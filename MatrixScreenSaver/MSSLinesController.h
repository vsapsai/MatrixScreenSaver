//
//  MSSLinesController.h
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/14/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSSLinesController : NSObject
- (void)setupViewForDisplayingLines:(NSView *)view;
- (void)animateLines:(NSTimeInterval)passedTime;
@end
