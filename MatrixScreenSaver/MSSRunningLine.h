//
//  MSSRunningLine.h
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/14/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MSSRunningLine : NSObject
- (instancetype)initWithString:(NSString *)string fontSize:(CGFloat)fontSize height:(CGFloat)height color:(NSColor *)color;

- (CALayer *)rootLayer;

// Animation-related.
@property (nonatomic) CGFloat speed;
@property (readonly, nonatomic, getter=isFinished) BOOL finished;
- (void)updateLinePosition:(NSTimeInterval)passedTime;
@end
