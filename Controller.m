#import "Controller.h"
#import "Cell.h"
#import "PreferenceController.h"
#import "CellView.h"

NSString * const CGLGridSizeKey = @"GridSize";
NSString * const CGLUpdateSpeedKey = @"UpdateSpeed";

@implementation Controller

@synthesize updateSpeed;
@synthesize columns;
@synthesize rows;
@synthesize cells;

+ (void)initialize
{
    // Set defaults for colors, update speed, grid size
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];

    // Colors
    NSData *backgroundColorAsData = [NSKeyedArchiver archivedDataWithRootObject:
    [NSColor grayColor]];
    NSData *borderColorAsData = [NSKeyedArchiver archivedDataWithRootObject:
    [NSColor whiteColor]];
    NSData *cellAliveColorAsData = [NSKeyedArchiver archivedDataWithRootObject:
    [NSColor yellowColor]];
    NSData *cellDeadColorAsData = [NSKeyedArchiver archivedDataWithRootObject:
    [NSColor blackColor]];

    [defaultValues setObject:backgroundColorAsData forKey:CGLBackgroundColorKey];
    [defaultValues setObject:borderColorAsData forKey:CGLBorderColorKey];
    [defaultValues setObject:cellAliveColorAsData forKey:CGLCellAliveColorKey];
    [defaultValues setObject:cellDeadColorAsData forKey:CGLCellDeadColorKey];
    [defaultValues setObject:[NSNumber numberWithInt:40] forKey:CGLGridSizeKey];
    [defaultValues setObject:[NSNumber numberWithFloat:-1.0] forKey:CGLUpdateSpeedKey];
    [defaultValues setObject:[NSNumber numberWithInt:1] forKey:CGLBorderSizeKey];

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];

}

- (void) awakeFromNib
{
    [speed setDoubleValue:updateSpeed];
    [size setIntegerValue:rows];

    // Pull the saved preferences (or the defaults)
    NSData * data = nil;
    data = [[NSUserDefaults standardUserDefaults] objectForKey: CGLBackgroundColorKey];
    view.backgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData: data];
    data = [[NSUserDefaults standardUserDefaults] objectForKey: CGLBorderColorKey];
    view.borderColor = [NSKeyedUnarchiver unarchiveObjectWithData: data];
    data = [[NSUserDefaults standardUserDefaults] objectForKey: CGLCellAliveColorKey];
    view.aliveColor = [NSKeyedUnarchiver unarchiveObjectWithData: data];
    data = [[NSUserDefaults standardUserDefaults] objectForKey: CGLCellDeadColorKey];
    view.deadColor = [NSKeyedUnarchiver unarchiveObjectWithData: data];

    view.borderSize = [[NSUserDefaults standardUserDefaults] integerForKey: CGLBorderSizeKey];
}

-(id)init
{
    self = [super init];
    if ( self == nil )
        return ( nil );
    
    self.updateSpeed = [[NSUserDefaults standardUserDefaults] doubleForKey: CGLUpdateSpeedKey];

    self.rows = [[NSUserDefaults standardUserDefaults] integerForKey:CGLGridSizeKey];
    self.columns = [[NSUserDefaults standardUserDefaults] integerForKey:CGLGridSizeKey];

    // using alloc/init, so not using property accessors
    cells = [[NSMutableArray alloc] initWithCapacity:columns];
    updates = [[NSMutableArray alloc] initWithCapacity: columns * rows];
    
    srandom( time(NULL) );

    for ( int colIndex = 0; colIndex < columns; colIndex++ )
    {
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:rows];

        for ( int rowIndex = 0; rowIndex < rows; rowIndex++ )
        {
            // randomized starting state
            Cell * cell = [[Cell alloc] init];
            cell.alive = (BOOL) (random() % 2);
            [row insertObject:cell atIndex:rowIndex];
            [cell release];
        }
        
        [cells insertObject:row atIndex:colIndex];
    }

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleColorChange:)
                                                 name: CGLColorChangedNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleBorderSizeChange:)
                                                 name: CGLBorderSizeChangedNotification
                                               object: nil];

    return self;
}

- (void) dealloc
{
    [preferenceController release];
    [cells release];
    [updates release];
    [updateTimer invalidate];
    [updateTimer release];
    [super dealloc];
}

#pragma mark -

/*!
 * @brief Returns the cell for a given column and row
 *
 * @param colKey column where the cell is located
 * @param rowKey row where the cell is located
 * @return the cell for the specified column and row
 */
- (Cell *)cellAtColumn:(NSUInteger)colKey andRow:(NSUInteger)rowKey
{
    if((colKey < 0 || colKey >= [self columns]) || (rowKey < 0 || rowKey >= [self rows]))
        return nil;
    return [[cells objectAtIndex:colKey] objectAtIndex:rowKey];
}

/*!
 * @brief Sets the cell for a given column and row
 *
 * @param aCell the cell to placed at the specified column and row
 * @param colKey column where the cell is located
 * @param rowKey row where the cell is located
 */
- (void)setCell:(Cell *)aCell atColumn:(NSUInteger)colKey andRow:(NSUInteger)rowKey
{
    NSMutableArray *column = [cells objectAtIndex:colKey];
    [column replaceObjectAtIndex:rowKey withObject:aCell];
    [cells replaceObjectAtIndex:colKey withObject:column];
}

/*!
 * @brief Returns the status of a cell for a given column and row
 *
 * @param colKey column where the cell is located
 * @param rowKey row where the cell is located
 * @return YES if the cell is alive, NO if it is dead
 */
- (bool)cellAliveAtColumn:(NSUInteger)colKey andRow:(NSUInteger)rowKey
{
    return [[self cellAtColumn:colKey andRow:rowKey] alive];
}

/*!
 * @brief Sets the status of a cell for a given column and row
 *
 * @param alive YES if the cell is alive, NO if it is dead
 * @param colKey column where the cell is located
 * @param rowKey row where the cell is located
 */
- (void)setCellAlive:(BOOL)alive AtColumn:(NSUInteger)colKey andRow:(NSUInteger)rowKey
{
    [[self cellAtColumn:colKey andRow:rowKey] setAlive:alive];
}

/*!
 * @brief Toggles the cell status for a given column and row
 *
 * @param colKey column where the cell is located
 * @param rowKey row where the cell is located
 */
- (void)toggleCellAtColumn:(NSUInteger)colKey andRow:(NSUInteger)rowKey
{
    [[self cellAtColumn:colKey andRow:rowKey] toggle];
}

/*!
 * @brief Finds the neigbhours of a cell
 *
 * @param colKey column where the cell is located
 * @param rowKey row where the cell is located
 * @return total number of neighbours
 */
- (int)findNeighboursForCellAtColumn:(NSUInteger)colKey andRow:(NSUInteger)rowKey
{
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

/*!
 * @brief Iterates through the cells, finds neighbours, and sets the status of the next generation's cells.
 */
- (void)updateCells
{
    [updates removeAllObjects];
    for ( int colIndex = 0; colIndex < columns; colIndex++ )
    {
        for ( int rowIndex = 0; rowIndex < rows; rowIndex++ )
        {
            int neighbours = [self findNeighboursForCellAtColumn:colIndex andRow:rowIndex];
            Cell *cell = [self cellAtColumn:colIndex andRow:rowIndex];
            BOOL toggle = NO;
            
            if ( cell.alive )
            {
                if ( (neighbours < 2) || (neighbours > 3) )
                    toggle = YES;
            }
            else if ( neighbours == 3 )
            {
                toggle = YES;
            }
            
            if ( toggle )
            {
                NSUInteger coords[2] = { colIndex, rowIndex };
                [updates addObject: [NSIndexPath indexPathWithIndexes: coords length: 2]];
            }
        }
    }
    
    // now we toggle everything we just marked
    for ( NSIndexPath * path in updates )
    {
        [self toggleCellAtColumn: [path indexAtPosition: 0] andRow: [path indexAtPosition: 1]];
    }
    
    [view setNeedsDisplay:YES];
}

#pragma mark Events
- (IBAction)clear:(id)sender
{
    for ( int colIndex = 0; colIndex < columns; colIndex++ )
    {
        for ( int rowIndex = 0; rowIndex < rows; rowIndex++ )
        {
            [[self cellAtColumn:colIndex andRow:rowIndex] setAlive:NO];
        }
    }
    
    [view setNeedsDisplay:YES];
}

- (IBAction)next:(id)sender
{
    [self updateCells];
}

- (IBAction)play:(id)sender
{
    [sender setTitle:@"Pause"];
    [sender setAction: @selector(pause:)];
    updateTimer = [[NSTimer scheduledTimerWithTimeInterval: updateSpeed
                                                    target: self
                                                  selector: @selector(timerFired:)
                                                  userInfo: nil
                                                   repeats: YES] retain];
}

- (IBAction)pause:(id)sender
{
    [sender setTitle: @"Play"];
    [sender setAction: @selector(play:)];
    [updateTimer invalidate];
    [updateTimer release];
    updateTimer = nil;
}

- (IBAction)resize:(id)sender
{
    int newSize = [size intValue];
    NSMutableArray *newCells = [[NSMutableArray alloc] initWithCapacity:newSize];
    for(int colIndex = 0; colIndex < newSize; colIndex++) {
        NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:newSize];
        for(int rowIndex = 0; rowIndex < newSize; rowIndex++) {
            if(colIndex < [self columns] &&rowIndex < [self rows]) {
                [row insertObject:[self cellAtColumn:colIndex andRow:rowIndex] atIndex:rowIndex];
            }
            else {
                [row insertObject:[[Cell alloc] init] atIndex:rowIndex];
            }
        }
        [newCells insertObject:row atIndex:colIndex];
    }

    [self setCells:newCells];
    [self setRows:newSize];
    [self setColumns:newSize];
    [updates release];
    updates = [[NSMutableArray alloc] initWithCapacity: columns * rows];
    [view setNeedsDisplay:YES];
}

- (IBAction)changeSpeed:(id)sender
{
    updateSpeed = 1.0 / [speed doubleValue];
    
    [updateTimer invalidate];
    [updateTimer release];
    
    updateTimer = [[NSTimer scheduledTimerWithTimeInterval: updateSpeed
                                                    target: self
                                                  selector: @selector(timerFired:)
                                                  userInfo: nil
                                                   repeats: YES] retain];
}

- (IBAction)showPreferencePanel:(id)sender
{
    if(!preferenceController) {
        preferenceController = [[PreferenceController alloc] init];
    }
    [preferenceController showWindow:self];
}

- (void)timerFired:(id)sender
{
    [self updateCells];
}

- (void)handleColorChange:(NSNotification *)note
{
    NSString *key = [[[note userInfo] allKeys] objectAtIndex:0];
    if(key == CGLBackgroundColorKey) {
        NSColor *color = [[note userInfo] objectForKey:CGLBackgroundColorKey];
        [view setBackgroundColor:color];
    }
    else if (key == CGLBorderColorKey) {
        NSColor *color = [[note userInfo] objectForKey:CGLBorderColorKey];
        [view setBorderColor:color];
    }
    else if (key == CGLCellAliveColorKey) {
        NSColor *color = [[note userInfo] objectForKey:CGLCellAliveColorKey];
        [view setAliveColor:color];
    }
    else if (key == CGLCellDeadColorKey) {
        NSColor *color = [[note userInfo] objectForKey:CGLCellDeadColorKey];
        [view setDeadColor:color];
    }
    [view setNeedsDisplay:YES];
}

- (void)handleBorderSizeChange:(NSNotification *)note
{
    NSNumber *borderSize = [[note userInfo] objectForKey:CGLBorderSizeKey];
    [view setBorderSize:[borderSize intValue]];
    [view setNeedsDisplay:YES];
}

#pragma mark Delegate Methods

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] setInteger:[size integerValue] forKey:CGLGridSizeKey];
    [[NSUserDefaults standardUserDefaults] setDouble: [speed doubleValue] forKey:CGLUpdateSpeedKey];
}

@end
