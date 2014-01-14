//
//  CompositingOperationView.m
//  MatrixScreenSaver
//
//  Created by Volodymyr Sapsai on 1/12/14.
//  Copyright (c) 2014 Volodymyr Sapsai. All rights reserved.
//

#import "CompositingOperationView.h"

@interface CompositingOperationView()
@property (nonatomic) NSImage *backgroundImage;
@property (nonatomic) NSImage *foregroundImage;
@property (nonatomic) NSImage *resultImage;
@end

static NSRect sImageRect = {0.0, 0.0, 480.0, 360.0};

@implementation CompositingOperationView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (nil != self)
    {
        // Initialization code here.
#if 1
        self.backgroundImage = [NSImage imageWithSize:sImageRect.size flipped:NO drawingHandler:^BOOL(NSRect dstRect)
        {
            NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor greenColor]
                                                                 endingColor:[[NSColor blackColor] colorWithAlphaComponent:0.]];
            [gradient drawInRect:dstRect angle:90.0];
            return YES;
        }];
        self.foregroundImage = [NSImage imageWithSize:sImageRect.size flipped:NO drawingHandler:^BOOL(NSRect dstRect)
        {
            //NSString *string = @"Hello Matrix";
            NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"H\ne\nl\nl\no\nM\na\nt\nr\ni\nx\nH\ne\nl\nl\no\nM\na\nt\nr\ni\nx" attributes:@{
                                                                                                                 NSForegroundColorAttributeName: [NSColor greenColor],
                                                                                                                 NSVerticalGlyphFormAttributeName: @(1)
                                                                                                                 }];
            //[string drawInRect:dstRect withAttributes:];
            //[string drawInRect:dstRect];
            [string drawAtPoint:NSZeroPoint];
            return YES;
        }];
#elif 1
        self.backgroundImage = [NSImage imageWithSize:sImageRect.size flipped:NO drawingHandler:^BOOL(NSRect dstRect)
        {
            NSBezierPath *path = [NSBezierPath bezierPath];

            [path moveToPoint:NSMakePoint(dstRect.size.width, 0.0)];
            [path lineToPoint:NSMakePoint(dstRect.size.width, dstRect.size.height)];
            [path lineToPoint:NSMakePoint(0.0, dstRect.size.height)];
            [path closePath];

            [[NSColor blueColor] set];
            [path fill];
            return YES;
        }];
        self.foregroundImage = [NSImage imageWithSize:sImageRect.size flipped:NO drawingHandler:^BOOL(NSRect dstRect)
        {
            NSBezierPath *path = [NSBezierPath bezierPath];

            [path moveToPoint:NSMakePoint(0.0, 0.0)];
            [path lineToPoint:NSMakePoint(0.0, dstRect.size.height)];
            [path lineToPoint:NSMakePoint(dstRect.size.width, dstRect.size.height)];
            [path closePath];

            [[NSColor redColor] set];
            [path fill];
            return YES;
        }];
#else
        self.backgroundImage = [[NSImage alloc] initWithSize:sImageRect.size];
        [self.backgroundImage addRepresentation:[[NSCustomImageRep alloc] initWithDrawSelector:@selector(drawBackground:) delegate:self]];
        self.foregroundImage = [[NSImage alloc] initWithSize:sImageRect.size];
        [self.foregroundImage addRepresentation:[[NSCustomImageRep alloc] initWithDrawSelector:@selector(drawForeground:) delegate:self]];
        self.resultImage = [[NSImage alloc] initWithSize:sImageRect.size];
        [self.resultImage addRepresentation:[[NSCustomImageRep alloc] initWithDrawSelector:@selector(drawResult:) delegate:self]];
#endif
        self.resultImage = [NSImage imageWithSize:sImageRect.size flipped:NO drawingHandler:^BOOL(NSRect dstRect)
        {
            [self.backgroundImage drawAtPoint:NSZeroPoint fromRect:dstRect operation:NSCompositeCopy fraction:1.0];
            [self.foregroundImage drawAtPoint:NSZeroPoint fromRect:dstRect operation:NSCompositeDestinationIn fraction:1.0];
            return YES;
        }];
    }
    return self;
}

- (void)drawBackground:(NSImageRep *)imageRep
{
    NSBezierPath *path = [NSBezierPath bezierPath];

    [path moveToPoint:NSMakePoint(sImageRect.size.width, 0.0)];
    [path lineToPoint:NSMakePoint(sImageRect.size.width, sImageRect.size.height)];
    [path lineToPoint:NSMakePoint(0.0, sImageRect.size.height)];
    [path closePath];

    [[NSColor blueColor] set];
    [path fill];
}

- (void)drawForeground:(NSImageRep *)imageRep
{
    NSBezierPath *path = [NSBezierPath bezierPath];

    [path moveToPoint:NSMakePoint(0.0, 0.0)];
    [path lineToPoint:NSMakePoint(0.0, sImageRect.size.height)];
    [path lineToPoint:NSMakePoint(sImageRect.size.width, sImageRect.size.height)];
    [path closePath];

    [[NSColor redColor] set];
    [path fill];
}

- (NSRect)imageRect:(NSImage *)image
{
    NSParameterAssert(image);
    NSSize size = image.size;
    return NSMakeRect(0.0, 0.0, size.width, size.height);
}

- (void)drawResult:(NSImageRep *)imageRep
{
    [self.backgroundImage drawAtPoint:NSZeroPoint fromRect:sImageRect operation:NSCompositeCopy fraction:1.0];
    [self.foregroundImage drawAtPoint:NSZeroPoint fromRect:sImageRect operation:NSCompositeSourceIn fraction:1.0];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [NSGraphicsContext saveGraphicsState];

    [[NSColor blackColor] set];
    NSRectFill(self.bounds);

    [self.resultImage drawInRect:self.bounds fromRect:sImageRect operation:NSCompositeSourceOver fraction:1.0];

    [NSGraphicsContext restoreGraphicsState];
}

@end
