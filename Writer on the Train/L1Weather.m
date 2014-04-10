//
//  L1Weather.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 05/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import "L1Weather.h"

@implementation L1Weather
@synthesize delegate;


-(void) findWeatherAtCoordinates:(CLLocationCoordinate2D)coordinate
{
    //http://openweathermap.org/data/2.3/forecast/city?id=524901&APPID=1111111111
    NSString * urlString = @"";
    NSURL * url = [NSURL URLWithString:urlString];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    connection = [NSURLConnection connectionWithRequest:request delegate:self];
}


@end
