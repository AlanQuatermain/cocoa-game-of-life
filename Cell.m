#import "Cell.h"

@implementation Cell

@synthesize alive;

- (id)init
{
    [super init];
    alive = NO;
    return self;
}

- (void)toggle
{
    [self setAlive:![self alive]];
}

@end
