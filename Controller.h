#import <Cocoa/Cocoa.h>

@class Cell;
@class PreferenceController;
@class CellView;

extern NSString * const CGLGridSizeKey;
extern NSString * const CGLUpdateSpeedKey;

@interface Controller : NSObject
{
    IBOutlet CellView *view;
    IBOutlet NSSlider *speed;
    IBOutlet NSSlider *size;
    IBOutlet NSButton *play;

    PreferenceController *preferenceController;

    // Cells
    NSMutableArray *cells;
    NSUInteger columns;
    NSUInteger rows;
    
    // Updates index-path holder
    NSMutableArray * updates;

    // Timer
    NSTimer *updateTimer;
    NSTimeInterval updateSpeed;
}

@property(readwrite, assign) NSTimeInterval updateSpeed;
@property(readwrite, assign) NSUInteger columns;
@property(readwrite, assign) NSUInteger rows;
@property(readwrite, assign) NSMutableArray *cells;

- (Cell *)cellAtColumn:(NSUInteger)colKey andRow:(NSUInteger)rowKey;
- (void)setCell:(Cell *)aCell atColumn:(NSUInteger)colKey andRow:(NSUInteger)rowKey;
- (bool)cellAliveAtColumn:(NSUInteger)colKey andRow:(NSUInteger)rowKey;
- (void)setCellAlive:(BOOL)alive AtColumn:(NSUInteger)colKey andRow:(NSUInteger)rowKey;
- (void)toggleCellAtColumn:(NSUInteger)colKey andRow:(NSUInteger)rowKey;

- (int)findNeighboursForCellAtColumn:(NSUInteger)colKey andRow:(NSUInteger)rowKey;
- (void)updateCells;

#pragma mark Events
- (IBAction)clear:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)resize:(id)sender;
- (IBAction)changeSpeed:(id)sender;
- (IBAction)showPreferencePanel:(id)sender;
- (void)timerFired:(id)sender;
- (void)handleColorChange:(NSNotification *)note;

@end
