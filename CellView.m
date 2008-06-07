#import "CellView.h"
#import "Controller.h"

@implementation CellView

@synthesize backgroundColor;
@synthesize borderColor;
@synthesize aliveColor;
@synthesize deadColor;
@synthesize borderSize;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(NSRect)rect
{

    NSRect bounds = [self bounds];
    [[self backgroundColor] set];
    [NSBezierPath fillRect:bounds];

    int columns = [controller columns];
    int rows = [controller rows];
    cellWidth = ((bounds.size.width - (columns * [self borderSize])) / columns);
    cellHeight = ((bounds.size.height - (rows * [self borderSize])) / rows);

    // Draw Cells

    for(int colIndex = 0; colIndex < columns; colIndex++) {
        for(int rowIndex = 0; rowIndex < rows; rowIndex++) {

            switch ([controller cellAliveAtColumn:colIndex andRow:rowIndex]) {
                case YES:
                    [[self aliveColor] set];
                    break;
                case NO:
                    [[self deadColor] set];
                    break;
            }

            // Create the cell
            NSRect cell = NSMakeRect((colIndex * cellWidth) + (colIndex * [self borderSize]),
                (rowIndex * cellHeight) + (rowIndex * [self borderSize]),
                cellWidth,
                cellHeight);

            [NSBezierPath fillRect:cell];

            if((rowIndex % 5) == 0) {
                [NSBezierPath setDefaultLineWidth:[self borderSize]];
                [[self borderColor] set];
                NSPoint start = NSMakePoint(bounds.origin.y, (rowIndex * cellHeight) + (rowIndex * [self borderSize]));
                NSPoint finish = NSMakePoint(bounds.size.width, (rowIndex * cellHeight) + (rowIndex * [self borderSize]));
                [NSBezierPath strokeLineFromPoint:start toPoint:finish];
            }
        }
        if((colIndex % 5) == 0) {
            [NSBezierPath setDefaultLineWidth:[self borderSize]];
            [[self borderColor] set];
            NSPoint start = NSMakePoint((colIndex * cellWidth) + (colIndex * [self borderSize]), bounds.origin.x);
            NSPoint finish = NSMakePoint((colIndex * cellWidth) + (colIndex * [self borderSize]), bounds.size.height);
            [NSBezierPath strokeLineFromPoint:start toPoint:finish];
        }
    }
}

#pragma mark Events

- (void)mouseDown:(NSEvent *)event
{
    NSPoint p = [event locationInWindow];
    NSPoint downPoint = [self convertPoint:p fromView:nil];
    int column = downPoint.x / (cellWidth + [self borderSize]);
    int row = downPoint.y / (cellHeight + [self borderSize]);
    [controller toggleCellAtColumn:column andRow:row];

    // For drags we want to enable or disable, not toggle
    dragCellStatus = [controller cellAliveAtColumn:column andRow:row];

    [self setNeedsDisplay:TRUE];
}

- (void) mouseDragged:(NSEvent *)event
{
    NSPoint p = [event locationInWindow];
    NSPoint downPoint = [self convertPoint:p fromView:nil];
    int column = downPoint.x / (cellWidth + [self borderSize]);
    int row = downPoint.y / (cellHeight + [self borderSize]);

    if (column != dragColumn || row != dragRow) {
        [controller setCellAlive:dragCellStatus AtColumn:column andRow:row];
        [self setNeedsDisplay:TRUE];
    }

    dragColumn = column;
    dragRow = row;
}

@end
