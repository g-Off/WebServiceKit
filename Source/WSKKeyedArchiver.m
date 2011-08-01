//
//  WSKKeyedArchiver.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-07-31.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import "WSKKeyedArchiver.h"

@interface WSKKeyedArchiver ()

- (id)encodedObjectFromObject:(id)obj;

@end

@implementation WSKKeyedArchiver

+ (BOOL)archiveRootObject:(id)rootObject toFile:(NSString *)path
{
	WSKKeyedArchiver *archiver = [[WSKKeyedArchiver alloc] init];
	[archiver encodeRootObject:rootObject];
	id newRootObject = [archiver rootObject];
//	BOOL success = [NSKeyedArchiver archiveRootObject:newRootObject toFile:path];
	
	NSString *error = nil;
	NSData *data = [NSPropertyListSerialization dataFromPropertyList:newRootObject format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
	BOOL success = [data writeToFile:path atomically:YES];
	
	[archiver release];
	
	return success;
}

- (id)init
{
	if ((self = [super init])) {
	}
	
	return self;
}

- (void)dealloc
{
	[_root release];
	[super dealloc];
}

- (void)reset
{
	[_root release];
	_root = nil;
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
//	NSString *rootObjectName = nil;
//	if (delegate && [delegate respondsToSelector:@selector(encoder:wantsNameForClass:)]) {
//		rootObjectName = [delegate encoder:self wantsNameForClass:[rootObject class]];
//	} else {
//		rootObjectName = NSStringFromClass([rootObject class]);
//	}
//	
//	if (rootObjectName) {
//		[self encodeObject:rootObject forKey:rootObjectName];
//		currentElement = rootElement;
//	}
	
	_root = [self encodedObjectFromObject:rootObject];
}

- (id)rootObject
{
	return _root;
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
	[self encodeObject:[NSNumber numberWithBool:boolv] forKey:key];
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
	id encodedObject = [self encodedObjectFromObject:objv];
	[_current setObject:encodedObject forKey:key];
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

#pragma mark -
#pragma mark Private

- (id)encodedObjectFromObject:(id)objv
{
	id encodedObject = nil;
	
	if ([objv isKindOfClass:[NSString class]] ||
		[objv isKindOfClass:[NSNumber class]]) {
		encodedObject = [objv retain];
	}
	else if ([objv isKindOfClass:[NSArray class]]) {
		NSArray *objects = (NSArray *)objv;
		NSMutableArray *newObjects = [NSMutableArray arrayWithCapacity:[objects count]];
		[objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[newObjects addObject:[self encodedObjectFromObject:obj]];
		}];
		encodedObject = [newObjects copy];
	}
	else if ([objv isKindOfClass:[NSSet class]]) {
		NSSet *objects = (NSSet *)objv;
		NSMutableSet *newObjects = [NSMutableSet setWithCapacity:[objects count]];
		[objects enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
			[newObjects addObject:[self encodedObjectFromObject:obj]];
		}];
		encodedObject = [newObjects copy];
	}
	else if ([objv isKindOfClass:[NSDictionary class]]) {
		NSDictionary *objects = (NSDictionary *)objv;
		NSMutableDictionary *newObjects = [NSMutableDictionary dictionaryWithCapacity:[objects count]];
		[objects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			[newObjects setObject:[self encodedObjectFromObject:obj] forKey:[self encodedObjectFromObject:key]];
		}];
		encodedObject = [newObjects copy];
	}
	else if ([objv conformsToProtocol:@protocol(NSCoding)]) {
		NSMutableDictionary *_oldCurrent = _current;
		_current = [[NSMutableDictionary alloc] init];
		[_current setObject:NSStringFromClass([objv class]) forKey:@"$WSKClassName"];
		[objv encodeWithCoder:self];
//		[self encodeObject:objv];
		encodedObject = _current;
		_current = _oldCurrent;
	}
	
	return [encodedObject autorelease];
}

@end
