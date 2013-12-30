//
//  WTContentViewController.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 29/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WTContentBlob;
@interface WTContentViewController : UIViewController
{
    IBOutlet UILabel * titleLabel;
    IBOutlet UITextView * textView;
    WTContentBlob * _blob;
}

-(void) setContentBlob:(WTContentBlob*) blob;
-(IBAction)dismissContentView;
@property (retain) WTContentBlob * blob;
@end
