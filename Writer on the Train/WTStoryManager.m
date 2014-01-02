//
//  WTContentManager.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 28/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import "WTStoryManager.h"
#import "L1Scenario.h"
#import "WTConfiguration.h"
#import "WTNode.h"
#import "WTContentBlob.h"
#import "L1Utils.h"
#import "WTUtils.h"
#import "WTJourney.h"

@import CoreLocation;

#define HIGH_RES_LOCATION_INTERVAL_MINUTES 10
#define DELAY_FOR_NONLOCATION_TRIGGER_MINUTES 10

// JAZ Can change this to simulate
#define MINUTES 1.0
#define WTDEBUG YES

#ifdef WTDEBUG
#   define WTDEBUGLOG(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#else
#   define WTDEBUGLOG(...)
#endif



@implementation WTStoryManager

#pragma mark -
#pragma mark Properties

@synthesize delegate;
@synthesize homeCoordinate;
@synthesize workCoordinate;
@synthesize journey;
@synthesize playedBlobs;
@synthesize scheduledContentBlob;


#pragma mark -
#pragma mark Life cycle and delegate

-(id) init
{
    self = [super init];
    if (self){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.activityType = CLActivityTypeOtherNavigation;
        
        highResolutionLocationInterval = HIGH_RES_LOCATION_INTERVAL_MINUTES * MINUTES;
        inHighResolutionRegion = NO;
        
        // Load scenario
        scenario = [L1Scenario scenarioFromStoryURL:WT_STORY_URL withKey:WT_SCENARIO_KEY];
        scenario.delegate = self;
        scenario.nodeClass = [WTNode class];
        [scenario retain];
        
        journey = nil;
        
        // coordinates, before they are set.
        homeCoordinate.latitude = NAN;
        homeCoordinate.longitude = NAN;
        workCoordinate.longitude = NAN;
        workCoordinate.latitude = NAN;

        // Load content blobs
        contentBlobs = [[NSMutableArray alloc] initWithCapacity:0];
        blobStatus = [[NSMutableDictionary alloc] initWithCapacity:0];
        playedBlobs = [[NSMutableSet alloc] initWithCapacity:0];
        NSArray * contentDictionaries = [L1Utils arrayFromJsonFile:@"blobs"];
        for (NSDictionary * dict in contentDictionaries){
            WTContentBlob * blob = [WTContentBlob contentBlobFromDictionary:dict];
            [contentBlobs addObject:blob];
            [blobStatus setObject:[NSNumber numberWithInt:0] forKey:blob.chapter];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relaunch:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

-(void) relaunch:(NSNotification*) notification
{
    if (self.scheduledContentBlob){
        [self displayContent:self.scheduledContentBlob];
        self.scheduledContentBlob = nil;
    }
        
}

-(void) nodeSource:(L1Scenario*) nodeScenario didReceiveNodes:(NSDictionary*) nodeDictionary
{
    // Just record that we have the nodes - keep them ourselves
    nodes = [nodeDictionary retain];
}


#pragma mark -
#pragma mark Setting journey parameters

-(BOOL) startJourney
{
    if (isnan(homeCoordinate.latitude) || isnan(workCoordinate.latitude)){
        [delegate chooseStationRequest];
        return NO;
    }
    // Start location behaviour
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    [locationManager startUpdatingLocation];

    // Some parameters about our journey
    haveShownNonlocationContent = NO;
    
    self.journey = [WTJourney journey];
    
    // Set direction of travel.
    // Work it out by which station is nearer.  We indicate that we do not know the
    // travel direction yet by setting it to "any".
    // then the first location update will set it
    [self performSelector:@selector(getHighResolutionLocation) withObject:nil afterDelay:highResolutionLocationInterval];
    return YES;
}


-(void) endJourney
{
    [locationManager stopUpdatingLocation];
    self.journey = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getHighResolutionLocation) object:nil];
}


#pragma mark -
#pragma mark Location update handling




-(void) getHighResolutionLocation
{
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self performSelector:@selector(getHighResolutionLocation) withObject:nil afterDelay:highResolutionLocationInterval];
}




- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    NSLog(@"Location update (%@ res)", locationManager.desiredAccuracy==kCLLocationAccuracyBest?@"High":@"Low");
    CLLocation * currentLocation = [locations lastObject];
    
    // If we do not know the travel direction yet then figure it out
    // and that is the only thing we do
    if (journey.travelDirection==WTTravelDirectionAny){
        [self.journey determineJourneyDirectionFromCoordinate:currentLocation.coordinate home:homeCoordinate work:workCoordinate];
        return;
    }
    
    // Update the fraction of the journey we have done
    [journey determineJourneySegment:currentLocation.coordinate];

    // Find some content and display it if found
    WTContentBlob * content = [self findContentForCoordinate:currentLocation.coordinate];
    if (content) [self displayContent:content];

    // If we are not in an explicit high-res region (i.e., if we have a one-off high-res location from the interval)
    // then switch back to low-res location
    if (!inHighResolutionRegion) locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;

}




#pragma mark -
#pragma mark Content Selection


-(BOOL) contentBlob:(WTContentBlob*) blob isValidAtCoordinate:(CLLocationCoordinate2D) coordinate
{
    // Check if blob has already been used
    if ([playedBlobs containsObject:blob.chapter]) {
        return NO;
    }
    
    WTDayOfWeek currentDayOfWeek = WTCurrentDayOfWeek();
    if (!(currentDayOfWeek & blob.days)) return NO;
    if ((blob.travelDirection != journey.travelDirection) && (blob.travelDirection!=WTTravelDirectionAny)) return NO;
    if ((blob.journeySegment!=journey.journeySegment) && (blob.journeySegment!=WTJourneySegmentAny)) return NO;

    return YES;
}

-(WTContentBlob*) validContentMatchingName:(NSString*)name atCoordinate:(CLLocationCoordinate2D) coordinate
{
    for (WTContentBlob* blob in contentBlobs){
        if (![blob.title isEqualToString:name]) continue;
        if ([self contentBlob:blob isValidAtCoordinate:coordinate]){
            blob.locationSpecific = YES;
            return blob;
        }
    }
    return nil;
}

-(WTContentBlob*) nextValidContentAtCoordinate:(CLLocationCoordinate2D) coordinate
{
    for (WTContentBlob* blob in contentBlobs){
        if ([self contentBlob:blob isValidAtCoordinate:coordinate]) {
            WTDEBUGLOG(@"Blob IS valid %@", blob);
            return blob;
        }
        else{
            WTDEBUGLOG(@"Blob not valid %@", blob);
        }
    }
    return nil;
}


-(WTContentBlob*) findContentForCoordinate:(CLLocationCoordinate2D) coordinate
{
    WTContentBlob * content = nil;
    
    // Check the nodes in the scenario to see if one of them is hit.
    // If so, ask the ContentSequencer to see if there is a matching and valid ContentBlob
    // If there is, activate it.
    NSString * activatedNodeName = nil;
    for (WTNode * node in [nodes allValues]){
        if ([node.region containsCoordinate:coordinate]){
            activatedNodeName = node.name;
            break;
        }
    }
    if (activatedNodeName){
        content = [self validContentMatchingName:activatedNodeName atCoordinate:coordinate];
    }
    else if (!haveShownNonlocationContent){
        // Alternatively we may have reached a length of time after
        // which to show some content regardless of location
        NSTimeInterval elapsed = -[journey.journeyStartTime timeIntervalSinceNow];
        if (elapsed>DELAY_FOR_NONLOCATION_TRIGGER_MINUTES*MINUTES){
            content = [self nextValidContentAtCoordinate:coordinate];
            haveShownNonlocationContent = YES;
        }
    }
    return content;
}

-(WTContentBlob*) blobForChapter:(NSDecimalNumber*) chapter
{
    for (WTContentBlob* blob in contentBlobs){
        if ([blob.chapter isEqualToNumber:chapter]) return blob;
    }
    return nil;
}

-(void) displayContentFromBackground:(NSDictionary*) info
{
    // in this case we take responsibilty
    // for telling the story manager the blob is done.
    NSDecimalNumber * chapter = [info objectForKey:@"blob"];
    WTContentBlob * blob = [self blobForChapter:chapter];
    if (blob) [self displayContent:blob];
}


-(void) displayContent:(WTContentBlob *)blob
{
    BOOL played = [delegate displayContent:blob];
    if (played) [playedBlobs addObject:blob.chapter];
    else self.scheduledContentBlob = blob;
}

-(NSInteger) contentCount
{
    return [contentBlobs count];
}

-(NSString*) titleForContentAtIndex:(NSInteger) index
{
    WTContentBlob * blob = [contentBlobs objectAtIndex:index];
    if ([playedBlobs containsObject:blob.chapter]) return blob.title;
    else return [NSString  stringWithFormat:@"--- %@ ---", blob.title];
    
}

-(WTContentBlob*) contentAtIndex:(NSInteger) index
{
    return [contentBlobs objectAtIndex:index];
}

@end
