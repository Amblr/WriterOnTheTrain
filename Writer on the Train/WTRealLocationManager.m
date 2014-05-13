//
//  WTLocationManager.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 05/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import "WTRealLocationManager.h"
#import "WTStoryManager.h"
#import "WTConfiguration.h"

// The desired behaviour is:
// starting at the scheduled start time...
//      Check if we are on the train...
//      If so:
//          If there is a target location:
//              Every 10 minutes, check high-res location for one blip
//              If "near" a target location, stay at high res until we find it and complete the journey,
//              Or some max time otherwise
//          Otherwise, just use significant location monitoring and find when we pass the segment

#define HORIZONTAL_ACCURACY_FOR_HIGHRES 1000.0
#define DISTANCE_TO_SWITCH_ON_FULL_HIGHRES 5000.0
#define FULL_HIGH_RES_TIME_LIMIT 300.0
#define OVERALL_TIME_LIMIT 6000


// Mode where we have not started the journey yet
#define MODE_NONE 0

// Mode where we are checking high-res location every ten minutes
#define MODE_PERIODIC_HIGHRES_ON 1
#define MODE_PERIODIC_HIGHRES_WAITING 2

// Mode where we are close to location-specific content and working at high-res
#define MODE_NEARBY_HIGHRES 3

// Mode where we are not looking for location-specific content, just a rough segment
#define MODE_LOWRES 4


@implementation WTRealLocationManager
@synthesize timer;
@synthesize targetCoordinate;
@synthesize modeStartTime;

-(id) initWithStoryManager:(id<WTLocationManagerDelegate>) manager
{
    self = [super initWithStoryManager:manager];
    if (self){
        // Our story manager
        // Activate the underlying location manager
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate: self];
        [locationManager setActivityType: CLActivityTypeOtherNavigation];
        self.timer = nil;
        self.modeStartTime = nil;
        mode = MODE_NONE;
        // Set a timer to periodically ask for a high-res update.
        
    }
    return self;
}


                 
-(void) enterHighResPeriodicOnMode:(NSTimer*) timer
{
    L1Log(@"Starting high-res location check", @"");
    [locationManager startUpdatingLocation];
    mode = MODE_PERIODIC_HIGHRES_ON;
    
}

-(void) enterHighResPeriodicWaitingMode
{
    L1Log(@"Setting timer for high-res location check", @"");
    self.modeStartTime = [NSDate date];

    self.timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:HIGH_RES_LOCATION_INTERVAL_MINUTES*MINUTES target:self selector:@selector(getHighResolutionLocation:) userInfo:nil repeats:NO];
    self.timer.tolerance = (HIGH_RES_LOCATION_INTERVAL_MINUTES*MINUTES)/10.0;
    [[NSRunLoop currentRunLoop ] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    mode = MODE_PERIODIC_HIGHRES_WAITING;
}

-(void) enterHighResNearbyMode
{
    L1Log(@"Entering full high-res location mode", @"");
    self.modeStartTime = [NSDate date];

    [self.timer invalidate];
    self.timer = nil;
    [locationManager startUpdatingLocation];
    mode = MODE_NEARBY_HIGHRES;
}

-(void) enterLowResMode
{
    L1Log(@"Entering low-res location mode", @"");

    mode = MODE_LOWRES;
    [locationManager startMonitoringSignificantLocationChanges];
    [self.timer invalidate];
    self.timer = nil;
}

-(void) enterNoneMode
{
    L1Log(@"Stopping all location monitoring", @"");

    [self.timer invalidate];
    self.timer = nil;
    mode = MODE_NONE;
}

-(void) startJourneyWithTargetCoordinate:(CLLocationCoordinate2D)coordinate
{
    self.targetCoordinate = coordinate;

    // Case 1: there is location-specific content on this journey.
    // so we need a strategy to try to find it
    if (CLLocationCoordinate2DIsValid(coordinate)){
        [self enterHighResPeriodicWaitingMode];
    }
    else{
        [self enterLowResMode];
    }
}

-(void) endJourney
{
    [locationManager stopUpdatingLocation];
    [self enterNoneMode];
}

-(void) checkTimeLimits
{
    float t = -[modeStartTime timeIntervalSinceNow];

    if (mode==MODE_NEARBY_HIGHRES){
                if (t>FULL_HIGH_RES_TIME_LIMIT){
            L1Log(@"Stayed too long in full high-res (%f seconds)",t);
            [self enterNoneMode];
        }
    }
    else if (mode==MODE_LOWRES || mode==MODE_PERIODIC_HIGHRES_WAITING || mode==MODE_PERIODIC_HIGHRES_WAITING){
        
        if (t>OVERALL_TIME_LIMIT){
            L1Log(@"Stayed too long in periodic high-res mode (%f seconds)",t);
            [self enterNoneMode];
        }
    }
    
    
}


-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation * location = [locations lastObject];
    
    // In low-res mode we just continue
    if (mode==MODE_LOWRES){
        [storyManager locationUpdate:location];
        [self checkTimeLimits];
    }
    else if (mode==MODE_NEARBY_HIGHRES){
        [storyManager locationUpdate:location];
        [self checkTimeLimits];
        // Check if we have gone on too long and should quit
    }
    else if (mode==MODE_PERIODIC_HIGHRES_WAITING){
        // This will be a coincidental low-res update while waiting for the high-res one.
        [storyManager locationUpdate:location];
        [self checkTimeLimits];
        // Check if we have gone on too long and should quit
    }
    else if (mode==MODE_PERIODIC_HIGHRES_ON){
        [storyManager locationUpdate:location];
        
        // It is possible we should switch to high-res here.
        CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:targetCoordinate.latitude longitude:targetCoordinate.longitude];
        
        if ([location distanceFromLocation:targetLocation] < DISTANCE_TO_SWITCH_ON_FULL_HIGHRES){
            [self enterHighResNearbyMode];
        }
        // Check if we have gone on too long and should quit
        // If this was a high-res update (the first is approximate) then return to periodic mode
        else if (location.horizontalAccuracy<HORIZONTAL_ACCURACY_FOR_HIGHRES){
            [self enterHighResPeriodicWaitingMode];
        }
        [targetLocation release];
        [self checkTimeLimits];

    }
    else{
        NSAssert(mode==MODE_NONE, @"Error in MODE");
        [locationManager stopMonitoringSignificantLocationChanges];
        [locationManager stopUpdatingLocation];
    }
    
    
}
    
@end
