//
//  L1UserLocationAnnotation.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 04/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import "L1UserLocationAnnotation.h"

@implementation L1UserLocationAnnotation

-(id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self){
    }
    return self;
}

-(BOOL) realLocation
{
    return realLocation;
}

-(void) setRealLocation:(BOOL)realLocation_
{
    realLocation = realLocation_;
    if (realLocation) self.image = [UIImage imageNamed:@"real-user-location.png"];
    else self.image = [UIImage imageNamed:@"fake-user-location.png"];
}

@end
