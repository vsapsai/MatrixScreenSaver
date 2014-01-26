//
//  MSSScreenSaverView.m
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/14/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import "MSSScreenSaverView.h"
#import "MSSUniformLinesController.h"

@interface MSSScreenSaverView()
@property (nonatomic) MSSBaseLinesController *linesController;
@property (nonatomic) NSDate *lastAnimationDate;
@end

@implementation MSSScreenSaverView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (nil != self)
    {
        self.linesController = [[MSSUniformLinesController alloc] init];
        [self.linesController setupViewForDisplayingLines:self];
        self.layer.backgroundColor = [[NSColor blackColor] CGColor];

        [self setAnimationTimeInterval:1.0];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
    self.lastAnimationDate = [NSDate date];
}

- (void)stopAnimation
{
    [super stopAnimation];
    self.lastAnimationDate = nil;
}

- (void)animateOneFrame
{
    NSDate *currentDate = [NSDate date];
    NSDate *lastAnimationDate = self.lastAnimationDate;
    if (nil != lastAnimationDate)
    {
        NSTimeInterval passedTime = [currentDate timeIntervalSinceDate:lastAnimationDate];
        [self.linesController animateLines:passedTime];
    }
    self.lastAnimationDate = currentDate;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow *)configureSheet
{
    return nil;
}

@end
