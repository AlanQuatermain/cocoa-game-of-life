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

- (void)awakeFromNib
{
    [NSApp setDelegate:self];
    [speed setFloatValue:updateSpeed];
    [size setIntValue:rows];

    // Pull the saved preferences (or the defaults)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *backgroundColorAsData = [defaults objectForKey:CGLBackgroundColorKey];
    [view setBackgroundColor:[NSKeyedUnarchiver unarchiveObjectWithData:backgroundColorAsData]];
    NSData *borderColorAsData = [defaults objectForKey:CGLBorderColorKey];
    [view setBorderColor:[NSKeyedUnarchiver unarchiveObjectWithData:borderColorAsData]];
    NSData *aliveColorAsData = [defaults objectForKey:CGLCellAliveColorKey];
    [view setAliveColor:[NSKeyedUnarchiver unarchiveObjectWithData:aliveColorAsData]];
    NSData *deadColorAsData = [defaults objectForKey:CGLCellDeadColorKey];
    [view setDeadColor:[NSKeyedUnarchiver unarchiveObjectWithData:deadColorAsData]];

    [view setBorderSize:[defaults integerForKey:CGLBorderSizeKey]];
}

-(id)init
{
    [super init];
    [self setUpdateSpeed:[[NSUserDefaults standardUserDefaults] floatForKey:CGLUpdateSpeedKey]];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self setRows:[defaults floatForKey:CGLGridSizeKey]];
    [self setColumns:[defaults floatForKey:CGLGridSizeKey]];

    cells = [[NSMutableArray alloc] initWithCapacity:columns];

    for(int colIndex = 0; colIndex < columns; colIndex++) {
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:rows];

        for(int rowIndex = 0; rowIndex < rows; rowIndex++) {
            [row insertObject:[[Cell alloc] init] atIndex:rowIndex];
        }
        [cells insertObject:row atIndex:colIndex];
    }

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(handleColorChange:)
               name:CGLColorChangedNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(handleBorderSizeChange:)
               name:CGLBorderSizeChangedNotification
             object:nil];

    return self;
}

#pragma mark -

/*!
 * @brief Returns the cell for a given column and row
 *
 * @param colKey column where the cell is located
 * @param rowKey row where the cell is located
 * @return the cell for the specified column and row
 */
- (Cell *)cellAtColumn:(int)colKey andRow:(int)rowKey
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
- (void)setCell:(Cell *)aCell atColumn:(int)colKey andRow:(int)rowKey
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
- (bool)cellAliveAtColumn:(int)colKey andRow:(int)rowKey
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
- (void)setCellAlive:(bool)alive AtColumn:(int)colKey andRow:(int)rowKey
{
    [[self cellAtColumn:colKey andRow:rowKey] setAlive:alive];
}

/*!
 * @brief Toggles the cell status for a given column and row
 *
 * @param colKey column where the cell is located
 * @param rowKey row where the cell is located
 */
- (void)toggleCellAtColumn:(int)colKey andRow:(int)rowKey
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
- (int)findNeighboursForCellAtColumn:(int)colKey andRow:(int)rowKey
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
            }
            else if(neighbours == 3) {
                // Cells that have 3 neighbours are alive
                [newCell setAlive:YES];
            }
            else {
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
- (IBAction)clear:(id)sender
{
    for(int colIndex = 0; colIndex < columns; colIndex++) {
        for(int rowIndex = 0; rowIndex < rows; rowIndex++) {
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
    if(updateTimer == nil) {
        [play setTitle:@"Pause"];
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:-updateSpeed
                                                       target:self
                                                     selector:@selector(timerFired:)
                                                     userInfo:nil
                                                      repeats:YES];
    }
    else {
        [play setTitle:@"Play"];
        [updateTimer invalidate];
        updateTimer = nil;
    }
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
    [view setNeedsDisplay:YES];
}

- (IBAction)changeSpeed:(id)sender
{
    updateSpeed = [speed floatValue];
    if([updateTimer isValid]) {
        [updateTimer invalidate];
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:-updateSpeed
                                                       target:self
                                                     selector:@selector(timerFired:)
                                                     userInfo:nil
                                                      repeats:YES];
    }
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:[size intValue]] forKey:CGLGridSizeKey];
    [defaults setObject:[NSNumber numberWithInt:[speed floatValue]] forKey:CGLUpdateSpeedKey];
}

@end
