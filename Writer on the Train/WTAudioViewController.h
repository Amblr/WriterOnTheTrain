//
//  WTAudioViewController.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 06/05/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTContentBlob;

@interface WTAudioViewController : UIViewController
{
    WTContentBlob * blob;
}
-(IBAction)play:(id)sender;
@property (retain) WTContentBlob * blob;
@end
