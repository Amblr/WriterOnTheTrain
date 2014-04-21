//
//  WTHallmarkView.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 13/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTContentBlob;
@interface WTHallmarkView : UIView
{
    IBOutletCollection(UIImageView) NSArray * imageViews;
}
-(void) setContentBlob:(WTContentBlob*) blob;
@property (retain) NSArray * imageViews;
@end
