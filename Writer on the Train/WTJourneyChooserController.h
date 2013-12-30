//
//  WTJourneyChooserController.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 29/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTJourneyChooserController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView * homeStationLocation;
    IBOutlet UITableView * workStationLocation;
    NSArray * stations;
    
    
}
@end
