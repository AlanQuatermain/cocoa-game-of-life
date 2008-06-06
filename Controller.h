#import <Cocoa/Cocoa.h>
@class Cell;
@class PreferenceController;

extern NSString * const CGLGridSizeKey;
extern NSString * const CGLUpdateSpeedKey;

@interface Controller : NSObject {
    IBOutlet id view;
    IBOutlet id speed;
    IBOutlet id size;
    IBOutlet id play;
    
    PreferenceController *preferenceController;
    
    NSMutableArray *cells;
    int columns;
    int rows;
    
    NSTimer *updateTimer;
    int updateSpeed;
}
@property(readwrite, assign) int updateSpeed;
@property(readwrite, assign) int columns;
@property(readwrite, assign) int rows;
@property(readwrite, assign) NSMutableArray *cells;

- (Cell *)cellAtColumn:(int)colKey andRow:(int)rowKey;
- (void)setCell:(Cell *)aCell atColumn:(int)colKey andRow:(int)rowKey;
- (bool)cellAliveAtColumn:(int)colKey andRow:(int)rowKey;
- (void)setCellAlive:(bool)alive AtColumn:(int)colKey andRow:(int)rowKey;
- (void)toggleCellAtColumn:(int)colKey andRow:(int)rowKey;

- (int)findNeighboursForCellAtColumn:(int)colKey andRow:(int)rowKey;
- (void)updateCells;

#pragma mark Events
- (IBAction)clear:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)resize:(id)sender;
- (IBAction)changeSpeed:(id)sender;
- (IBAction)showPreferencePanel:(id)sender;
- (void)timerFired:(id)sender;
- (void)handleColorChange:(NSNotification *)note;

@end
