//
//  MSSBaseLinesController.h
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/15/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MSSRunningLine;

// `MSSBaseLinesController` is responsible for basic lines' management.  It
// should be subclassed to provide various lines' patterns.
@interface MSSBaseLinesController : NSObject
- (void)setupViewForDisplayingLines:(NSView *)view;
- (void)animateLines:(NSTimeInterval)passedTime;

// Intended to be used in subclasses only.
@property (nonatomic) NSArray *lines;
@property (nonatomic) CGSize viewSize;
- (void)addLayer:(CALayer *)layer atOrigin:(CGPoint)origin;
- (NSString *)randomStringOfLength:(NSUInteger)length fromCharacters:(NSString *)characters;
// Should be overridden in subclasses.
- (void)generateMoreLinesIfNeeded;
- (void)willRemoveLine:(id<MSSRunningLine>)line;
@end
