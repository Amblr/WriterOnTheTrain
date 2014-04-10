//
//  WTJourney.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 30/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import "WTJourney.h"
#import "WTUtils.h"

@implementation WTJourney
@synthesize journeyStartTime;
@synthesize journeyStart;
@synthesize journeyEnd;
@synthesize journeySegment;
@synthesize travelDirection;


-(id) init
{
    self = [super init];
    if (self){
        self.journeyStartTime = [NSDate date];
        self.journeySegment = WTJourneySegmentAny;
        self.travelDirection = WTTravelDirectionAny;
    }
    return self;
    
}

+(WTJourney*) journey
{
    WTJourney * journey = [[WTJourney alloc] init];
    return [journey autorelease];
}

-(void) startJourney
{
    // Start location behaviour
    // Some parameters about our journey
    self.journeyStartTime = [NSDate date];
    currentDayOfWeek = WTCurrentDayOfWeek();
    
    // Set direction of travel.
    // Work it out by which station is nearer.  We indicate that we do not know the
    // travel direction yet by setting it to "any".
    // then the first location update will set it
    travelDirection = WTTravelDirectionAny;
}


-(void) determineJourneySegment:(CLLocationCoordinate2D) coordinate
{
    // Draw a straight line between the journey start and end points
    // and work out the nearest point on the line to the coordinate
    // The dot product being zero does this most easily.
    // Do this on the tangent plane (flat approximation; should be okay as we only
    // need an approx solution.
    
    MKMapPoint x0 = MKMapPointForCoordinate(coordinate);
    MKMapPoint x1 = MKMapPointForCoordinate(journeyStart);
    MKMapPoint x2 = MKMapPointForCoordinate(journeyEnd);
    MKMapPoint travelledVector = WTMapPointDifference(x1,x0);
    MKMapPoint journeyVector = WTMapPointDifference(x2,x1);
    
    double travelledDistance = sqrt(travelledVector.x*travelledVector.x+travelledVector.y*travelledVector.y);
    double journeyDistance = sqrt(journeyVector.x*journeyVector.x+journeyVector.y*journeyVector.y);
    
    double fraction = travelledDistance/journeyDistance;
    WTJourneySegment newJourneySegment = (WTJourneySegment) (fraction*WTNumberOfJourneySegments);
    if (newJourneySegment<0) newJourneySegment=0;
    if (newJourneySegment>WTNumberOfJourneySegments) newJourneySegment=WTNumberOfJourneySegments;
    if (newJourneySegment!=journeySegment) {
        NSLog(@"Moved to journey segment %d",newJourneySegment);
    }
    journeySegment=newJourneySegment;
}

-(void) determineJourneyDirectionFromCoordinate:(CLLocationCoordinate2D) coordinate home:(CLLocationCoordinate2D) homeCoordinate work:(CLLocationCoordinate2D) workCoordinate;
{
    // Get distance of start and end from this coordinate and the start and end points
    
    CLLocation *homeLocation = [[CLLocation alloc] initWithCoordinate: homeCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil];
    CLLocation *workLocation = [[CLLocation alloc] initWithCoordinate: workCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil];
    CLLocation *location = [[CLLocation alloc] initWithCoordinate: coordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil];
    
    CLLocationDistance distanceFromHome = [homeLocation distanceFromLocation:location];
    CLLocationDistance distanceFromWork = [workLocation distanceFromLocation:location];
    
    travelDirection = (distanceFromHome<distanceFromWork) ? WTTravelDirectionEastbound : WTTravelDirectionWestbound;
    
    if (travelDirection==WTTravelDirectionEastbound) {
        journeyStart = homeCoordinate;
        journeyEnd = workCoordinate;
    }
    else if (travelDirection==WTTravelDirectionWestbound) {
        journeyStart = workCoordinate;
        journeyEnd = homeCoordinate;
    }
    
}


@end
