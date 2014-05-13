//
//  WTLocationManager.m
//  
//
//  Created by Joe Zuntz on 05/04/2014.
//
//

#import "WTLocationManager.h"
#import "WTStoryManager.h"


@implementation WTLocationManager
-(id) initWithStoryManager:(id<WTLocationManagerDelegate>) manager
{
    self = [super init];
    if (self){
        storyManager = [manager retain];
    }
    
    return self;
}

-(void) startJourneyWithContent:(WTContentBlob *)content
{
    
}
-(void) endJourney
{
    
}

@end
