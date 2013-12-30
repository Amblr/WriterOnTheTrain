//
//  WTTabBarController.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 29/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTStoryManager.h"

@interface WTTabBarController : UITabBarController<WTStoryManagerDelegate>
{
    WTStoryManager * storyManager;
}
@property (retain) WTStoryManager * storyManager;
@end
