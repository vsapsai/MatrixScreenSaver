//
//  MSSLinesController.m
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/14/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import "MSSLinesController.h"
#import "MSSRunningLine.h"

//TODO(vsapsai): support 2 kinds of running lines: one where all text moves and one where only focus moves.

@interface MSSLinesController()
@property (nonatomic) CALayer *hostLayer;
@property (nonatomic) NSArray *lines;
@end

@implementation MSSLinesController

- (void)setupViewForDisplayingLines:(NSView *)view
{
    NSParameterAssert(nil != view);
    [self _prepareView:view];
    //TODO(vsapsai): create lines
    CGFloat viewHeight = view.bounds.size.height;
    MSSRunningLine *line1 = [[MSSRunningLine alloc] initWithString:@"LINE" fontSize:16.0 height:viewHeight color:[NSColor greenColor]];
    line1.speed = 20.0;
    [self addLayer:[line1 rootLayer] atOrigin:CGPointMake(50.0, 0.0)];
    MSSRunningLine *line2 = [[MSSRunningLine alloc] initWithString:@"SAFHWEFSLKDF" fontSize:22.0 height:viewHeight color:[NSColor greenColor]];
    line2.speed = 30.0;
    [self addLayer:[line2 rootLayer] atOrigin:CGPointMake(123.0, 0.0)];
    self.lines = @[line1, line2];
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

- (void)animateLines:(NSTimeInterval)passedTime
{
    NSArray *lines = self.lines;
    for (MSSRunningLine *line in lines)
    {
        [line updateLinePosition:passedTime];
    }
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

@end
