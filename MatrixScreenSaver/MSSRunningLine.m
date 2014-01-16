//
//  MSSRunningLine.m
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/14/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import "MSSRunningLine.h"

#import <QuartzCore/CAGradientLayer.h>
#import <QuartzCore/CATextLayer.h>
#import <QuartzCore/CIFilter.h>

@interface MSSRunningLine()
@property (copy, nonatomic) NSString *string;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) CGFloat height;
@property (nonatomic) NSColor *color;

@property (nonatomic) CALayer *rootLayerPrimitive;
@property (nonatomic) CALayer *textLayer;
@end

@implementation MSSRunningLine

- (instancetype)initWithString:(NSString *)string fontSize:(CGFloat)fontSize height:(CGFloat)height color:(NSColor *)color
{
    NSParameterAssert(string.length > 0);
    NSParameterAssert(fontSize > 0);
    NSParameterAssert(height > 0);
    NSParameterAssert(nil != color);
    self = [super init];
    if (nil != self)
    {
        self.string = string;
        self.fontSize = fontSize;
        self.height = height;
        self.color = color;
        self.speed = 0.0;
    }
    return self;
}

- (CALayer *)rootLayer
{
    // rootLayer
    // |- textLayer
    //    |- gradientLayer
    if (nil == self.rootLayerPrimitive)
    {
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.string = [self _stringWithAttributes];
        CGSize textSize = [textLayer preferredFrameSize];
        CGFloat lineWidth = textSize.height;  // take height because text is vertical
        textLayer.anchorPoint = CGPointZero;
        textLayer.bounds = CGRectMake(0.0, 0.0, textSize.width, textSize.height);
        textLayer.position = CGPointMake(lineWidth, -textSize.width);
        textLayer.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
        self.textLayer = textLayer;

        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = textLayer.bounds;
        CGColorRef startColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.0);
        CGColorRef endColor = [self.color CGColor];
        gradientLayer.colors = @[(id)CFBridgingRelease(startColor), (__bridge id)endColor];
        gradientLayer.startPoint = CGPointMake(0.0, 0.5);
        gradientLayer.endPoint = CGPointMake(1.0, 0.5);
        CIFilter *filter = [CIFilter filterWithName:@"CISourceInCompositing"];
        gradientLayer.compositingFilter = filter;
        [textLayer addSublayer:gradientLayer];

        CALayer *rootLayer = [CALayer layer];
        rootLayer.frame = CGRectMake(0.0, 0.0, lineWidth, self.height);
        [rootLayer addSublayer:textLayer];
        self.rootLayerPrimitive = rootLayer;
    }
    return self.rootLayerPrimitive;
}

- (NSAttributedString *)_stringWithAttributes
{
    NSDictionary *attributes = @{
        NSForegroundColorAttributeName: self.color,
        NSFontAttributeName: [NSFont systemFontOfSize:self.fontSize],
        NSVerticalGlyphFormAttributeName: @(1)
    };
    return [[NSAttributedString alloc] initWithString:self.string attributes:attributes];
}

- (BOOL)isFinished
{
    return (self.textLayer.position.y >= self.height);
}

- (void)updateLinePosition:(NSTimeInterval)passedTime
{
    CGFloat movedDistance = passedTime * self.speed;
    CGPoint newPosition = self.textLayer.position;
    newPosition.y += movedDistance;
    self.textLayer.position = newPosition;
}

@end
