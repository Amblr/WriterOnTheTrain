//
//  WTChapterTableViewCell.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 13/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTHallmarkView;
@class WTContentBlob;

@interface WTChapterTableViewCell : UITableViewCell
{
    IBOutlet UILabel * chapterLabel;
    WTHallmarkView * hallmarkView;
}
-(void) setContentBlob:(WTContentBlob*) blob;
-(void) setAvailable:(BOOL) available;
@end
