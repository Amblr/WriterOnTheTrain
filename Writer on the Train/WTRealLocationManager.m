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

@implementation WTRealLocationManager

-(id) initWithStoryManager:(id<WTLocationManagerDelegate>) manager
{
    self = [super initWithStoryManager:manager];
    if (self){
        // Our story manager
        // Activate the underlying location manager
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate: self];
        [locationManager setActivityType: CLActivityTypeOtherNavigation];
        
        // Set a timer to periodically ask for a high-res update.
        timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:HIGH_RES_LOCATION_INTERVAL_MINUTES*MINUTES target:self selector:@selector(getHighResolutionLocation:) userInfo:nil repeats:YES];
        timer.tolerance = (HIGH_RES_LOCATION_INTERVAL_MINUTES*MINUTES)/5.0;
        [[NSRunLoop currentRunLoop ] addTimer:timer forMode:NSDefaultRunLoopMode];
        
    }
    return self;
}


                 
-(void) getHighResolutionLocation:(NSTimer*) timer
{
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // The next location update should noe be at high accuracy
}


-(void) startJourney
{
    [locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
    [locationManager startUpdatingLocation];

}

-(void) endJourney
{
    [locationManager stopUpdatingLocation];    
}


-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    [storyManager locationUpdate:[locations lastObject]];
    
    // This might have been a high-accuracy one.
    // Just in case, switch back to low accuracy
    manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
}
    
@end
