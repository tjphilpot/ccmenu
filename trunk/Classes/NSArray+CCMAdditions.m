
#import "NSArray+CCMAdditions.h"


@interface _CCMArrayCollector : NSObject
{
	NSArray	*array;
}

@end

@implementation _CCMArrayCollector

- (id)initWithArray:(NSArray *)anArray
{
	[super init];
	array = anArray;
	return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	if([array count] == 0)
	{
		// this is not correct, but we don't really care, we just need something that return an object
		return [super methodSignatureForSelector:@selector(init)]; 
	}
	return [[array objectAtIndex:0] methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	NSMutableArray *result = [NSMutableArray array];
	NSEnumerator *objectEnumerator = [array objectEnumerator];
	NSObject *object;
	while((object = [objectEnumerator nextObject]) != nil)
	{
		id returnValue;
		[anInvocation setTarget:object];
		[anInvocation invoke];
		[anInvocation getReturnValue:&returnValue];
		if(returnValue != nil)
			[result addObject:returnValue];
	}
	[anInvocation setTarget:self];
	[anInvocation setReturnValue:&result];
}

@end


@implementation NSArray(CCMCollectionAdditions)

- (id)collect
{
	return [[[_CCMArrayCollector alloc] initWithArray:self] autorelease];
}

@end