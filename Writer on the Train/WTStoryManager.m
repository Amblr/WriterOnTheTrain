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
#import "WTRealLocationManager.h"
#import "WTFakeLocationManager.h"

@import CoreLocation;


#define LOCATION_ACCURACY_FOR_DISPLAY 500
#define LOCATION_DISTANCE_FOR_DISPLAY 500

// This definitely will not work for the real case
#define DISTANCE_FROM_STATION_FOR_STARTING_JOURNEY 5000.0


@implementation WTStoryManager

#pragma mark -
#pragma mark Properties

@synthesize delegate;
@synthesize homeCoordinate;
@synthesize workCoordinate;
@synthesize journey;
@synthesize playedBlobs;
@synthesize scheduledContentBlob;
@synthesize fakeDate;
@synthesize fakeDirectionOfTravel;

#pragma mark -
#pragma mark Life cycle and delegate

-(id) init
{
    self = [super init];
    if (self){
        
#if (REAL_LOCATION)
        locationManager = [[WTRealLocationManager alloc] initWithStoryManager:self];
#else
        locationManager = [[WTFakeLocationManager alloc] initWithStoryManager:self coordinate:CLLocationCoordinate2DMake(NAN, NAN)];
#endif
        
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
        
        self.fakeDate = [NSDate date];
        self.fakeDirectionOfTravel = WTTravelDirectionEastbound;
        
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
    NSLog(@"Recevied %lu nodes",(unsigned long)[nodes count]);
}


#pragma mark -
#pragma mark Setting journey parameters

-(void) enableBackgroundMode
{
#if (!REAL_LOCATION)
    WTFakeLocationManager * fakeLocationManager = (WTFakeLocationManager*) locationManager;
    [fakeLocationManager enterBackground];
#endif
}

-(void) checkForJourneyStart:(CLLocation*) location
{
    
// Early return if we are simulating location
#if (!REAL_LOCATION)
    return;
#endif
    
    
    if (isnan(homeCoordinate.latitude) || isnan(workCoordinate.latitude)){
        return;
    }

    CLLocation * homeLocation = [[CLLocation alloc] initWithLatitude:homeCoordinate.latitude longitude:homeCoordinate.longitude];
    CLLocation * workLocation = [[CLLocation alloc] initWithLatitude:workCoordinate.latitude longitude:workCoordinate.longitude];
    
    CLLocationDistance homeDistance = [homeLocation distanceFromLocation:location];
    CLLocationDistance workDistance = [workLocation distanceFromLocation:location];
    
    if (homeDistance<DISTANCE_FROM_STATION_FOR_STARTING_JOURNEY || workDistance<DISTANCE_FROM_STATION_FOR_STARTING_JOURNEY){
        [self startJourney];
    }
    
    [homeLocation release];
    [workLocation release];
}


-(BOOL) startJourney
{
    if (isnan(homeCoordinate.latitude) || isnan(workCoordinate.latitude)){
        [delegate chooseStationRequest];
        return NO;
    }

    // Some parameters about our journey
    haveShownContentOnThisJourney = NO;
    
    self.journey = [WTJourney journey];
    L1Log(@"Begun journey%@", @"");
    
    
    // This bit is all for simulations only
#if (!REAL_LOCATION)
    WTFakeLocationManager * fakeLocationManager = (WTFakeLocationManager*) locationManager;
    if (fakeDirectionOfTravel>0){
        fakeLocationManager.fakeJourneyStart = homeCoordinate;
        fakeLocationManager.fakeJourneyEnd = workCoordinate;
    }
    else{
        fakeLocationManager.fakeJourneyStart = workCoordinate;
        fakeLocationManager.fakeJourneyEnd = homeCoordinate;
    }
    fakeLocationManager.speed = TRAIN_SPEED;
    
#endif
    
    // Set direction of travel.
    // Work it out by which station is nearer.  We indicate that we do not know the
    // travel direction yet by setting it to "any".
    // then the first location update will set it
    journey.travelDirection = WTTravelDirectionAny;
    
    [delegate didStartJourney:self.journey];
    return YES;
}


-(void) endJourney
{
    self.journey = nil;
    self.scheduledContentBlob = nil;
    [locationManager endJourney];
}


#pragma mark -
#pragma mark Location update handling


- (void) locationUpdate:(CLLocation*) location
{
    
    [self.delegate locationUpdate:location];
    
    if (journey==nil){
        [self checkForJourneyStart:location];
        return;
    }
    
    // If we do not know the travel direction yet then figure it out
    // and that is the only thing we do
    if (journey.travelDirection==WTTravelDirectionAny){
        [self.journey determineJourneyDirectionFromCoordinate:location.coordinate home:homeCoordinate work:workCoordinate];
        L1Log(@"Determined travel direction: %d", self.journey.travelDirection);

        // Only now can we schedule some content
        self.scheduledContentBlob = [self selectContentForJourney];
        if (self.scheduledContentBlob){
            L1Log(@"Scheduled content: %@", self.scheduledContentBlob.title);
        }
        
        [locationManager startJourneyWithTargetCoordinate:self.scheduledContentBlob.coordinate];
        
        
        return;
    }
    
    if (haveShownContentOnThisJourney){
        // This probably shouldn't happen - we should switch off location updates once we
        // have seen the content.
        L1Log(@"No more content due this journey %@", @"");
        return;
    }
    
    
    // Update the fraction of the journey we have done
    [journey determineJourneySegment:location.coordinate];

    // Find some content and display it if found
    if ([self scheduledContentIsValidAtLocation:location])
    {
        [self displayContent:self.scheduledContentBlob];
        haveShownContentOnThisJourney = YES;
        // The journey is over as far as we are concerned because we have seen the only
        // content we will see
        [self endJourney];
    }

}




#pragma mark -
#pragma mark Content Selection

-(WTContentBlob*) selectContentForJourney
{
    for (WTContentBlob * blob in contentBlobs){
        if ([self contentBlobisValidForJourney:blob]) {
            return blob;
        }
    }
    return nil;
}

-(BOOL) scheduledContentIsValidAtLocation:(CLLocation*) location
{
    if (scheduledContentBlob.locationSpecific){
        if (location.horizontalAccuracy>LOCATION_ACCURACY_FOR_DISPLAY) return NO;
        CLLocation * contentLocation = [[[CLLocation alloc] initWithLatitude:scheduledContentBlob.coordinate.latitude longitude:scheduledContentBlob.coordinate.longitude] autorelease];
        return [location distanceFromLocation:contentLocation] < LOCATION_DISTANCE_FOR_DISPLAY;
    }
    else{
        return self.scheduledContentBlob.journeySegment>=self.journey.journeySegment;
    }
}

+(BOOL) isMorning
{
    NSDateComponents * components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:[NSDate date]];
    NSInteger h = components.hour;
    return (h>0 && h<12);
}

-(BOOL) contentBlobisValidNow:(WTContentBlob*) blob
{
    // Check if blob has already been used
    if ([playedBlobs containsObject:blob.chapter]) {
        return NO;
    }
#if (REAL_LOCATION==0)
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:self.fakeDate];
    NSInteger weekday = components.weekday - 1; // Sunday=0, Monday=1, ...
    NSInteger weekdayFromMonday = ((weekday-1)%7);// Monday=0, Tuesday=1, ...
    NSInteger weekdayPower = 1<<weekdayFromMonday;
    WTDayOfWeek currentDayOfWeek = (int)weekdayPower;
    NSDateComponents *hourComponents = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:self.fakeDate];
    NSInteger hour = hourComponents.hour;
    WTTimeOfDay timeOfDay;
    if (hour<12) timeOfDay = WTTimeOfDayMorning;
    else if (hour<17) timeOfDay = WTTimeOfDayAfternoon;
    else timeOfDay = WTTimeOfDayEvening;
#else
    WTDayOfWeek currentDayOfWeek = WTCurrentDayOfWeek();
    WTTimeOfDay timeOfDay = [WTStoryManager isMorning] ? WTTimeOfDayMorning : WTTimeOfDayAfternoon;
    
#endif
    if ((blob.timeOfDay!=WTTimeOfDayAny) && (blob.timeOfDay!=timeOfDay)) {
        L1Log(@"%@ not valid time=%d not %d", blob.title, timeOfDay, blob.timeOfDay); // blank line for clarity
        
        return NO;
    }
    if (!(currentDayOfWeek & blob.days)) {
        L1Log(@"%@ not valid day=%d not binary & %d", blob.title, currentDayOfWeek, blob.days);
        return NO;
    }
    return YES;
}



-(BOOL) contentBlob:(WTContentBlob*) blob isValidAtCoordinate:(CLLocationCoordinate2D) coordinate
{
    
    
    // Location check.
    // There are two types of location we have - journey segments and lat/lon
    if (CLLocationCoordinate2DIsValid(blob.coordinate)){
        CLLocation * blobLocation = [[CLLocation alloc] initWithLatitude:blob.coordinate.latitude longitude:blob.coordinate.longitude];
        CLLocation * ourLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        CLLocationDistance d = [ourLocation distanceFromLocation:blobLocation];
        [blobLocation release];
        [ourLocation release];
        BOOL close = d<LOCATION_SPECIFIC_NODE_SIZE_METERS;
        if (close) {
            L1Log(@"Close enough (%f) for %@!",d,blob.title);
        }
        else {
            L1Log(@"%@ not valid too far away (%f meters)", blob.title, d);
        }
        return close;
    }
    else{
        // If we get here the journey segment should not be -1, since that would mean we have neither a location nor
        // a segment
        BOOL rightSegment =(blob.journeySegment==journey.journeySegment);
        if (!rightSegment){
            L1Log(@"%@ not valid segment = %d not %d", blob.title, journey.journeySegment, blob.journeySegment);
        }
        else{
            L1Log(@"Right segment (%d,%d) for %@!",journey.journeySegment, blob.journeySegment, blob.title);
        }
        return rightSegment;
    }
}

-(BOOL) coordinateIsValidForJourney:(CLLocationCoordinate2D) coordinate
{
    // For now, just assume that any point is okay if
    // it lies between the start and end in longitude.
    // This WILL NOT WORK for branch-line content, nor if the
    // line doubles back on itself somehow.
    CLLocationDegrees lon = coordinate.longitude;
    CLLocationDegrees startLon = journey.journeyStart.longitude;
    CLLocationDegrees endLon = journey.journeyEnd.longitude;
    BOOL ok =(lon-startLon)*(lon-endLon)<0;
    return ok;
}

-(BOOL) contentBlobisValidForJourney:(WTContentBlob*) blob
{
    if (![self contentBlobisValidNow:blob]) return NO;
    
    if ((blob.travelDirection != journey.travelDirection) && (blob.travelDirection!=WTTravelDirectionAny)){
        L1Log(@"%@ not valid direction=%d not %d", blob.title, journey.travelDirection, blob.travelDirection);
        return NO;
    }
    
    // If blob is not location-specific then somewhere along this journey it will be valid
    if (!blob.locationSpecific) return YES;
    
    // otherwise check explicitloy
    BOOL ok =  [self coordinateIsValidForJourney:blob.coordinate];
    if (!ok) L1Log(@"%@ not along journey path (lon=%f)",blob.title, blob.coordinate.longitude);

    return ok;
}



#pragma mark -
#pragma mark Content Display


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

#pragma mark -
#pragma mark Content Listing

-(NSInteger) contentCount
{
    return [contentBlobs count];
}

-(NSString*) titleForContentAtIndex:(NSInteger) index
{
    WTContentBlob * blob = [contentBlobs objectAtIndex:index];
    if ([self contentAtIndexIsAvailable:index]) return blob.title;
    else return [NSString  stringWithFormat:@"-%@", blob.title];
    
}

-(WTContentBlob*) contentAtIndex:(NSInteger) index
{
    return [contentBlobs objectAtIndex:index];
}

-(BOOL) contentAtIndexIsAvailable:(NSInteger) index;
{
    WTContentBlob * blob = [contentBlobs objectAtIndex:index];
    return [playedBlobs containsObject:blob.chapter];
}

-(WTContentBlob*) nextBlobFrom:(WTContentBlob*) blob
{
    NSInteger index = [contentBlobs indexOfObject:blob];
    NSInteger next = (index+1) % [contentBlobs count];
    return [self contentAtIndex:next];
    
}
-(WTContentBlob*) previousBlobFrom:(WTContentBlob*) blob
{
    NSInteger index = [contentBlobs indexOfObject:blob];
    NSInteger prev = (index-1) % [contentBlobs count];
    return [self contentAtIndex:prev];

}


@end
