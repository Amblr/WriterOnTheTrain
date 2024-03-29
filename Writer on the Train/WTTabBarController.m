//
//  WTTabBarController.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 29/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import "WTTabBarController.h"
#import "WTContentViewController.h"
#import "WTContentBlob.h"
#import "WTStoryManager.h"
#import "WTMapViewController.h"

@interface WTTabBarController ()

@end

@implementation WTTabBarController
@synthesize storyManager;
@synthesize mapViewController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        shownIntro=NO;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (!shownIntro) self.view.hidden=YES;
    storyManager = [[WTStoryManager alloc] init];
    storyManager.delegate = self;
    self.delegate = self;

    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!shownIntro) self.view.hidden=YES;
    else self.view.hidden=NO;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!shownIntro) [self performSegueWithIdentifier:@"intro" sender:self];

}

- (IBAction)unwindIntroView:(UIStoryboardSegue *)unwindSegue
{
    shownIntro=YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"content-presentation"]){
        WTContentViewController * destination = (WTContentViewController *) segue.destinationViewController;
        WTContentBlob * blob = (WTContentBlob*) sender;
        [destination setContentBlob:blob];
        destination.buttonsVisible=YES;
    }
}


-(BOOL) displayContent:(WTContentBlob*) blob
{
    
    if ([[UIApplication sharedApplication] applicationState]==UIApplicationStateActive){
        [self performSegueWithIdentifier:@"content-presentation" sender:blob];
        return YES;
    }
    else{
        UILocalNotification * note =  [[UILocalNotification alloc] init];
        note.alertBody = @"You have reached a place in the written world.";
        note.alertAction = @"Experience";
        note.userInfo = [NSDictionary dictionaryWithObject:blob.chapter forKey:@"blob"];
        [[UIApplication sharedApplication] presentLocalNotificationNow:note];
        return NO;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Choose stations"]){
        self.selectedIndex = 1 ;
    }
}

-(void) chooseStationRequest
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Choose stations" message:@"Please choose your stations before starting your journey" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    alert.delegate = self;
    [alert show];
}

-(void) locationUpdate:(CLLocation *)location
{
    // Tell the map view to update location
    [mapViewController locationUpdate:location];
    
}

-(void) didStartJourney:(WTJourney *)journey
{
    
}

-(void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"Selected %@",viewController);
}

@end
