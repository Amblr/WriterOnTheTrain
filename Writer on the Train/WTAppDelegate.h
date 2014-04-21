//
//  WTAppDelegate.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 27/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTTabBarController;
@class WTStoryManager;

@interface WTAppDelegate : UIResponder <UIApplicationDelegate>
{
    WTTabBarController * tabBarController;
    WTStoryManager * storyManager;
}
@property (strong, nonatomic) UIWindow *window;
@property (retain) WTStoryManager * storyManager;
@end
