//
//  WTJourneyChooserController.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 29/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import "WTJourneyChooserController.h"
#import "L1Utils.h"
@import CoreLocation;
#import "WTStoryManager.h"
#import "WTTabBarController.h"



@interface WTJourneyChooserController ()

@end

@implementation WTJourneyChooserController

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
    // Load the list of statations from file
    // Form will be array of arrays ["name", lat, lon]
    stations = [[L1Utils arrayFromJsonFile:@"stations"] retain];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table Data Source

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Each table view has the same content in, just a list of stations, so just return the station count;
    return [stations count];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The same content goes in each cell too
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    NSArray * stationData = [stations objectAtIndex:indexPath.row];
    cell.textLabel.text = [stationData objectAtIndex:0];
    return cell;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * stationData = [stations objectAtIndex:indexPath.row];
    NSNumber * latitudeNumber = [stationData objectAtIndex:1];
    NSNumber * longitudeNumber = [stationData objectAtIndex:2];
    double longitude = [longitudeNumber doubleValue];
    double latitude = [latitudeNumber doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    WTTabBarController * root = (WTTabBarController*) self.parentViewController;
    WTStoryManager * storyManager = root.storyManager;
    if (tableView==homeStationLocation){
        storyManager.homeCoordinate = coordinate;
        NSLog(@"Set home station");
    }
    else if (tableView==workStationLocation){
        NSLog(@"Set work station");
        storyManager.workCoordinate = coordinate;
    }
}

@end
