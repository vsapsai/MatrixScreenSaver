//
//  MSSUniformLinesController.m
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/15/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import "MSSUniformLinesController.h"
#import "MSSRunningDiscreteFocusLine.h"
#import <ScreenSaver/ScreenSaverView.h>

// One of the variants:
// - all text of the same size, all screen can be taken by characters
// - lines are pretty long
// - no easily readable characters
// - characters don't move, only focus moves (looks like partially visible characters are impossible)
// - some characters inside a string can suddenly change

static const CGFloat kFontSize = 20.0;
static const CGFloat kLineStep = 25.0;
static const CGFloat kLineTextPadding = -15.0;
static const CGFloat kMinCharacterHeight = 16.0;
// How many of possible lines should be visible at the moment.
static const CGFloat kLinesPercentage = 0.9;

@interface MSSUniformLinesController()
@property (nonatomic) NSUInteger desiredLinesCount;
@property (nonatomic) CGFloat linesXOffset;
@property (nonatomic) NSMutableArray *availablePlaces;
@property (nonatomic) NSUInteger lineLength;
@end

@implementation MSSUniformLinesController

- (void)setupViewForDisplayingLines:(NSView *)view
{
    [super setupViewForDisplayingLines:view];
    NSUInteger linesCount = self.viewSize.width / kLineStep;
    CGFloat usedWidth = linesCount * kLineStep;
    CGFloat extraWidth = self.viewSize.width - usedWidth;
    self.linesXOffset = kLineTextPadding + extraWidth / 2.0;
    self.desiredLinesCount = linesCount * kLinesPercentage;
    NSMutableArray *availablePlaces = [NSMutableArray arrayWithCapacity:linesCount];
    for (NSUInteger i = 0; i < linesCount; i++)
    {
        [availablePlaces addObject:@(i)];
    }
    self.availablePlaces = availablePlaces;
    NSUInteger lineLength = ceil(self.viewSize.height / kMinCharacterHeight);
    if (0 == lineLength)
    {
        lineLength = 1;
    }
    self.lineLength = lineLength;
}

- (void)generateMoreLinesIfNeeded
{
    BOOL needMoreLines = ([self.lines count] < self.desiredLinesCount);
    BOOL canAddLine = (SSRandomFloatBetween(0.0, 10.0) < 1.0);
    if (needMoreLines && canAddLine)
    {
        NSInteger linesToAdd = 1;
        NSMutableArray *addedLines = [NSMutableArray arrayWithCapacity:linesToAdd];
        for (NSUInteger i = 0; i < linesToAdd; i++)
        {
            id<MSSRunningLine> line = [self _generateLine];
            [self _positionLineAtRandomPosition:line];
            [addedLines addObject:line];
        }
        self.lines = [self.lines arrayByAddingObjectsFromArray:addedLines];
    }
}

- (id<MSSRunningLine>)_generateLine
{
    static BOOL sIsInitialized = NO;
    static NSString *sAllowedCharacters = nil;
    static NSColor *sColor = nil;
    static NSColor *sHilightColor = nil;
    if (!sIsInitialized)
    {
        sAllowedCharacters = [[NSBundle bundleForClass:[MSSUniformLinesController class]] localizedStringForKey:@"Fancy Characters" value:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ" table:nil];
        sColor = [NSColor colorWithCalibratedRed:(16.0 / 255.0) green:(117.0 / 255.0) blue:(2.0 / 255.0) alpha:1.0];
        sHilightColor = [NSColor colorWithCalibratedRed:(150.0 / 255.0) green:(255.0 / 255.0) blue:(134.0 / 255.0) alpha:1.0];
        sIsInitialized = YES;
    }

    NSString *string = [self randomStringOfLength:self.lineLength fromCharacters:sAllowedCharacters];
    CGFloat focusHeight = kMinCharacterHeight * SSRandomIntBetween(5, (int)self.lineLength);
    id<MSSRunningLine> line = [[MSSRunningDiscreteFocusLine alloc] initWithString:string fontSize:kFontSize focusHeight:focusHeight color:sColor hilightColor:sHilightColor backgroundColor:[NSColor blackColor]];
    line.speed = SSRandomFloatBetween(50.0, 80.0);
    return line;
}

- (void)_positionLineAtRandomPosition:(id<MSSRunningLine>)line
{
    NSNumber *linePlace = [self _takeRandomObject:self.availablePlaces];
    line.identifier = linePlace;
    CGFloat xPosition = self.linesXOffset + [linePlace integerValue] * kLineStep;
    [self addLayer:[line rootLayer] atOrigin:CGPointMake(xPosition, 0.0)];
}

- (id)_takeRandomObject:(NSMutableArray *)objects
{
    NSParameterAssert([objects count] > 0);
    NSInteger objectIndex = SSRandomIntBetween(0, (int)[objects count] - 1);
    id result = [objects objectAtIndex:objectIndex];
    [objects removeObjectAtIndex:objectIndex];
    return result;
}

- (void)willRemoveLine:(id<MSSRunningLine>)line
{
    NSNumber *lineIdentifier = line.identifier;
    NSAssert(nil != lineIdentifier, @"Should have assigned identifier to a line when created it");
    NSAssert([lineIdentifier isKindOfClass:[NSNumber class]], @"Identifier should be NSNumber");
    [self.availablePlaces addObject:lineIdentifier];
}

@end
