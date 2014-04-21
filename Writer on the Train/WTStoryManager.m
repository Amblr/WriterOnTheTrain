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

-(BOOL) startJourney
{
    if (isnan(homeCoordinate.latitude) || isnan(workCoordinate.latitude)){
        [delegate chooseStationRequest];
        return NO;
    }
    // Start location behaviour

    // Some parameters about our journey
    haveShownContentOnThisJourney = NO;
    
    self.journey = [WTJourney journey];
    
    
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
    
    
    [locationManager startJourney];
    
    // Set direction of travel.
    // Work it out by which station is nearer.  We indicate that we do not know the
    // travel direction yet by setting it to "any".
    // then the first location update will set it
    journey.travelDirection = WTTravelDirectionAny;
    return YES;
}


-(void) endJourney
{
    self.journey = nil;
}


#pragma mark -
#pragma mark Location update handling



- (void) locationUpdate:(CLLocation*) location
{
    
    [self.delegate locationUpdate:location];
    
    if (journey==nil){
        return;
    }
    
    // If we do not know the travel direction yet then figure it out
    // and that is the only thing we do
    if (journey.travelDirection==WTTravelDirectionAny){
        [self.journey determineJourneyDirectionFromCoordinate:location.coordinate home:homeCoordinate work:workCoordinate];
        WTDEBUGLOG(@"Determining travel direction");
        return;
    }
    
    if (haveShownContentOnThisJourney){
        // This probably shouldn't happen - we should switch off location updates once we
        // have seen the content.
        WTDEBUGLOG(@"No more content due this journey");
        return;
    }
    
    
    // Update the fraction of the journey we have done
    [journey determineJourneySegment:location.coordinate];

    // Find some content and display it if found
    WTContentBlob * content = [self findContentForCoordinate:location.coordinate];
    if (content) {
        [self displayContent:content];
        haveShownContentOnThisJourney = YES;
        // The journey is over as far as we are concerned because we have seen the only
        // content we will see
        [self endJourney];
    }

}




#pragma mark -
#pragma mark Content Selection

+(BOOL) isMorning
{
    NSDateComponents * components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:[NSDate date]];
    NSInteger h = components.hour;
    return (h>0 && h<12);
}


-(BOOL) contentBlob:(WTContentBlob*) blob isValidAtCoordinate:(CLLocationCoordinate2D) coordinate
{
    // Check if blob has already been used
    if ([playedBlobs containsObject:blob.chapter]) {
        return NO;
    }
    
#if (REAL_LOCATION==0)
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:self.fakeDate];
    NSInteger weekday = components.weekday; // Sunday=1, Monday=2, ...
    NSInteger weekdayFromMonday = ((weekday+1)%7)+1 ;
    NSInteger weekdayPower = 1<<weekdayFromMonday;
    WTDayOfWeek currentDayOfWeek = weekdayPower;
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
        WTDEBUGLOG(@"Wrong time of day (%d,%d) for %@",timeOfDay, blob.timeOfDay, blob.title);
        return NO;
    }
    if (!(currentDayOfWeek & blob.days)) {
        WTDEBUGLOG(@"Wrong day of week (%d,%d) for %@",currentDayOfWeek, blob.days, blob.title);
        return NO;
    }
    if ((blob.travelDirection != journey.travelDirection) && (blob.travelDirection!=WTTravelDirectionAny)){
        WTDEBUGLOG(@"Wrong travel direction (%d,%d) for %@",journey.travelDirection, blob.travelDirection, blob.title);
        return NO;
        
    }
    
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
            WTDEBUGLOG(@"Close enough (%f) for %@!",d,blob.title);
        }
        else {
            WTDEBUGLOG(@"Too far (%f) for %@!",d,blob.title);
        }
        return close;
    }
    else{
        // If we get here the journey segment should not be -1, since that would mean we have neither a location nor
        // a segment
        BOOL rightSegment =(blob.journeySegment==journey.journeySegment);
        if (!rightSegment){
            WTDEBUGLOG(@"Wrong segment (%d,%d) for %@!",journey.journeySegment, blob.journeySegment, blob.title);
        }
        else{
            WTDEBUGLOG(@"Right segment (%d,%d) for %@!",journey.journeySegment, blob.journeySegment, blob.title);
        }
        return rightSegment;
    }
}

//-(WTContentBlob*) validContentMatchingName:(NSString*)name atCoordinate:(CLLocationCoordinate2D) coordinate
//{
//    for (WTContentBlob* blob in contentBlobs){
//        if (![blob.title isEqualToString:name]) continue;
//        if ([self contentBlob:blob isValidAtCoordinate:coordinate]){
//            return blob;
//        }
//    }
//    return nil;
//}

//-(WTContentBlob*) nextValidContentAtCoordinate:(CLLocationCoordinate2D) coordinate
//{
//    for (WTContentBlob* blob in contentBlobs){
//        if ([self contentBlob:blob isValidAtCoordinate:coordinate]) {
//            WTDEBUGLOG(@"Blob IS valid %@", blob);
//            return blob;
//        }
//        else{
//            WTDEBUGLOG(@"Blob not valid %@", blob);
//        }
//    }
//    return nil;
//}


-(WTContentBlob*) findContentForCoordinate:(CLLocationCoordinate2D) coordinate
{
    WTContentBlob * content = nil;
    for (WTContentBlob * blob in contentBlobs){
        if ([self contentBlob:blob isValidAtCoordinate:coordinate]){
            WTDEBUGLOG(@"Content %@ is VALID", blob.title);
            content=blob;
            break;
        }
        else{
        }
    }
    return content;
    
    // For each node we check if the node is either near to where we are or
    //
    
    
    
    // Check the nodes in the scenario to see if one of them is hit.
    // If so, ask the ContentSequencer to see if there is a matching and valid ContentBlob
    // If there is, activate it.
//    NSString * activatedNodeName = nil;
//    for (WTNode * node in [nodes allValues]){
//        if ([node.region containsCoordinate:coordinate]){
//            activatedNodeName = node.name;
//            break;
//        }
//    }
//    if (activatedNodeName){
//        content = [self validContentMatchingName:activatedNodeName atCoordinate:coordinate];
//    }
//    else if (!haveShownNonlocationContent){
//        // Alternatively we may have reached a length of time after
//        // which to show some content regardless of location
//        NSTimeInterval elapsed = -[journey.journeyStartTime timeIntervalSinceNow];
//        if (elapsed>DELAY_FOR_NONLOCATION_TRIGGER_MINUTES*MINUTES){
//            content = [self nextValidContentAtCoordinate:coordinate];
//            haveShownNonlocationContent = YES;
//        }
//    }
//    
    
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
