//
//  WTFirstViewController.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 27/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "L1MapViewController.h"
#import "WTStoryManager.h"

@interface WTMapViewController : UIViewController<MKMapViewDelegate>
{
    IBOutlet MKMapView * mapView;
    MKPointAnnotation * userLocation;
    MKAnnotationView * userLocationView;
    
}
-(IBAction)startJourney:(id)sender;
-(void) locationUpdate:(CLLocation *)location;

@end
