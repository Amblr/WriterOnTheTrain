//
//  WTContentBlob.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 27/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import "L1Logger.h"

@class WTNode;

typedef enum WTTravelDirection {
    WTTravelDirectionAny=0,
    
    WTTravelDirectionEastbound=1,
    WTTravelDirectionWestbound=-1,
    
    WTTravelDirectionNorthbound=2,
    WTTravelDirectionSouthbound=-2,
    
} WTTravelDirection;

// Bit mask for days of week.
typedef enum WTDayOfWeek {
    WTDayOfWeekMonday = 1,
    WTDayOfWeekTuesday = 2,
    WTDayOfWeekWednesday = 4,
    WTDayOfWeekThursday = 8,
    WTDayOfWeekFriday = 16,
    WTDayOfWeekSaturday = 32,
    WTDayOfWeekSunday = 64,
    WTDayOfWeekAny = 127,
    WTDayOfWeekWeekend = 96,
} WTDayOfWeek;

typedef enum WTWindowDirection{
    WTWindowDirectionLeft=1,
    WTWindowDirectionRight=-1,
    WTWindowDirectionEither=0,
} WTWindowDirection;

typedef enum WTTimeOfDay{
    WTTimeOfDayAny=0,
    WTTimeOfDayMorning=1,
    WTTimeOfDayAfternoon=2,
    WTTimeOfDayEvening=3,
} WTTimeOfDay;

typedef int WTJourneySegment;
#define WTJourneySegmentAny -1
#define WTNumberOfJourneySegments 6

@interface WTContentBlob : NSObject
{
    //This contains both conditions for this media to be played and
    //the content itself
    
    //Conditionality
    WTTravelDirection travelDirection;
    WTWindowDirection windowDirection;
    WTJourneySegment journeySegment;
    NSInteger days;
    WTTimeOfDay timeOfDay;
    
    //Content
    NSString * title;
    NSString * text;
    NSString * strand;
    NSDecimalNumber * chapter;
    
    CLLocationCoordinate2D coordinate;
    

}

+(WTContentBlob*) contentBlobFromDictionary:(NSDictionary*) dictionary;

@property (assign) WTTravelDirection travelDirection;
@property (assign) WTWindowDirection windowDirection;
@property (assign) NSInteger days;
@property (assign) WTTimeOfDay timeOfDay;
@property (assign) WTJourneySegment journeySegment;

@property (retain) NSString * title;
@property (retain) NSString * text;
@property (retain) NSString * strand;
@property (retain) NSDecimalNumber * chapter;
@property (assign) CLLocationCoordinate2D coordinate;
@property (readonly) BOOL locationSpecific;


@end
