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
#import "MSSGlyphLineLocation.h"

static CGFloat MSSBlendValue(CGFloat fromValue, CGFloat toValue, CGFloat lambda);

@interface MSSRunningDiscreteFocusLine()
@property (copy, nonatomic) NSString *string;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) CGFloat focusHeight;
@property (nonatomic) NSColor *color;
@property (nonatomic) NSColor *hilightColor;
@property (nonatomic) NSColor *backgroundColor;

@property (nonatomic) CALayer *rootLayerPrimitive;
@property (nonatomic) CGFloat focusWindowStart;
@property (nonatomic) CTLineRef line;
@property (nonatomic) NSArray *characterLocations;  // array of MSSGlyphLineLocation
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
        self.focusWindowStart = 0.0;

        CTLineRef line = [self _createLineWithString:string fontSize:fontSize];
        NSAssert(NULL != line, @"Failed to create CTLineRef");
        NSAssert(CTLineGetGlyphCount(line) == string.length, @"Assume character-to-glyph 1-to-1 correspondence");
        self.line = line;
        // Here we make an assumption that characters and glyphs are the same.
        self.characterLocations = [self _glyphLocationsForLine:line];
    }
    return self;
}

- (void)dealloc
{
    CTLineRef line = self.line;
    if (NULL != line)
    {
        CFRelease(line);
        self.line = NULL;
    }
}

- (CTLineRef)_createLineWithString:(NSString *)string fontSize:(CGFloat)fontSize
{
    NSParameterAssert(string.length > 0);
    NSParameterAssert(fontSize > 0.0);
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:@{
        // Specify color, though it's overridden with CGContextSetRGBFillColor.
        // Without specifying color CGContextSetRGBFillColor won't take affect.
        NSForegroundColorAttributeName: [NSColor textColor],
        NSFontAttributeName: [NSFont systemFontOfSize:fontSize],
        NSVerticalGlyphFormAttributeName: @(1)
    }];
    return CTLineCreateWithAttributedString((CFAttributedStringRef)attributedString);
}

// All line glyphs are split into runs.  To draw a random glyph from line, we
// need to know which run it belongs to and glyph index within a run.
- (NSArray *)_glyphLocationsForLine:(CTLineRef)line
{
    NSParameterAssert(line);
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:CTLineGetGlyphCount(line)];
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runArray);
    for (CFIndex runIndex = 0; runIndex < runCount; runIndex++)
    {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
		CFIndex runGlyphCount = CTRunGetGlyphCount(run);
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < runGlyphCount; runGlyphIndex++)
        {
            [result addObject:[[MSSGlyphLineLocation alloc] initWithRunIndex:runIndex runGlyphIndex:runGlyphIndex]];
        }
    }
    return [result copy];
}

#pragma mark -

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
    CFArrayRef runArray = CTLineGetGlyphRuns(self.line);
    NSArray *characterLocations = self.characterLocations;
    // From focusWindowStart decide which glyphs to draw and glyph color.
    NSInteger startCharacterDiscreteIndex = floor(self.focusWindowStart / self.fontSize);
    NSInteger endCharacterDiscreteIndex = floor((self.focusWindowStart + self.focusHeight) / self.fontSize);
    CGFloat finalRed, finalGreen, finalBlue, finalAlpha;
    [self.color getRed:&finalRed green:&finalGreen blue:&finalBlue alpha:&finalAlpha];

    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGFloat layerHeight = layer.bounds.size.height;
    CGContextSetTextPosition(context, 10.0, layerHeight);
    for (NSInteger i = startCharacterDiscreteIndex; i <= endCharacterDiscreteIndex; i++)
    {
        CGFloat characterContinuousIndex = i * self.fontSize;
        // focusLambda takes value in a range [0.0, 1.0] and describes gradient measure.
        CGFloat focusLambda = (characterContinuousIndex - self.focusWindowStart) / self.focusHeight;
        CGContextSetRGBFillColor(context,
            MSSBlendValue(0.0, finalRed, focusLambda),
            MSSBlendValue(0.0, finalGreen, focusLambda),
            MSSBlendValue(0.0, finalBlue, focusLambda),
            MSSBlendValue(0.0, finalAlpha, focusLambda));
        MSSGlyphLineLocation *characterLocation = characterLocations[i];
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, characterLocation.runIndex);
        CTRunDraw(run, context, CFRangeMake(characterLocation.runGlyphIndex, 1));
    }
    CGContextRestoreGState(context);
}

- (void)drawEntireStringInLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    CFArrayRef runArray = CTLineGetGlyphRuns(self.line);
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
                MSSBlendValue(initialRed, finalRed, colorLambda),
                MSSBlendValue(initialGreen, finalGreen, colorLambda),
                MSSBlendValue(initialBlue, finalBlue, colorLambda),
                MSSBlendValue(initialAlpha, finalAlpha, colorLambda));
            CTRunDraw(run, context, CFRangeMake(runGlyphIndex, 1));
        }
        runsLength += runGlyphCount;
    }

    CGContextRestoreGState(context);
}

@end

static CGFloat MSSBlendValue(CGFloat fromValue, CGFloat toValue, CGFloat lambda)
{
    return lambda * toValue + (1.0 - lambda) * fromValue;
}
