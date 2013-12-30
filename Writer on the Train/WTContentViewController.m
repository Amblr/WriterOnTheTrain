//
//  WTContentViewController.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 29/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import "WTContentViewController.h"
#import "WTContentBlob.h"

@interface WTContentViewController ()

@end

@implementation WTContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    titleLabel.text = self.blob.title;
    textView.text = self.blob.text;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dismiss
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}



-(void) setContentBlob:(WTContentBlob*) blob
{
    self.blob = blob;
}

-(IBAction)dismissContentView
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

@end
