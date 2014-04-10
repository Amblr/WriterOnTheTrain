//
//  WTJourney.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 30/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import "WTContentBlob.h"

@interface WTJourney : NSObject
{
    CLLocationCoordinate2D journeyStart;
    CLLocationCoordinate2D journeyEnd;
    NSDate * journeyStartTime;
    WTTravelDirection travelDirection;
    WTJourneySegment journeySegment;
    WTDayOfWeek currentDayOfWeek;

}
@property (assign) CLLocationCoordinate2D journeyStart;
@property (assign) CLLocationCoordinate2D journeyEnd;
@property (retain) NSDate * journeyStartTime;
@property (assign) WTTravelDirection travelDirection;
@property (assign) WTJourneySegment journeySegment;



-(id) init;
+(WTJourney*) journey;
-(void) startJourney;
-(void) determineJourneySegment:(CLLocationCoordinate2D) coordinate;
-(void) determineJourneyDirectionFromCoordinate:(CLLocationCoordinate2D) coordinate home:(CLLocationCoordinate2D) homeCoordinate work:(CLLocationCoordinate2D) workCoordinate;

@end
