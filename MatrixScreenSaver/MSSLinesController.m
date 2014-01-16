//
//  MSSLinesController.m
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/14/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import "MSSLinesController.h"
#import "MSSRunningContinuouslyLine.h"
#import <ScreenSaver/ScreenSaverView.h>

//TODO(vsapsai): support 2 kinds of running lines: one where all text moves and one where only focus moves.

static const CGFloat kLinesDensity = 0.05;

@interface MSSLinesController()
@property (nonatomic) NSUInteger desiredLinesCount;
@end

@implementation MSSLinesController

- (void)setupViewForDisplayingLines:(NSView *)view
{
    [super setupViewForDisplayingLines:view];
    NSInteger linesCount = view.bounds.size.width * kLinesDensity;
    if (linesCount < 1)
    {
        linesCount = 1;
    }
    self.desiredLinesCount = linesCount;
    // Desired number of lines will be created when we try to animate them.
}

- (void)generateMoreLinesIfNeeded
{
    if ([self.lines count] < self.desiredLinesCount)
    {
        NSMutableArray *lines = [self.lines mutableCopy];
        while ([lines count] < self.desiredLinesCount)
        {
            id<MSSRunningLine> line = [self _generateRunningLine];
            CGFloat xPosition = SSRandomIntBetween(0, self.viewSize.width);
            [self addLayer:[line rootLayer] atOrigin:CGPointMake(xPosition, 0.0)];
            [lines addObject:line];
        }
        self.lines = [lines copy];
    }
}

- (id<MSSRunningLine>)_generateRunningLine
{
    NSString *string = [self _generateString];
    CGFloat fontSize = SSRandomIntBetween(12, 42);
    id<MSSRunningLine> result = [[MSSRunningContinuouslyLine alloc] initWithString:string fontSize:fontSize height:self.viewSize.height color:[NSColor greenColor]];
    result.speed = SSRandomFloatBetween(10.0, 100.0);
    return result;
}

- (NSString *)_generateString
{
    static NSString *sAllowedCharacters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSUInteger stringLength = SSRandomIntBetween(3, 15);
    return [self randomStringOfLength:stringLength fromCharacters:sAllowedCharacters];
}

@end
