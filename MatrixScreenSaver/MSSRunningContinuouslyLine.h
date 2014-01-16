//
//  MSSRunningContinuouslyLine.h
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/14/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSSRunningLine.h"


@interface MSSRunningContinuouslyLine : NSObject <MSSRunningLine>
- (instancetype)initWithString:(NSString *)string fontSize:(CGFloat)fontSize height:(CGFloat)height color:(NSColor *)color;
@end
