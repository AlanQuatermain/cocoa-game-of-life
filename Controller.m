#import "Controller.h"

#define GRID_SIZE 40
#define UPDATE_SPEED -1.5

@implementation Controller

@synthesize columns;
@synthesize rows;
@synthesize cells;

- (void)awakeFromNib {
    [NSApp setDelegate:self];
    [speed setFloatValue:updateSpeed];
    [size setIntValue:rows];
}

-(id)init {
    [super init];
    
    updateSpeed = UPDATE_SPEED;
    [self setRows:GRID_SIZE];
    [self setColumns:GRID_SIZE];
    
    cells = [[NSMutableArray alloc] initWithCapacity:columns];
    
   for(int colIndex = 0; colIndex < columns; colIndex++) {
       NSMutableArray *row = [NSMutableArray arrayWithCapacity:rows];
       
       for(int rowIndex = 0; rowIndex < rows; rowIndex++) {
           [row insertObject:[[Cell alloc] init] atIndex:rowIndex];
       }
       [cells insertObject:row atIndex:colIndex];
    }
    
    return self;
}

- (Cell *)cellAtColumn:(int)colKey andRow:(int)rowKey {
    if((colKey < 0 || colKey >= [self columns]) || (rowKey < 0 || rowKey >= [self rows]))
        return nil;
    return [[cells objectAtIndex:colKey] objectAtIndex:rowKey];
}

- (void)setCell:(Cell *)aCell atColumn:(int)colKey andRow:(int)rowKey {
    NSMutableArray *column = [cells objectAtIndex:colKey];
    [column replaceObjectAtIndex:rowKey withObject:aCell];
    [cells replaceObjectAtIndex:colKey withObject:column];
}

- (bool)cellAliveAtColumn:(int)colKey andRow:(int)rowKey {
    return [[self cellAtColumn:colKey andRow:rowKey] alive];
}

- (void)toggleCellAtColumn:(int)colKey andRow:(int)rowKey {
    [[self cellAtColumn:colKey andRow:rowKey] toggle];
}

- (int)findNeighboursForCellAtColumn:(int)colKey andRow:(int)rowKey {
    int total = 0;
    
    // Row Above
    if([self cellAliveAtColumn:(colKey - 1) andRow:(rowKey + 1)])
        total++;
    if([self cellAliveAtColumn:colKey andRow:(rowKey + 1)])
        total++;
    if([self cellAliveAtColumn:(colKey + 1) andRow:(rowKey + 1)])
        total++;
    
    // Left & Right
    if([self cellAliveAtColumn:(colKey - 1) andRow:rowKey])
        total++;
    if([self cellAliveAtColumn:(colKey + 1) andRow:rowKey])
        total++;
    
    // Row Below
    if([self cellAliveAtColumn:(colKey - 1) andRow:(rowKey - 1)])
        total++;
    if([self cellAliveAtColumn:colKey andRow:(rowKey - 1)])
        total++;
    if([self cellAliveAtColumn:(colKey + 1) andRow:(rowKey - 1)])
        total++;
    
    return total;
}

- (void)updateCells {
    NSMutableArray *nextGen = [[NSMutableArray alloc] initWithCapacity:columns];
    for(int colIndex = 0; colIndex < columns; colIndex++) {
        NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:rows];
        for(int rowIndex = 0; rowIndex < rows; rowIndex++) {
            int neighbours = [self findNeighboursForCellAtColumn:colIndex andRow:rowIndex];
            Cell *cell = [self cellAtColumn:colIndex andRow:rowIndex];
            Cell *newCell = [[Cell alloc] init];
            if((neighbours == 2) && [cell alive]) {
                // Cells that are alive, with 2 neighbours stay alive
                [newCell setAlive:YES];
            } else if(neighbours == 3) {
                // Cells that have 3 neighbours are alive
                [newCell setAlive:YES];
            } else {
                // Everyone else dies
                [newCell setAlive:NO];
            }            
            [row insertObject:newCell atIndex:rowIndex];
        }
        [nextGen insertObject:row atIndex:colIndex];
    }
    [self setCells:nextGen];
    [view setNeedsDisplay:YES];
}

#pragma mark Events
- (IBAction)clear:(id)sender {
    for(int colIndex = 0; colIndex < columns; colIndex++) {        
        for(int rowIndex = 0; rowIndex < rows; rowIndex++) {
            [[self cellAtColumn:colIndex andRow:rowIndex] setAlive:NO];
        }
    }
    [view setNeedsDisplay:YES];
}

- (IBAction)next:(id)sender {
    [self updateCells];
}

- (IBAction)play:(id)sender {
    if(updateTimer == nil) {
        [play setTitle:@"Pause"];
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:-updateSpeed
                                                       target:self 
                                                     selector:@selector(timerFired:)
                                                     userInfo:nil 
                                                      repeats:YES];
    } else {
        [play setTitle:@"Play"];
        [updateTimer invalidate];
        updateTimer = nil;
    }
}

- (void)timerFired:(id)sender
{
    [self updateCells];
}

- (IBAction)resize:(id)sender {
    int newSize = [size intValue];
    NSMutableArray *newCells = [[NSMutableArray alloc] initWithCapacity:newSize];
    for(int colIndex = 0; colIndex < newSize; colIndex++) {
        NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:newSize];
        for(int rowIndex = 0; rowIndex < newSize; rowIndex++) {
            if(colIndex < [self columns] &&rowIndex < [self rows]) {
                [row insertObject:[self cellAtColumn:colIndex andRow:rowIndex] atIndex:rowIndex];
            } else {
                [row insertObject:[[Cell alloc] init] atIndex:rowIndex];
            }
        }
        [newCells insertObject:row atIndex:colIndex];
    }
    
    [self setCells:newCells];
    [self setRows:newSize];
    [self setColumns:newSize];
    [view setNeedsDisplay:YES];
}

- (IBAction)changeSpeed:(id)sender {
    updateSpeed = [speed intValue];  
    if([updateTimer isValid]) {
        [updateTimer invalidate];
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:-updateSpeed
                                                       target:self 
                                                     selector:@selector(timerFired:)
                                                     userInfo:nil 
                                                      repeats:YES];   
    }
}


#pragma mark Delegate Methods

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;   
}

@end
