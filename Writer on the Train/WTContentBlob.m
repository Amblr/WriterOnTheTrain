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
@synthesize journeySegment;
@synthesize strand;
@synthesize timeOfDay;
@synthesize coordinate;

-(BOOL) locationSpecific
{
    return CLLocationCoordinate2DIsValid(coordinate);
}

+(WTContentBlob*) contentBlobFromDictionary:(NSDictionary*) dictionary
{
    
    WTContentBlob * blob = [[WTContentBlob alloc] init];
    
    // Get basic data
    blob.title = [dictionary objectForKey:@"Name"];
    blob.text = [dictionary objectForKey:@"Text"];
    blob.strand = [dictionary objectForKey:@"Strand"];
    blob.chapter = [NSDecimalNumber decimalNumberWithString:[dictionary objectForKey:@"Position"]];
    
    // Get the direction of travel
    NSString * journeyDirectionString = [[dictionary objectForKey:@"Direction of Travel"] lowercaseString];
    if (journeyDirectionString==nil) blob.travelDirection = WTTravelDirectionAny;
    else if ([journeyDirectionString isEqualToString:@"east"]) blob.travelDirection = WTTravelDirectionEastbound;
    else if ([journeyDirectionString isEqualToString:@"west"]) blob.travelDirection = WTTravelDirectionWestbound;
    else if ([journeyDirectionString isEqualToString:@"north"]) blob.travelDirection = WTTravelDirectionNorthbound;
    else if ([journeyDirectionString isEqualToString:@"south"]) blob.travelDirection = WTTravelDirectionSouthbound;
    else if ([journeyDirectionString isEqualToString:@"any"]) blob.travelDirection = WTTravelDirectionAny;
    else NSAssert(NO, @"Invalid journey direction string %@", journeyDirectionString);
    
    // Get days of the week on which content is valid
    NSNumber * dayMask = [dictionary objectForKey:@"dayMask"];
    blob.days = dayMask.intValue;
    
    // Which window to look out of for the inbound journey
    NSString * windowDirectionString = [[dictionary objectForKey:@"window"] lowercaseString];
    if (windowDirectionString==nil) blob.windowDirection = WTWindowDirectionEither;
    else if ([windowDirectionString isEqualToString:@"left"]) blob.windowDirection = WTWindowDirectionLeft;
    else if ([windowDirectionString isEqualToString:@"right"]) blob.windowDirection = WTWindowDirectionRight;
    else if ([windowDirectionString isEqualToString:@"either"]) blob.windowDirection = WTWindowDirectionEither;
    else NSAssert(NO, @"Invalid window direction string %@", windowDirectionString);

    NSString * timeOfDayString = [[dictionary objectForKey:@"Time of Day"] lowercaseString];
    if (timeOfDayString==nil) blob.timeOfDay = WTTimeOfDayAny;
    else if ([timeOfDayString isEqualToString:@"any"]) blob.timeOfDay = WTTimeOfDayAny;
    else if ([timeOfDayString isEqualToString:@"morning"]) blob.timeOfDay = WTTimeOfDayMorning;
    else if ([timeOfDayString isEqualToString:@"afternoon"]) blob.timeOfDay = WTTimeOfDayAfternoon;
    else if ([timeOfDayString isEqualToString:@"evening"]) blob.timeOfDay = WTTimeOfDayEvening;
    else NSAssert(NO, @"Invalid time of day string %@", timeOfDayString);
    
    NSString * latString = [[dictionary objectForKey:@"Lat"] lowercaseString];
    NSString * lonString = [[dictionary objectForKey:@"Lon"] lowercaseString];
    if ([lonString length]==0){
        NSLog(@"lonString=%@",lonString);
        NSLog(@"latString=%@",lonString);
        blob.coordinate = CLLocationCoordinate2DMake(NAN, NAN);
    }
    else{
        float lat = [latString floatValue];
        float lon = [lonString floatValue];
        blob.coordinate = CLLocationCoordinate2DMake(lat,lon);
    }
    
    
    
    //Valid journey segment
    NSNumber * journeySegmentNumber = [dictionary objectForKey:@"Phase of Journey"];
    if (journeySegmentNumber==nil) blob.journeySegment = WTJourneySegmentAny;
    else blob.journeySegment = (WTJourneySegment) journeySegmentNumber.intValue;
    
    
    if (!(CLLocationCoordinate2DIsValid(blob.coordinate) || blob.journeySegment>=0)){
        NSAssert(CLLocationCoordinate2DIsValid(blob.coordinate) || blob.journeySegment>=0, @"Bad blob");
    }
    
    NSLog(@"Got blob called %@ at segment %d",blob.title, blob.journeySegment);
    
    return blob;
}

@end
