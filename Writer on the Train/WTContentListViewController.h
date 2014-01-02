//
//  WTContentListViewController.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 30/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTStoryManager;
@interface WTContentListViewController : UITableViewController
{
    WTStoryManager * storyManager;
    IBOutlet UITableView * contentTableListView;;
}
@property (retain) WTStoryManager * storyManager;
@end
