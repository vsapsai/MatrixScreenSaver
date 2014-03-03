//
//  MSSGlyphLineLocation.h
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 3/3/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import <Foundation/Foundation.h>

// CTLineRef consists of CTRunRef which consists of glyphs.
// MSSGlyphLineLocation stores glyph location in a run and a line.
@interface MSSGlyphLineLocation : NSObject
@property (nonatomic) CFIndex runIndex;
@property (nonatomic) CFIndex runGlyphIndex;

- (instancetype)initWithRunIndex:(CFIndex)runIndex runGlyphIndex:(CFIndex)runGlyphIndex;
@end
