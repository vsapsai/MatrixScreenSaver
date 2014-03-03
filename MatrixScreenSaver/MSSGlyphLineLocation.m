//
//  MSSGlyphLineLocation.m
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 3/3/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import "MSSGlyphLineLocation.h"

@implementation MSSGlyphLineLocation

- (instancetype)initWithRunIndex:(CFIndex)runIndex runGlyphIndex:(CFIndex)runGlyphIndex
{
    self = [super init];
    if (nil != self)
    {
        self.runIndex = runIndex;
        self.runGlyphIndex = runGlyphIndex;
    }
    return self;
}

@end
