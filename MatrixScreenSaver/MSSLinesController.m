//
//  MSSLinesController.m
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/14/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import "MSSLinesController.h"
#import "MSSRunningLine.h"
#import <ScreenSaver/ScreenSaverView.h>

//TODO(vsapsai): support 2 kinds of running lines: one where all text moves and one where only focus moves.
//
// One of the variants:
// - all text of the same size, all screen can be taken by characters
// - lines are pretty long
// - no easily readable characters
// - characters don't move, only focus moves (looks like partially visible characters are impossible)
// - some characters inside a string can suddenly change

static const CGFloat kLinesDensity = 0.05;

@interface MSSLinesController()
@property (nonatomic) CGSize viewSize;
@property (nonatomic) NSUInteger desiredLinesCount;
@end

@implementation MSSLinesController

- (void)setupViewForDisplayingLines:(NSView *)view
{
    [super setupViewForDisplayingLines:view];
    self.viewSize = view.bounds.size;
    srandomdev();
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
            MSSRunningLine *line = [self _generateRunningLine];
            CGFloat xPosition = SSRandomIntBetween(0, self.viewSize.width);
            [self addLayer:[line rootLayer] atOrigin:CGPointMake(xPosition, 0.0)];
            [lines addObject:line];
        }
        self.lines = [lines copy];
    }
}

- (MSSRunningLine *)_generateRunningLine
{
    CGFloat layerHeight = self.viewSize.height;
    NSString *string = [self _generateString];
    CGFloat fontSize = SSRandomIntBetween(12, 42);
    MSSRunningLine *result = [[MSSRunningLine alloc] initWithString:string fontSize:fontSize height:layerHeight color:[NSColor greenColor]];
    result.speed = SSRandomFloatBetween(10.0, 100.0);
    return result;
}

- (NSString *)_generateString
{
    static NSString *sAllowedCharacters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSUInteger allowedCharactersCount = [sAllowedCharacters length];
    NSUInteger stringLength = SSRandomIntBetween(3, 15);
    NSMutableArray *characters = [NSMutableArray arrayWithCapacity:stringLength];
    for (int i = 0; i < stringLength; i++)
    {
        NSUInteger characterIndex = SSRandomIntBetween(0, (int)allowedCharactersCount - 1);
        [characters addObject:[sAllowedCharacters substringWithRange:NSMakeRange(characterIndex, 1)]];
    }
    return [characters componentsJoinedByString:@""];
}

@end
