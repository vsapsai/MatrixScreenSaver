//
//  MSSRunningDiscreteFocusLine.h
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 3/1/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSSRunningLine.h"

@interface MSSRunningDiscreteFocusLine : NSObject <MSSRunningLine>

- (instancetype)initWithString:(NSString *)string fontSize:(CGFloat)fontSize focusHeight:(CGFloat)focusHeight color:(NSColor *)color hilightColor:(NSColor *)hilightColor backgroundColor:(NSColor *)backgroundColor;

@end
