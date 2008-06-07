#import "PreferenceController.h"

NSString * const CGLBackgroundColorKey = @"BackgroundColor";
NSString * const CGLBorderColorKey = @"BorderColor";
NSString * const CGLCellAliveColorKey = @"CellAliveColor";
NSString * const CGLCellDeadColorKey = @"CellDeadColor";
NSString * const CGLColorChangedNotification = @"CGLColorChanged";
NSString * const CGLBorderSizeKey = @"BorderSize";
NSString * const CGLBorderSizeChangedNotification = @"CGLBorderSizeChanged";

@implementation PreferenceController

- (id)init
{
    self = [super initWithWindowNibName:@"Preferences"];
    defaults = [NSUserDefaults standardUserDefaults];
    nc = [NSNotificationCenter defaultCenter];
    return self;
}

- (NSColor *)backgroundColor
{
    NSData *colorAsData = [defaults objectForKey:CGLBackgroundColorKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:colorAsData];
}

- (NSColor *)borderColor
{
    NSData *colorAsData = [defaults objectForKey:CGLBorderColorKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:colorAsData];
}

- (NSColor *)cellAliveColor
{
    NSData *colorAsData = [defaults objectForKey:CGLCellAliveColorKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:colorAsData];
}

- (NSColor *)cellDeadColor
{
    NSData *colorAsData = [defaults objectForKey:CGLCellDeadColorKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:colorAsData];
}

- (int)borderSize
{
    return [defaults integerForKey:CGLBorderSizeKey];
}

- (void)windowDidLoad
{
    [backgroundColor setColor:[self backgroundColor]];
    [borderColor setColor:[self borderColor]];
    [cellAliveColor setColor:[self cellAliveColor]];
    [cellDeadColor setColor:[self cellDeadColor]];
    [borderSize setIntValue:[self borderSize]];
}

#pragma mark Events

- (IBAction)changeBorderColor:(id)sender
{
    NSColor *color = [borderColor color];
    NSData *colorAsData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [defaults setObject:colorAsData forKey:CGLBorderColorKey];
    NSDictionary *d = [NSDictionary dictionaryWithObject:color
        forKey:CGLBorderColorKey];
    [nc postNotificationName:CGLColorChangedNotification
        object:self
        userInfo:d];
}

- (IBAction)changeBackgroundColor:(id)sender
{
    NSColor *color = [backgroundColor color];
    NSData *colorAsData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [defaults setObject:colorAsData forKey:CGLBackgroundColorKey];
    NSDictionary *d = [NSDictionary dictionaryWithObject:color
        forKey:CGLBackgroundColorKey];
    [nc postNotificationName:CGLColorChangedNotification
        object:self
        userInfo:d];
}

- (IBAction)changeCellAliveColor:(id)sender
{
    NSColor *color = [cellAliveColor color];
    NSData *colorAsData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [defaults setObject:colorAsData forKey:CGLCellAliveColorKey];
    NSDictionary *d = [NSDictionary dictionaryWithObject:color
        forKey:CGLCellAliveColorKey];
    [nc postNotificationName:CGLColorChangedNotification
        object:self
        userInfo:d];
}

- (IBAction)changeCellDeadColor:(id)sender
{
    NSColor *color = [cellDeadColor color];
    NSData *colorAsData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [defaults setObject:colorAsData forKey:CGLCellDeadColorKey];
    NSDictionary *d = [NSDictionary dictionaryWithObject:color
        forKey:CGLCellDeadColorKey];
    [nc postNotificationName:CGLColorChangedNotification
        object:self
        userInfo:d];
}

- (IBAction)changeBorderSize:(id)sender
{
    NSNumber *size = [NSNumber numberWithInt:[borderSize intValue]];
    [defaults setObject:size forKey:CGLBorderSizeKey];
    NSDictionary *d = [NSDictionary dictionaryWithObject:size
        forKey:CGLBorderSizeKey];
    [nc postNotificationName:CGLBorderSizeChangedNotification
        object:self
        userInfo:d];

}

@end
