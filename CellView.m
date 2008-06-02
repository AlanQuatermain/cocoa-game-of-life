#import "CellView.h"
#import "Controller.h"

#define BORDER_WIDTH 1
#define BORDER whiteColor
#define BACKGROUND grayColor
#define CELL_ALIVE redColor
#define CELL_DEAD blackColor

@implementation CellView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    NSRect bounds = [self bounds];
    [[NSColor BACKGROUND] set];
    [NSBezierPath fillRect:bounds];
    
    int columns = [controller columns];
    int rows = [controller rows];
    cellWidth = ((bounds.size.width - (columns * BORDER_WIDTH)) / columns);
    cellHeight = ((bounds.size.height - (rows * BORDER_WIDTH)) / rows);
    
    // Draw Cells
    
    for(int colIndex = 0; colIndex < columns; colIndex++) {        
        for(int rowIndex = 0; rowIndex < rows; rowIndex++) {
            
            if([controller cellAliveAtColumn:colIndex andRow:rowIndex]) {
                [[NSColor CELL_ALIVE] set];
            } else {
                [[NSColor CELL_DEAD] set];
            }
            
            NSRect cell = NSMakeRect((colIndex * cellWidth) + (colIndex * BORDER_WIDTH), 
                                     (rowIndex * cellHeight) + (rowIndex * BORDER_WIDTH), 
                                     cellWidth, 
                                     cellHeight);
            
            [NSBezierPath fillRect:cell];
            
            if((rowIndex % 5) == 0) {
                [NSBezierPath setDefaultLineWidth:BORDER_WIDTH];
                [[NSColor BORDER] set];
                NSPoint start = NSMakePoint(bounds.origin.y, (rowIndex * cellHeight) + (rowIndex * BORDER_WIDTH));
                NSPoint finish = NSMakePoint(bounds.size.width, (rowIndex * cellHeight) + (rowIndex * BORDER_WIDTH));
                [NSBezierPath strokeLineFromPoint:start toPoint:finish];
            }
        }
        if((colIndex % 5) == 0) {
            [NSBezierPath setDefaultLineWidth:BORDER_WIDTH];
            [[NSColor BORDER] set];
            NSPoint start = NSMakePoint((colIndex * cellWidth) + (colIndex * BORDER_WIDTH), bounds.origin.x);
            NSPoint finish = NSMakePoint((colIndex * cellWidth) + (colIndex * BORDER_WIDTH), bounds.size.height);
            [NSBezierPath strokeLineFromPoint:start toPoint:finish];
        }
    }
}

#pragma mark Events

- (void)mouseDown:(NSEvent *)event {
    NSPoint p = [event locationInWindow];
    NSPoint downPoint = [self convertPoint:p fromView:nil];
    int column = downPoint.x / (cellWidth + BORDER_WIDTH);
    int row = downPoint.y / (cellHeight + BORDER_WIDTH);
    [controller toggleCellAtColumn:column andRow:row];
    [self setNeedsDisplay:TRUE];
}

- (void) mouseDragged:(NSEvent *)event {
    NSPoint p = [event locationInWindow];
    NSPoint downPoint = [self convertPoint:p fromView:nil];
    int column = downPoint.x / (cellWidth + BORDER_WIDTH);
    int row = downPoint.y / (cellHeight + BORDER_WIDTH);
    if (column != dragColumn || row != dragRow) {
        [controller toggleCellAtColumn:column andRow:row];
        [self setNeedsDisplay:TRUE];
    }
    dragColumn = column;
    dragRow = row;
}

@end
