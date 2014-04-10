//
//  WTLocationManager.h
//  
//
//  Created by Joe Zuntz on 05/04/2014.
//
//
@class WTStoryManager;
@class CLLocation;



@protocol WTLocationManagerDelegate <NSObject>
- (void) locationUpdate:(CLLocation*) location;

@end

@interface WTLocationManager : NSObject
{
    id<WTLocationManagerDelegate> storyManager;

}
-(id) initWithStoryManager:(id<WTLocationManagerDelegate>) manager;
-(void) startJourney;
-(void) endJourney;

@end
