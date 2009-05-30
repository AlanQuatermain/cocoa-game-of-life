#import <Cocoa/Cocoa.h>

@interface Cell : NSObject
{
    BOOL    alive;
}

@property(nonatomic, assign) BOOL alive;

- (void)toggle;

@end
