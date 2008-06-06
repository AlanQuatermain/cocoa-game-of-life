#import <Cocoa/Cocoa.h>


@interface CellView : NSView {
    IBOutlet id controller;
    
    float cellWidth;
    float cellHeight;
    
	// Colors
	NSColor *backgroundColor;
	NSColor *borderColor;
	NSColor *aliveColor;
	NSColor *deadColor;
	
	// Events
    int dragColumn;
    int dragRow;
    bool dragCellStatus;
}

@property(readwrite, copy) NSColor *backgroundColor;
@property(readwrite, copy) NSColor *borderColor;
@property(readwrite, copy) NSColor *aliveColor;
@property(readwrite, copy) NSColor *deadColor;


@end
