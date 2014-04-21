//
//  WTChapterTableViewCell.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 13/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import "WTChapterTableViewCell.h"
#import "WTContentBlob.h"
#import "WTHallmarkView.h"

@implementation WTChapterTableViewCell

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self){

        self=(WTChapterTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"WTChapterTableViewCell" owner:nil options:nil] lastObject];

        hallmarkView = [[WTHallmarkView alloc] initWithFrame:CGRectMake(2, 12, 256, 32)];
        [self.contentView addSubview:hallmarkView];
        hallmarkView.frame = CGRectMake(24, 36, 256, 32);
    }
    return self;
}
- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
//    [self addSubview:hallmarkView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setContentBlob:(WTContentBlob*) blob
{
    chapterLabel.text = blob.title;
    [hallmarkView setContentBlob:blob];
}

-(void) setAvailable:(BOOL)available
{
    if (available) {
        chapterLabel.textColor = [UIColor blackColor];
        hallmarkView.alpha = 1.0;
    }
    else{
        chapterLabel.textColor = [UIColor lightGrayColor];
        hallmarkView.alpha = 0.3;
    }
    
}
@end
