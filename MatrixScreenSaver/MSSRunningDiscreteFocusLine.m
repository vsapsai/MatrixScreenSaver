//
//  MSSRunningDiscreteFocusLine.m
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 3/1/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import "MSSRunningDiscreteFocusLine.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/CALayer.h>

@interface MSSRunningDiscreteFocusLine()
@property (copy, nonatomic) NSString *string;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) CGFloat focusHeight;
@property (nonatomic) NSColor *color;
@property (nonatomic) NSColor *hilightColor;
@property (nonatomic) NSColor *backgroundColor;

@property (nonatomic) CALayer *rootLayerPrimitive;
@end

@implementation MSSRunningDiscreteFocusLine

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
    if (nil == self.rootLayerPrimitive)
    {
        CALayer *rootLayer = [CALayer layer];
        rootLayer.frame = CGRectMake(0.0, 0.0, 25.0, self.fontSize * [self.string length]);
        rootLayer.backgroundColor = [self.backgroundColor CGColor];
        rootLayer.geometryFlipped = YES;
        rootLayer.delegate = self;
        [rootLayer setNeedsDisplay];
        self.rootLayerPrimitive = rootLayer;
    }
    return self.rootLayerPrimitive;
}

- (BOOL)isFinished
{
    return NO;
}

- (void)updateLinePosition:(NSTimeInterval)passedTime
{
    // do nothing
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:self.string attributes:@{
        NSForegroundColorAttributeName: self.color,
        NSFontAttributeName: [NSFont systemFontOfSize:self.fontSize],
        NSVerticalGlyphFormAttributeName: @(1)
    }];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)string);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
	CFIndex runCount = CFArrayGetCount(runArray);

    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGFloat layerHeight = layer.bounds.size.height;
    CGContextSetTextPosition(context, 10.0, layerHeight);
    CGFloat initialRed = 0.0, initialGreen = 0.0, initialBlue = 0.0, initialAlpha = 0.0;
    CGFloat finalRed, finalGreen, finalBlue, finalAlpha;
    [self.color getRed:&finalRed green:&finalGreen blue:&finalBlue alpha:&finalAlpha];

    CFIndex runsLength = 0;
    for (CFIndex runIndex = 0; runIndex < runCount; runIndex++)
    {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
		CFIndex runGlyphCount = CTRunGetGlyphCount(run);
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < runGlyphCount; runGlyphIndex++)
        {
            CFIndex glyphIndex = runsLength + runGlyphIndex;
            CGFloat colorLambda = (CGFloat)glyphIndex / [self.string length];
            CGContextSetRGBFillColor(context,
                colorLambda * finalRed + (1.0 - colorLambda) * initialRed,
                colorLambda * finalGreen + (1.0 - colorLambda) * initialGreen,
                colorLambda * finalBlue + (1.0 - colorLambda) * initialBlue,
                colorLambda * finalAlpha + (1.0 - colorLambda) * initialAlpha);
            CTRunDraw(run, context, CFRangeMake(runGlyphIndex, 1));
        }
        runsLength += runGlyphCount;
    }

    CGContextRestoreGState(context);
    CFRelease(line);
}

@end
