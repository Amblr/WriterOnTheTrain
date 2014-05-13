//
//  WTLocationManager.h
//  
//
//  Created by Joe Zuntz on 05/04/2014.
//
//
@import CoreLocation;
@class WTStoryManager;
@class WTContentBlob;

@protocol WTLocationManagerDelegate <NSObject>
- (void) locationUpdate:(CLLocation*) location;

@end

@interface WTLocationManager : NSObject
{
    id<WTLocationManagerDelegate> storyManager;

}
-(id) initWithStoryManager:(id<WTLocationManagerDelegate>) manager;
-(void) startJourneyWithTargetCoordinate:(CLLocationCoordinate2D) coordinate;
-(void) endJourney;

@end
