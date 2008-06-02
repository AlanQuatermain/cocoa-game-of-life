#import <Cocoa/Cocoa.h>


@interface CellView : NSView {
    IBOutlet id controller;
    
    float cellWidth;
    float cellHeight;
    
    int dragColumn;
    int dragRow;
}

@end
