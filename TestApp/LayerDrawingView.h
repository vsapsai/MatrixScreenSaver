//
//  LayerDrawingView.h
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/13/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// WARNING: experimental code, don't use in production.
//
// Try to draw text with fade-out gradient using CALayer.  Try to move layers
// to achieve animation.
@interface LayerDrawingView : NSView
- (IBAction)animateGradient:(id)sender;
@end
