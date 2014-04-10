//
//  WTFakeLocationManager.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 05/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import "WTLocationManager.h"
#import <CoreLocation/CoreLocation.h>

@class NSTimer;
@interface WTFakeLocationManager : WTLocationManager
{
    NSTimer * timer;
    CLLocationCoordinate2D fakeJourneyStart;
    CLLocationCoordinate2D fakeJourneyEnd;
    NSDate * journeyStartTime;
    CLLocationSpeed speed;
    CLLocationCoordinate2D currentLocation;
    
    BOOL moving;
    CLLocationCoordinate2D  origin;
    CLLocationCoordinate2D destination;
    double finalTheta;
    double originVector[3];
    double axisVector[3];

}
-(id) initWithStoryManager:(id<WTLocationManagerDelegate>) manager coordinate:(CLLocationCoordinate2D) startCoordinate;
@property (assign) CLLocationCoordinate2D fakeJourneyStart;
@property (assign) CLLocationCoordinate2D fakeJourneyEnd;
@property (assign) CLLocationSpeed speed;
@property (retain) NSDate * journeyStartTime;


@end
