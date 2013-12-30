//
//  WTUtils.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 30/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import "WTUtils.h"


WTDayOfWeek WTCurrentDayOfWeek()
{
    CFAbsoluteTime at = CFAbsoluteTimeGetCurrent();
    CFTimeZoneRef tz = CFTimeZoneCopySystem();
    SInt32 WeekdayNumber = CFAbsoluteTimeGetDayOfWeek(at, tz);
    return (WTDayOfWeek) 2>>(WeekdayNumber-1);
}


MKMapPoint WTMapPointDifference(MKMapPoint x1, MKMapPoint x2){
    MKMapPoint d = MKMapPointMake(x1.x-x2.x, x1.y-x2.y);
    return d;
}

double WTMapPointDotProduct(MKMapPoint x1, MKMapPoint x2){
    return x1.x*x2.x+x1.y*x2.y;
    
}
