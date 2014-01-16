//
//  MSSRunningFocusLine.m
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/16/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import "MSSRunningFocusLine.h"

#import <QuartzCore/CAGradientLayer.h>
#import <QuartzCore/CATextLayer.h>
#import <QuartzCore/CIFilter.h>

@interface MSSRunningFocusLine()
@property (copy, nonatomic) NSString *string;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) CGFloat focusHeight;
@property (nonatomic) NSColor *color;
@property (nonatomic) NSColor *hilightColor;
@property (nonatomic) NSColor *backgroundColor;

@property (nonatomic) CALayer *rootLayerPrimitive;
@property (nonatomic) CALayer *gradientLayer;
@end

@implementation MSSRunningFocusLine

@synthesize identifier;
@synthesize speed;

- (instancetype)initWithString:(NSString *)string fontSize:(CGFloat)fontSize focusHeight:(CGFloat)focusHeight color:(NSColor *)color hilightColor:(NSColor *)hilightColor backgroundColor:(NSColor *)backgroundColor
{
    NSParameterAssert(string.length > 0);
    NSParameterAssert(fontSize > 0);
    NSParameterAssert(focusHeight > 0);
    NSParameterAssert(nil != color);
    NSParameterAssert(nil != hilightColor);
    NSParameterAssert(nil != backgroundColor);
    self = [super init];
    if (nil != self)
    {
        self.string = string;
        self.fontSize = fontSize;
        self.focusHeight = focusHeight;
        self.color = color;
        self.hilightColor = hilightColor;
        self.backgroundColor = backgroundColor;
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
        textLayer.anchorPoint = CGPointZero;
        textLayer.bounds = CGRectMake(0.0, 0.0, textSize.width, textSize.height);
        textLayer.position = CGPointMake(textSize.height, 0.0);
        textLayer.affineTransform = CGAffineTransformMakeRotation(M_PI_2);

        CAGradientLayer *gradientLayer = [self _createGradientLayer];
        gradientLayer.anchorPoint = CGPointZero;
        gradientLayer.frame = CGRectMake(-self.focusHeight, 0.0, self.focusHeight, textSize.height);
        [textLayer addSublayer:gradientLayer];
        self.gradientLayer = gradientLayer;

        CALayer *rootLayer = [CALayer layer];
        rootLayer.frame = CGRectMake(0.0, 0.0, textSize.height, textSize.width);
        [rootLayer addSublayer:textLayer];
        self.rootLayerPrimitive = rootLayer;
    }
    return self.rootLayerPrimitive;
}

- (NSAttributedString *)_stringWithAttributes
{
    NSDictionary *attributes = @{
        NSForegroundColorAttributeName: self.backgroundColor,
        NSFontAttributeName: [NSFont systemFontOfSize:self.fontSize],
        NSVerticalGlyphFormAttributeName: @(1)
    };
    return [[NSAttributedString alloc] initWithString:self.string attributes:attributes];
}

- (CAGradientLayer *)_createGradientLayer
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    CGColorRef startColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.0);
    CGColorRef middleColor = [self.color CGColor];
    CGColorRef endColor = [self.hilightColor CGColor];
    gradientLayer.colors = @[(id)CFBridgingRelease(startColor), (__bridge id)middleColor, (__bridge id)middleColor, (__bridge id)endColor];
    gradientLayer.locations = @[@(0.0), @(0.6), @(0.9), @(1.0)];
    gradientLayer.startPoint = CGPointMake(0.0, 0.5);
    gradientLayer.endPoint = CGPointMake(1.0, 0.5);
    CIFilter *filter = [CIFilter filterWithName:@"CISourceInCompositing"];
    gradientLayer.compositingFilter = filter;
    return gradientLayer;
}

- (BOOL)isFinished
{
    return (self.gradientLayer.position.x >= self.rootLayerPrimitive.bounds.size.height);
}

- (void)updateLinePosition:(NSTimeInterval)passedTime
{
    CGFloat movedDistance = passedTime * self.speed;
    CGPoint newPosition = self.gradientLayer.position;
    newPosition.x += movedDistance;
    self.gradientLayer.position = newPosition;
}

@end
