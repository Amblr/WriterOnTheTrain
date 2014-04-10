//
//  WTLocationManager.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 05/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "WTLocationManager.h"

@class WTStoryManager;


@interface WTRealLocationManager : WTLocationManager<CLLocationManagerDelegate>
{
    CLLocationManager * locationManager;
    NSTimeInterval highResolutionLocationInterval;
    BOOL inHighResolutionRegion;
    NSTimer * timer;
}
@end
