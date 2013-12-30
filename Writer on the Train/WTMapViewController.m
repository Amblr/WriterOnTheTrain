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

@implementation WTMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    mapView.showsUserLocation = YES;
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    mapView.showsUserLocation = NO;
}


-(IBAction)startJourney:(id)sender
{
    WTTabBarController * root = (WTTabBarController*) self.parentViewController;
    WTStoryManager * storyManager = root.storyManager;
    [storyManager startJourney];

}



@end
