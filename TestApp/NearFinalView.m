//
//  NearFinalView.m
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/14/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import "NearFinalView.h"
#import "MSSLinesController.h"

@interface NearFinalView()
@property (nonatomic) MSSLinesController *linesController;
@property (nonatomic) NSTimer *animationTimer;
@property (nonatomic) NSDate *lastAnimationDate;
@end

@implementation NearFinalView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (nil != self)
    {
        self.linesController = [[MSSLinesController alloc] init];
        [self.linesController setupViewForDisplayingLines:self];

        self.layer.backgroundColor = [[NSColor blackColor] CGColor];

        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / 30.0) target:self selector:@selector(animateLines:) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)animateLines:(NSTimer *)timer
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

@end
