//
//  L1UserLocationAnnotation.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 04/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface L1UserLocationAnnotation : MKAnnotationView
{
    BOOL realLocation;
}

@property (assign) BOOL realLocation;

@end
