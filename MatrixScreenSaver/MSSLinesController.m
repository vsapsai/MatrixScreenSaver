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

static const CGFloat kLinesDensity = 0.05;

@interface MSSLinesController()
@property (nonatomic) CALayer *hostLayer;
@property (nonatomic) NSArray *lines;
@property (nonatomic) NSUInteger desiredLinesCount;
@end

@implementation MSSLinesController

- (void)setupViewForDisplayingLines:(NSView *)view
{
    NSParameterAssert(nil != view);
    [self _prepareView:view];
    srandomdev();
    NSInteger linesCount = view.bounds.size.width * kLinesDensity;
    if (linesCount < 1)
    {
        linesCount = 1;
    }
    self.desiredLinesCount = linesCount;
    // Desired number of lines will be created when we try to animate them.
}

- (void)_prepareView:(NSView *)view
{
    NSParameterAssert(nil != view);
    view.wantsLayer = YES;
    view.layer = [CALayer layer];
    view.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    view.layerUsesCoreImageFilters = YES;
    // Make sure we use flipped geometry.  Lines start running from the top, so
    // it is more convenient to have 0 at the top.
    if (![view isFlipped])
    {
        CALayer *hostLayer = [CALayer layer];
        hostLayer.frame = view.layer.bounds;
        hostLayer.geometryFlipped = YES;
        [view.layer addSublayer:hostLayer];
        self.hostLayer = hostLayer;
    }
    else
    {
        self.hostLayer = view.layer;
    }
}

- (void)_addLayer:(CALayer *)layer atOrigin:(CGPoint)origin
{
    NSParameterAssert(nil != layer);
    CGSize boundsSize = layer.bounds.size;
    CGPoint anchorPoint = layer.anchorPoint;
    CGPoint newPosition = CGPointMake(origin.x + boundsSize.width * anchorPoint.x,
                                      origin.y + boundsSize.height * anchorPoint.y);
    layer.position = newPosition;
    [self.hostLayer addSublayer:layer];
}

- (MSSRunningLine *)_generateRunningLine
{
    CGFloat layerHeight = self.hostLayer.bounds.size.height;
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

- (void)animateLines:(NSTimeInterval)passedTime
{
    NSArray *lines = self.lines;
    for (MSSRunningLine *line in lines)
    {
        [line updateLinePosition:passedTime];
    }
    [self _removeFinishedLines];
    [self _addLinesToDesiredCount];
}

- (void)_removeFinishedLines
{
    NSArray *lines = self.lines;
    NSMutableArray *liveLines = [NSMutableArray arrayWithCapacity:[lines count]];
    for (MSSRunningLine *line in lines)
    {
        if (line.finished)
        {
            [[line rootLayer] removeFromSuperlayer];
        }
        else
        {
            [liveLines addObject:line];
        }
    }
    self.lines = [liveLines copy];
}

- (void)_addLinesToDesiredCount
{
    if ([self.lines count] < self.desiredLinesCount)
    {
        NSMutableArray *lines = [self.lines mutableCopy];
        while ([lines count] < self.desiredLinesCount)
        {
            MSSRunningLine *line = [self _generateRunningLine];
            CGFloat xPosition = SSRandomIntBetween(0, self.hostLayer.bounds.size.width);
            [self _addLayer:[line rootLayer] atOrigin:CGPointMake(xPosition, 0.0)];
            [lines addObject:line];
        }
        self.lines = [lines copy];
    }
}

@end
