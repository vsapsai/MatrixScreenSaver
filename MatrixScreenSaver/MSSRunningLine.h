//
//  MSSRunningLine.h
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/16/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MSSRunningLine <NSObject>
@property (nonatomic) id identifier;
@property (readonly, nonatomic) CALayer *rootLayer;

// Animation-related.
@property (nonatomic) CGFloat speed;
@property (readonly, nonatomic, getter=isFinished) BOOL finished;
- (void)updateLinePosition:(NSTimeInterval)passedTime;
@end
