//
//  WTContentBlob.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 27/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import "WTContentBlob.h"

@implementation WTContentBlob
@synthesize title;
@synthesize text;
@synthesize chapter;
@synthesize travelDirection;
@synthesize days;
@synthesize windowDirection;
@synthesize locationSpecific;
@synthesize journeySegment;

+(WTContentBlob*) contentBlobFromDictionary:(NSDictionary*) dictionary
{
    
    WTContentBlob * blob = [[WTContentBlob alloc] init];
    
    // Get basic data
    blob.title = [dictionary objectForKey:@"title"];
    blob.text = [dictionary objectForKey:@"text"];
    blob.chapter = [NSDecimalNumber decimalNumberWithString:[dictionary objectForKey:@"chapter"]];
    
    // Get the direction of travel
    NSString * journeyDirectionString = [dictionary objectForKey:@"direction"];
    if (journeyDirectionString==nil) blob.travelDirection = WTTravelDirectionAny;
    else if ([journeyDirectionString isEqualToString:@"east"]) blob.travelDirection = WTTravelDirectionEastbound;
    else if ([journeyDirectionString isEqualToString:@"west"]) blob.travelDirection = WTTravelDirectionWestbound;
    else if ([journeyDirectionString isEqualToString:@"north"]) blob.travelDirection = WTTravelDirectionNorthbound;
    else if ([journeyDirectionString isEqualToString:@"south"]) blob.travelDirection = WTTravelDirectionSouthbound;
    else if ([journeyDirectionString isEqualToString:@"any"]) blob.travelDirection = WTTravelDirectionAny;
    else NSAssert(NO, @"Invalid journey direction string %@", journeyDirectionString);
    
    // Get days of the week on which content is valid
    NSNumber * dayMask = [dictionary objectForKey:@"dayMask"];
    blob.days = (WTDayOfWeek) dayMask.intValue;
    
    // Which window to look out of for the inbound journey
    NSString * windowDirectionString = [dictionary objectForKey:@"window"];
    if (windowDirectionString==nil) blob.windowDirection = WTWindowDirectionEither;
    else if ([windowDirectionString isEqualToString:@"left"]) blob.windowDirection = WTWindowDirectionLeft;
    else if ([windowDirectionString isEqualToString:@"right"]) blob.windowDirection = WTWindowDirectionRight;
    else if ([windowDirectionString isEqualToString:@"either"]) blob.windowDirection = WTWindowDirectionEither;
    else NSAssert(NO, @"Invalid window direction string %@", windowDirectionString);

    NSString * timeOfDayString = [dictionary objectForKey:@"time"];
    if (timeOfDayString==nil) blob.timeOfDay = WTTimeOfDayAny;
    else if ([timeOfDayString isEqualToString:@"any"]) blob.timeOfDay = WTTimeOfDayAny;
    else if ([timeOfDayString isEqualToString:@"morning"]) blob.timeOfDay = WTTimeOfDayMorning;
    else if ([timeOfDayString isEqualToString:@"afternoon"]) blob.timeOfDay = WTTimeOfDayAfternoon;
    else NSAssert(NO, @"Invalid time of day string %@", timeOfDayString);


    

    
    //Valid journey segment
    NSNumber * journeySegmentNumber = [dictionary objectForKey:@"segment"];
    if (journeySegmentNumber==nil) blob.journeySegment = WTJourneySegmentAny;
    else blob.journeySegment = (WTJourneySegment) journeySegmentNumber.intValue;

    // We will not find this out until later.
    blob.locationSpecific = NO;
    
    return blob;
}

@end
