//
//  MSSUniformLinesController.m
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/15/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import "MSSUniformLinesController.h"
#import "MSSRunningLine.h"
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
    NSInteger linesToAdd = self.desiredLinesCount - [self.lines count];
    if (linesToAdd > 0)
    {
        NSMutableArray *addedLines = [NSMutableArray arrayWithCapacity:linesToAdd];
        for (NSUInteger i = 0; i < linesToAdd; i++)
        {
            MSSRunningLine *line = [[MSSRunningLine alloc] initWithString:[self _generateString] fontSize:kFontSize height:self.viewSize.height color:[NSColor greenColor]];
            line.speed = SSRandomFloatBetween(50.0, 70.0);

            NSNumber *linePlace = [self _takeRandomObject:self.availablePlaces];
            line.identifier = linePlace;
            CGFloat xPosition = self.linesXOffset + [linePlace integerValue] * kLineStep;
            [self addLayer:[line rootLayer] atOrigin:CGPointMake(xPosition, 0.0)];
            [addedLines addObject:line];
        }
        self.lines = [self.lines arrayByAddingObjectsFromArray:addedLines];
    }
}

- (NSString *)_generateString
{
    static NSString *sAllowedCharacters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    return [self randomStringOfLength:self.lineLength fromCharacters:sAllowedCharacters];
}

- (id)_takeRandomObject:(NSMutableArray *)objects
{
    NSParameterAssert([objects count] > 0);
    NSInteger objectIndex = SSRandomIntBetween(0, (int)[objects count] - 1);
    id result = [objects objectAtIndex:objectIndex];
    [objects removeObjectAtIndex:objectIndex];
    return result;
}

- (void)willRemoveLine:(MSSRunningLine *)line
{
    NSNumber *lineIdentifier = line.identifier;
    NSAssert(nil != lineIdentifier, @"Should have assigned identifier to a line when created it");
    NSAssert([lineIdentifier isKindOfClass:[NSNumber class]], @"Identifier should be NSNumber");
    [self.availablePlaces addObject:lineIdentifier];
}

@end
