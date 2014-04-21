//
//  WTFakeLocationManager.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 05/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import "WTFakeLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "L1SphericalGeometry.h"
#import "WTConfiguration.h"
@import MapKit;



@implementation WTFakeLocationManager
@synthesize fakeJourneyEnd;
@synthesize fakeJourneyStart;
@synthesize speed;
@synthesize journeyStartTime;

-(id) initWithStoryManager:(id<WTLocationManagerDelegate>) manager coordinate:(CLLocationCoordinate2D) startCoordinate
{
    self = [super initWithStoryManager:manager];
    if (self){
        // Set a timer to periodically ask for a high-res update.
        timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:FAKE_LOCATION_UPDATE_MINUTES*MINUTES target:self selector:@selector(updateFakeLocation:) userInfo:nil repeats:YES];
        timer.tolerance = (FAKE_LOCATION_UPDATE_MINUTES*MINUTES)/5.0;
        [[NSRunLoop currentRunLoop ] addTimer:timer forMode:NSDefaultRunLoopMode];
        
        self.fakeJourneyStart = startCoordinate;
        self.fakeJourneyEnd = CLLocationCoordinate2DMake(NAN, NAN);
        
    }
    return self;
}


-(void) journeyComplete:(CLLocationCoordinate2D) endPoint
{
    self.fakeJourneyStart = endPoint;
    moving=NO;
    self.journeyStartTime = nil;
    fakeJourneyEnd.latitude = NAN;
    fakeJourneyEnd.longitude = NAN;
    
}

-(CLLocationCoordinate2D) journeyPositionDoCheck:(BOOL) check
{
    MKMapPoint startPoint = MKMapPointForCoordinate(self.fakeJourneyStart);
    MKMapPoint endPoint = MKMapPointForCoordinate(self.fakeJourneyEnd);

    float timeSinceStartMinutes = [[NSDate date] timeIntervalSinceDate:self.journeyStartTime]/MINUTES; // This is in minutes now.
    //
    double journeyLength = sqrt(pow(endPoint.x-startPoint.x,2) + pow(endPoint.y-startPoint.y,2)  );
    double pointsPerMeter = MKMapPointsPerMeterAtLatitude((self.fakeJourneyStart.latitude+self.fakeJourneyEnd.latitude)/2.0);
    double pointsTravelled = timeSinceStartMinutes * speed * 60.0 * pointsPerMeter;

    if ((pointsTravelled>journeyLength) && check){
        [self journeyComplete:self.fakeJourneyEnd];
        return self.fakeJourneyStart;
        
    }
    
    double cosTheta =(endPoint.x-startPoint.x) / journeyLength;
    double sinTheta =(endPoint.y-startPoint.y) / journeyLength;

    MKMapPoint nowPoint;
    nowPoint.x = startPoint.x + cosTheta * pointsTravelled;
    nowPoint.y = startPoint.y + sinTheta * pointsTravelled;
    
    CLLocationCoordinate2D p = MKCoordinateForMapPoint(nowPoint);
    
    return p;
//      Clever Spherical stuff; too clever; doesn't work
//    float omega = speed / RADIUS_OF_EARTH_METERS; // from v = r omega
//    float radians = omega*time_since_start;
//    if (check && radians>finalTheta){
//        // Update to the new end point and return what is now the start (the old end)
//        [self journeyComplete:self.fakeJourneyEnd];
//        return self.fakeJourneyStart;
//    }
//    return find_rotated_coordinate(axisVector, originVector, radians);
}


-(void) updateFakeLocation:(NSTimer*) timer
{
    CLLocationCoordinate2D pos;
    if (moving) {
        pos = [self journeyPositionDoCheck:YES];
    }
    else{
        pos = self.fakeJourneyStart;
    }
    CLLocation * location = [[CLLocation alloc] initWithCoordinate:pos altitude:50.0 horizontalAccuracy:100.0 verticalAccuracy:100.0 timestamp:[NSDate date]];
    [storyManager locationUpdate:location];
}

-(void) startJourney;
{
    if ((!CLLocationCoordinate2DIsValid(self.fakeJourneyStart) || (!CLLocationCoordinate2DIsValid(self.fakeJourneyEnd)) )){
        NSLog(@"Cannot start journey - no destination");
        return;
    }
    moving = YES;
    self.journeyStartTime = [NSDate date];
//    coordinate_to_cartesian(self.fakeJourneyStart, originVector);
//    double dot = coordinate_dot_cross_product(self.fakeJourneyStart, self.fakeJourneyEnd, axisVector);
//    finalTheta = acos(dot);
//    normalize_vector(axisVector);
    
}
-(void) endJourney
{
    [self journeyComplete:[self journeyPositionDoCheck:NO]];

}


-(void) enterBackground
{
//    [timer invalidate];
    
}

@end
