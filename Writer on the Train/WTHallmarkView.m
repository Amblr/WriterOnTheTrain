//
//  WTHallmarkView.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 13/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import "WTHallmarkView.h"
#import "WTContentBlob.h"
#import "NSArray+UIViewSorting.h"

@implementation WTHallmarkView
@synthesize imageViews;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self=(WTHallmarkView*)[[[NSBundle mainBundle] loadNibNamed:@"WTHallmarkView" owner:nil options:nil] lastObject];
    }
    return self;
}

-(void) awakeFromNib
{
    [super awakeFromNib];
}

-(UIImage *)imageFromText:(NSString *)text
{
    // set the font type and size
    UIFont *font = [UIFont systemFontOfSize:14.0];
    CGSize size = {32,32};
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    else
        // iOS is < 4.0
        UIGraphicsBeginImageContext(size);
    
    // optional: add a shadow, to avoid clipping the shadow you should make the context size bigger
    //
    // CGContextRef ctx = UIGraphicsGetCurrentContext();
    // CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor grayColor] CGColor]);
    
    // draw in context, you can use also drawInRect:withFont:
    [text drawAtPoint:CGPointMake(0.0, 0.0) withFont:font];
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImage*) imageForTravelDirection:(WTTravelDirection) direction
{
    if (direction==WTTravelDirectionEastbound){
        return [self imageFromText:@"E"];
    }
    else if (direction==WTTravelDirectionWestbound){
        return [self imageFromText:@"W"];
    }
    else if (direction==WTTravelDirectionNorthbound){
        return [self imageFromText:@"N"];
    }
    else if (direction==WTTravelDirectionSouthbound){
        return [self imageFromText:@"S"];
    }
    return [UIImage imageNamed:@"HallmarkPlaceholder.png"];
}

-(UIImage*) imageForDayOfWeek:(WTDayOfWeek) dayOfWeek
{
    if (dayOfWeek==WTDayOfWeekMonday){
        return [self imageFromText:@"Mo"];
    }
    if (dayOfWeek==WTDayOfWeekTuesday){
        return [self imageFromText:@"Tu"];
    }
    if (dayOfWeek==WTDayOfWeekWednesday){
        return [self imageFromText:@"We"];
    }
    if (dayOfWeek==WTDayOfWeekThursday){
        return [self imageFromText:@"Th"];
    }
    if (dayOfWeek==WTDayOfWeekFriday){
        return [self imageFromText:@"Fr"];
    }
    if (dayOfWeek==WTDayOfWeekSaturday){
        return [self imageFromText:@"Sa"];
    }
    if (dayOfWeek==WTDayOfWeekSunday){
        return [self imageFromText:@"Su"];
    }

    return [UIImage imageNamed:@"HallmarkPlaceholder.png"];
}

-(UIImage*) imageForTimeOfDay:(WTTimeOfDay) timeOfDay
{
    if (timeOfDay==WTTimeOfDayMorning){
        return [self imageFromText:@"AM"];
    }
    if (timeOfDay==WTTimeOfDayAfternoon || timeOfDay==WTTimeOfDayEvening){
        return [self imageFromText:@"PM"];
    }

    return [UIImage imageNamed:@"HallmarkPlaceholder.png"];
}

-(UIImage*) imageForJourneySegment:(WTJourneySegment) segment
{
    NSString * string = [NSString stringWithFormat:@"%d",segment];
    return [self imageFromText:string];
}




-(void) setContentBlob:(WTContentBlob *)blob
{
    self.imageViews = [self.imageViews sortByUIViewOriginX];
    NSInteger pos=0;
    
    if (blob.travelDirection!=WTTravelDirectionAny){
        UIImageView *imageView = [imageViews objectAtIndex:pos];
        imageView.image = [self imageForTravelDirection:blob.travelDirection];
        pos++;
    }
    
    if (blob.timeOfDay!=WTTimeOfDayAny){
        UIImageView *imageView = [imageViews objectAtIndex:pos];
        imageView.image = [self imageForTimeOfDay:blob.timeOfDay];
        pos++;
    }
    
    if (blob.journeySegment!=WTJourneySegmentAny){
        UIImageView *imageView = [imageViews objectAtIndex:pos];
        imageView.image = [self imageForJourneySegment:blob.journeySegment];
        pos++;
    }
    
    if (blob.days!=WTDayOfWeekAny){
        if (blob.days==WTDayOfWeekWeekend){
            UIImageView *imageView = [imageViews objectAtIndex:pos];
            imageView.image = [self imageForDayOfWeek:WTDayOfWeekWeekend];
            pos++;
        }
        else {
            int days[7] = {WTDayOfWeekMonday, WTDayOfWeekTuesday, WTDayOfWeekWednesday, WTDayOfWeekThursday, WTDayOfWeekFriday, WTDayOfWeekSaturday, WTDayOfWeekSunday};
            for (int d=0;d<7; d++) {
                if (days[d] & blob.days){
                    if (pos>=[imageViews count]) return;
                    UIImageView *imageView = [imageViews objectAtIndex:pos];
                    imageView.image = [self imageForDayOfWeek:days[d]];
                    pos++;
                }
            }
        }
    }
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
