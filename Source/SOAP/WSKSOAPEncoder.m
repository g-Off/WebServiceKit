//
//  WSKSOAPEncoder.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-17.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import "WSKSOAPEncoder.h"


@implementation WSKSOAPEncoder

@synthesize delegate;
@synthesize  rootElement;

- (id)init
{
	if ((self = [super init])) {
	}
	
	return self;
}

- (void)dealloc
{
	[rootElement release];
	currentElement = nil;
	[super dealloc];
}

- (void)reset
{
	currentElement = nil;
	[rootElement release];
	rootElement = nil;
}

#pragma mark - NSCoder

- (BOOL)allowsKeyedCoding
{
	return YES;
}

- (NSInteger)versionForClassName:(NSString *)className
{
	return 0;
}

- (void)encodeRootObject:(id)rootObject
{
	NSString *rootObjectName = nil;
	if (delegate && [delegate respondsToSelector:@selector(encoder:wantsNameForClass:)]) {
		rootObjectName = [delegate encoder:self wantsNameForClass:[rootObject class]];
	} else {
		rootObjectName = NSStringFromClass([rootObject class]);
	}
	
	if (rootObjectName) {
		[self encodeObject:rootObject forKey:rootObjectName];
		currentElement = rootElement;
	}
}

- (void)encodeValueOfObjCType:(const char *)type at:(const void *)addr
{
	
}

- (void)encodeDataObject:(NSData *)data
{
	
}

#pragma mark - Keyed Coding

- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key
{
	
}

- (void)encodeBytes:(const uint8_t *)bytesp length:(NSUInteger)lenv forKey:(NSString *)key
{
	
}

- (void)encodeConditionalObject:(id)objv forKey:(NSString *)key
{
	
}

- (void)encodeDouble:(double)realv forKey:(NSString *)key
{
	[self encodeObject:[NSNumber numberWithDouble:realv] forKey:key];
}

- (void)encodeFloat:(float)realv forKey:(NSString *)key
{
	[self encodeObject:[NSNumber numberWithFloat:realv] forKey:key];
}

- (void)encodeInt32:(int32_t)intv forKey:(NSString *)key
{
	[self encodeObject:[NSNumber numberWithInt:intv] forKey:key];
}

- (void)encodeInt64:(int64_t)intv forKey:(NSString *)key
{
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
	[self encodeObject:[NSNumber numberWithLong:intv] forKey:key];
#else
	[self encodeObject:[NSNumber numberWithLongLong:intv] forKey:key];
#endif
}

- (void)encodeInt:(int)intv forKey:(NSString *)key
{
	[self encodeObject:[NSNumber numberWithInt:intv] forKey:key];
}

- (void)encodeInteger:(NSInteger)intv forKey:(NSString *)key
{
	[self encodeObject:[NSNumber numberWithInteger:intv] forKey:key];
}

- (void)encodeObject:(id)objv forKey:(NSString *)key
{
	NSXMLElement *element = [NSXMLElement elementWithName:key];
	
	if (rootElement == nil) {
		rootElement = [element retain];
		currentElement = rootElement;
	}
	
	if ([objv isKindOfClass:[NSString class]] ||
		[objv isKindOfClass:[NSNumber class]] ||
		[objv isKindOfClass:[NSCalendarDate class]] ||
		[objv isKindOfClass:[NSData class]] ||
		[objv isKindOfClass:[NSURL class]]) {
		[element setObjectValue:objv];
	} else if ([objv isKindOfClass:[NSArray class]]) {
		
	} else if ([objv conformsToProtocol:@protocol(NSCoding)]) {
		[objv encodeWithCoder:self];
	}
	
	if (currentElement != element) {
		[currentElement addChild:element];
	}
}

- (void)encodePoint:(NSPoint)point forKey:(NSString *)key
{
	
}

- (void)encodeRect:(NSRect)rect forKey:(NSString *)key
{
	
}

- (void)encodeSize:(NSSize)size forKey:(NSString *)key
{
	
}

@end
