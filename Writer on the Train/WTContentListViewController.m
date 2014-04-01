//
//  WTContentListViewController.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 30/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import "WTContentListViewController.h"
#import "WTTabBarController.h"
#import "WTContentViewController.h"

@interface WTContentListViewController ()

@end


@implementation WTContentListViewController
@synthesize storyManager;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.storyManager = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    WTTabBarController * root = (WTTabBarController*) self.parentViewController;
    self.storyManager = root.storyManager;
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [contentTableListView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.storyManager contentCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString * title =[self.storyManager titleForContentAtIndex:indexPath.row];
    if ([title characterAtIndex:0]=='-'){
        title = [title substringFromIndex:1];
        cell.textLabel.textColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:0.7];
    }
    else{
        cell.textLabel.textColor = [UIColor blackColor];
        
    }
    cell.textLabel.text = title;

    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([storyManager contentAtIndexIsAvailable:indexPath.row]){
        WTContentBlob * blob = [storyManager contentAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"content-presentation-list" sender:blob];        
    }
}


#pragma mark - Navigation


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"content-presentation-list"]){
        WTContentViewController * destination = (WTContentViewController *) segue.destinationViewController;
        WTContentBlob * blob = (WTContentBlob*) sender;
        [destination setContentBlob:blob];
    }
}


@end
