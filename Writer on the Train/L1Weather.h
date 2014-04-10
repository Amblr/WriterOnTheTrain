//
//  L1Weather.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 05/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;

@protocol L1WeatherDelegate <NSObject>

-(void) foundWeather:(NSString*) weather forCoordinate:(CLLocationCoordinate2D) coordinate;

@end

@interface L1Weather : NSObject
{
    id<L1WeatherDelegate> delegate;
    // Connection Object
    NSURLConnection * connection;
}

@property (retain) id<L1WeatherDelegate> delegate;
-(void) findWeatherAtCoordinates:(CLLocationCoordinate2D) coordinate;
@end
