//
//  NSArray+NSArray_UIViewSorting.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 13/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (UIViewSorting)
- (NSArray*) sortByObjectTag;
- (NSArray*) sortByUIViewOriginX;
- (NSArray*) sortByUIViewOriginY;
@end
