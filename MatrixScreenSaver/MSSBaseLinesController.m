//
//  MSSBaseLinesController.m
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/15/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import "MSSBaseLinesController.h"
#import "MSSRunningLine.h"
#import <QuartzCore/CATransaction.h>
#import <ScreenSaver/ScreenSaverView.h>

@interface MSSBaseLinesController()
@property (nonatomic) CALayer *hostLayer;
@end

@implementation MSSBaseLinesController

- (void)setupViewForDisplayingLines:(NSView *)view
{
    NSParameterAssert(nil != view);
    [self _prepareView:view];
    self.viewSize = view.bounds.size;
    srandomdev();
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

- (void)animateLines:(NSTimeInterval)passedTime
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    NSArray *lines = self.lines;
    for (MSSRunningLine *line in lines)
    {
        [line updateLinePosition:passedTime];
    }
    [CATransaction commit];

    [self _removeFinishedLines];
    [self generateMoreLinesIfNeeded];
}

- (void)_removeFinishedLines
{
    NSArray *lines = self.lines;
    NSMutableArray *liveLines = [NSMutableArray arrayWithCapacity:[lines count]];
    for (MSSRunningLine *line in lines)
    {
        if (line.finished)
        {
            [self willRemoveLine:line];
            [[line rootLayer] removeFromSuperlayer];
        }
        else
        {
            [liveLines addObject:line];
        }
    }
    self.lines = [liveLines copy];
}

- (void)addLayer:(CALayer *)layer atOrigin:(CGPoint)origin
{
    NSParameterAssert(nil != layer);
    CGSize boundsSize = layer.bounds.size;
    CGPoint anchorPoint = layer.anchorPoint;
    CGPoint newPosition = CGPointMake(origin.x + boundsSize.width * anchorPoint.x,
                                      origin.y + boundsSize.height * anchorPoint.y);
    layer.position = newPosition;
    [self.hostLayer addSublayer:layer];
}

- (NSString *)randomStringOfLength:(NSUInteger)length fromCharacters:(NSString *)characters
{
    if (0 == length)
    {
        return @"";
    }
    NSParameterAssert([characters length] > 0);
    int lastCharacterIndex = (int)[characters length] - 1;
    NSMutableArray *resultCharacters = [NSMutableArray arrayWithCapacity:length];
    for (NSInteger i = 0; i < length; i++)
    {
        NSUInteger characterIndex = SSRandomIntBetween(0, lastCharacterIndex);
        [resultCharacters addObject:[characters substringWithRange:NSMakeRange(characterIndex, 1)]];
    }
    return [resultCharacters componentsJoinedByString:@""];
}

- (void)generateMoreLinesIfNeeded
{
    NSAssert(@"Should implement %@ in subclasses", NSStringFromSelector(_cmd));
}

- (void)willRemoveLine:(MSSRunningLine *)line
{
    // Can be implemented in subclasses.
}

@end
