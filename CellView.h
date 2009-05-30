#import <Cocoa/Cocoa.h>

@class Controller;

@interface CellView : NSView
{
    IBOutlet Controller *controller;

    float cellWidth;
    float cellHeight;

    NSInteger borderSize;

    // Colors
    NSColor *backgroundColor;
    NSColor *borderColor;
    NSColor *aliveColor;
    NSColor *deadColor;

    // Events
    int dragColumn;                               // Used to determine the last cell
    int dragRow;                                  // that was modified in a dragging operation

    BOOL dragCellStatus;                          // Used in dragging events to set the cells alive or dead
}

@property(readwrite, copy) NSColor *backgroundColor;
@property(readwrite, copy) NSColor *borderColor;
@property(readwrite, copy) NSColor *aliveColor;
@property(readwrite, copy) NSColor *deadColor;
@property(readwrite, assign) NSInteger borderSize;

@end
