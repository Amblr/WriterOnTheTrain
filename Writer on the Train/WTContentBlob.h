//
//  WTContentBlob.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 27/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import <Foundation/Foundation.h>

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

typedef int WTJourneySegment;
#define WTJourneySegmentAny 0
#define WTNumberOfJourneySegments 20

@interface WTContentBlob : NSObject
{
    //This contains both conditions for this media to be played and
    //the content itself
    
    //Conditionality
    WTTravelDirection travelDirection;
    WTWindowDirection windowDirection;
    WTJourneySegment journeySegment;
    WTDayOfWeek days;
    
    //Content
    NSString * title;
    NSString * text;
    NSDecimalNumber * chapter;
}

+(WTContentBlob*) contentBlobFromDictionary:(NSDictionary*) dictionary;

@property (assign) WTTravelDirection travelDirection;
@property (assign) WTWindowDirection windowDirection;
@property (assign) WTDayOfWeek days;
@property (assign) WTJourneySegment journeySegment;

@property (retain) NSString * title;
@property (retain) NSString * text;
@property (retain) NSDecimalNumber * chapter;



@end
