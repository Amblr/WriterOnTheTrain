//
//  WTIntroViewController.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 13/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import "WTIntroViewController.h"

@interface WTIntroViewController ()

@end

@implementation WTIntroViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)begin:(id)sender
{
    [self performSegueWithIdentifier:@"unwind-intro" sender:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
