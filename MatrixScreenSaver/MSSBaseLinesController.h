//
//  MSSBaseLinesController.h
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/15/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import <Foundation/Foundation.h>

// `MSSBaseLinesController` is responsible for basic lines' management.  It should be subclassed to provide various lines' patterns.
@interface MSSBaseLinesController : NSObject
- (void)setupViewForDisplayingLines:(NSView *)view;
- (void)animateLines:(NSTimeInterval)passedTime;

// Intended for subclasses.
@property (nonatomic) NSArray *lines;
- (void)addLayer:(CALayer *)layer atOrigin:(CGPoint)origin;
// Should be overridden in subclasses.
- (void)generateMoreLinesIfNeeded;
@end
