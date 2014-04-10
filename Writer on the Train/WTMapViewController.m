//
//  WTFirstViewController.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 27/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import "WTMapViewController.h"
#import "WTTabBarController.h"
#import "WTStoryManager.h"


@interface WTMapViewController ()

@end


@interface L1PointAnnotation : MKPointAnnotation

@end


@implementation WTMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    userLocation = [[MKPointAnnotation  alloc] init];
    userLocation.coordinate = CLLocationCoordinate2DMake(NAN, NAN);
    userLocationView = [[MKAnnotationView alloc] initWithAnnotation:userLocation reuseIdentifier:@"user-location"];
#if (REAL_LOCATION)
    userLocationView.image = [UIImage imageNamed:@"real-user-location.png"];
#else
    userLocationView.image = [UIImage imageNamed:@"fake-user-location.png"];
#endif
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    WTTabBarController * root = (WTTabBarController*) self.parentViewController;
    root.mapViewController = self;
    [mapView addAnnotation:userLocation];
    

}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    mapView.showsUserLocation = YES;
}


-(IBAction)startJourney:(id)sender
{
    WTTabBarController * root = (WTTabBarController*) self.parentViewController;
    WTStoryManager * storyManager = root.storyManager;
    [storyManager startJourney];
}

-(MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation==userLocation){
        return userLocationView;
    }
    return nil;
}

-(void) locationUpdate:(CLLocation *)location
{
    NSLog(@"Location: %f  %f", location.coordinate.longitude, location.coordinate.latitude);
    if (CLLocationCoordinate2DIsValid(location.coordinate)) {
        [userLocation setCoordinate:location.coordinate];
    }
}




@end
