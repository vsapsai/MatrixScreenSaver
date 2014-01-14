//
//  LayerDrawingView.m
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/13/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import "LayerDrawingView.h"
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CATransaction.h>
#import <QuartzCore/CAGradientLayer.h>
#import <QuartzCore/CATextLayer.h>
#import <QuartzCore/CIFilter.h>

@interface LayerDrawingView()
@property (nonatomic) CALayer *animatedLayer;
@end

@implementation LayerDrawingView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (nil != self)
    {
        // Setup layer-hosting view.
        self.wantsLayer = YES;
        self.layer = [CALayer layer];
        self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
        self.layerUsesCoreImageFilters = YES;
        self.layer.backgroundColor = [[NSColor blackColor] CGColor];
        // Setup layers' hierarchy.
        CALayer *clippingLayer = [CALayer layer];
        clippingLayer.frame = CGRectMake(0.0, 0.0, 150.0, 150.0);
        clippingLayer.masksToBounds = YES;
        [self.layer addSublayer:clippingLayer];

        CALayer *gradientLayer = [self gradientLayer];
        CALayer *textLayer = [self textLayer];
        //[self addSublayer:textLayer toLayer:self.layer];
        [clippingLayer addSublayer:textLayer];
        //[self addSublayer:gradientLayer toLayer:textLayer];
        gradientLayer.frame = CGRectMake(0.0, 0.0, 50.0, 150.0);
        [textLayer addSublayer:gradientLayer];
        //gradientLayer.borderWidth = 1.0;
        gradientLayer.compositingFilter = [self createCompositingFilter];

        self.animatedLayer = gradientLayer;
    }
    return self;
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//	[super drawRect:dirtyRect];
//	
//    // Drawing code here.
//}

- (void)addSublayer:(CALayer *)layer toLayer:(CALayer *)superLayer
{
    layer.bounds = superLayer.bounds;
    layer.anchorPoint = CGPointMake(0.0, 0.0);
    layer.autoresizingMask = (kCALayerWidthSizable | kCALayerHeightSizable);
    [superLayer addSublayer:layer];
}

- (CALayer *)textLayer
{
    CATextLayer *layer = [CATextLayer layer];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"HelloMatrixhello" attributes:@{
        NSForegroundColorAttributeName: [NSColor blackColor],
        NSFontAttributeName: [NSFont systemFontOfSize:14.0],
        NSVerticalGlyphFormAttributeName: @(1)
    }];
    layer.string = string;

    //layer.borderWidth = 2.0;  // for debug

    layer.frame = CGRectMake(0.0, 0.0, 150.0, 150.0);
    layer.affineTransform = CGAffineTransformMakeRotation(-M_PI_2);

    return layer;
}

- (CALayer *)gradientLayer
{
    CAGradientLayer *layer = [CAGradientLayer layer];
    CGColorRef startColor = CGColorCreateGenericRGB(1.0, 0.5, 0.4, 0.0);
    CGColorRef endColor = CGColorCreateGenericRGB(0.0, 1.0, 0.0, 1.0);
    layer.colors = @[(id)CFBridgingRelease(startColor), (id)CFBridgingRelease(endColor)];
    layer.startPoint = CGPointMake(0.0, 0.5);
    layer.endPoint = CGPointMake(1.0, 0.5);
    return layer;
}

- (CIFilter *)createCompositingFilter
{
    CIFilter *filter = [CIFilter filterWithName:@"CISourceInCompositing"];
    [filter setDefaults];
    return filter;
}

#pragma mark Drawing

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    [self drawGradientInLayer:layer inContext:ctx];
}

// Maybe using CAGradientLayer is better idea.
- (void)drawGradientInLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 0.5, 0.4, 1.0,  // Start color
                              0.8, 0.8, 0.3, 1.0 }; // End color
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);

    CGRect bounds = layer.bounds;
    CGPoint fromPoint = bounds.origin;
    CGPoint toPoint = CGPointMake(fromPoint.x + bounds.size.width, fromPoint.y);
    CGContextDrawLinearGradient(ctx, gradient, fromPoint, toPoint, 0);

    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

//- (BOOL)wantsUpdateLayer
//{
//    return YES;
//}
//
//- (void)updateLayer
//{
//    //[self.layer setNeedsDisplay];
//}

#pragma mark - Action(s)

- (IBAction)animateGradient:(id)sender
{
    CGPoint oldPosition = self.animatedLayer.position;
    CGPoint newPosition = oldPosition;
    newPosition.x += 100.0;

#if 0
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithPoint:NSPointFromCGPoint(oldPosition)];
    animation.toValue = [NSValue valueWithPoint:NSPointFromCGPoint(newPosition)];
    animation.duration = 3.0;
    [self.animatedLayer addAnimation:animation forKey:@"position"];
    self.animatedLayer.position = newPosition;
#else
    //self.animatedLayer.speed = 0.05;
    [CATransaction begin];
    [CATransaction setAnimationDuration:5.0];
    self.animatedLayer.position = newPosition;
    [CATransaction commit];
#endif
}

@end
