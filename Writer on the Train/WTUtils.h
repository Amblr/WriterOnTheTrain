//
//  WTUtils.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 30/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTContentBlob.h"
@import MapKit;

WTDayOfWeek WTCurrentDayOfWeek();
MKMapPoint WTMapPointDifference(MKMapPoint x1, MKMapPoint x2);
double WTMapPointDotProduct(MKMapPoint x1, MKMapPoint x2);

