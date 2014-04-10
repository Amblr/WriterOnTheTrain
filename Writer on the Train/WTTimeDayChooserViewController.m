//
//  WTTimeDayChooserViewController.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 09/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import "WTTimeDayChooserViewController.h"
#import "WTTabBarController.h"


@interface WTTimeDayChooserViewController ()

@end

@implementation WTTimeDayChooserViewController

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)chooseDateTime:(id)sender
{
    UIDatePicker * picker = (UIDatePicker*) sender;
    WTTabBarController * root = (WTTabBarController*) self.parentViewController;
    WTStoryManager * story = root.storyManager;
    story.fakeDate = picker.date;
}

@end
