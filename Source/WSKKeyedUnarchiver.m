//
//  WSKKeyedUnarchiver.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-07-31.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import "WSKKeyedUnarchiver.h"

@implementation WSKKeyedUnarchiver

+ (id)unarchiveObjectWithObject:(id)obj
{
	WSKKeyedUnarchiver *unarchiver = [[WSKKeyedUnarchiver alloc] initWithObject:obj];
	id unarchivedObj = [[unarchiver decodeObject] retain];
	[unarchiver release];
	
	return [unarchivedObj autorelease];
}

- (id)initWithObject:(id)obj
{
	if ((self = [super init])) {
		rootObject = [obj retain];
		objectStack = [[NSMutableArray alloc] initWithObjects:rootObject, nil];
	}
	
	return self;
}

- (void)dealloc
{
	[rootObject release];
	[objectStack release];
	
	[super dealloc];
}

#pragma mark - NSCoder

- (BOOL)allowsKeyedCoding
{
	return YES;
}

- (BOOL)containsValueForKey:(NSString *)key
{
	return NO;
}

// TODO: should maybe get objectValue back instead of stringValue if it's an NSNumber

- (const uint8_t *)decodeBytesForKey:(NSString *)key returnedLength:(NSUInteger *)lengthp
{
	NSLog(@"%@", key);
	// TODO
	return NULL;
}

- (BOOL)decodeBoolForKey:(NSString *)key
{
	return [(NSNumber *)[self decodeObjectForKey:key] boolValue];
}

- (double)decodeDoubleForKey:(NSString *)key
{
	return [(NSNumber *)[self decodeObjectForKey:key] doubleValue];
}

- (float)decodeFloatForKey:(NSString *)key
{
	return [(NSNumber *)[self decodeObjectForKey:key] floatValue];
}

- (int)decodeIntForKey:(NSString *)key
{
	return [(NSNumber *)[self decodeObjectForKey:key] intValue];
}

- (NSInteger)decodeIntegerForKey:(NSString *)key
{
	return [(NSNumber *)[self decodeObjectForKey:key] integerValue];
}

- (int32_t)decodeInt32ForKey:(NSString *)key
{
	return [(NSNumber *)[self decodeObjectForKey:key] intValue];
}

- (int64_t)decodeInt64ForKey:(NSString *)key
{
	return [(NSNumber *)[self decodeObjectForKey:key] longLongValue];
}

- (id)decodeObject
{
	id decodedObject = nil;
	id stackObject = [objectStack lastObject];
	
	if ([stackObject isKindOfClass:[NSString class]]) {
		decodedObject = [stackObject retain];
	}
	else if ([stackObject isKindOfClass:[NSNumber class]]) {
		decodedObject = [stackObject retain];
	}
	else if ([stackObject isKindOfClass:[NSArray class]]) {
		NSArray *objects = (NSArray *)stackObject;
		NSMutableArray *array = [NSMutableArray arrayWithCapacity:[objects count]];
		[objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[objectStack addObject:obj];
			[array addObject:[self decodeObject]];
			[objectStack removeLastObject];
		}];
		
		decodedObject = [array copy];
	}
	else if ([stackObject isKindOfClass:[NSSet class]]) {
		NSSet *objects = (NSSet *)stackObject;
		NSMutableSet *set = [NSMutableSet setWithCapacity:[objects count]];
		[objects enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
			[objectStack addObject:obj];
			[set addObject:[self decodeObject]];
			[objectStack removeLastObject];
		}];
		
		decodedObject = [set copy];
	}
	else if ([stackObject isKindOfClass:[NSDictionary class]]) {
		NSDictionary *objects = (NSDictionary *)stackObject;
		
		NSString *className = [objects objectForKey:@"$WSKClassName"];
		if (className) {
			Class cls = NSClassFromString(className);
			if (cls && [cls instancesRespondToSelector:@selector(initWithCoder:)]) {
				decodedObject = [[cls alloc] initWithCoder:self];
			}
		} else {
			NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[objects count]];
			[objects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
				[objectStack addObject:key];
				id decodedKey = [self decodeObject];
				[objectStack removeLastObject];
				
				[objectStack addObject:obj];
				id decodedObj = [self decodeObject];
				[objectStack removeLastObject];
				
				[dictionary setObject:decodedObj forKey:decodedKey];
			}];
			
			decodedObject = [dictionary copy];
		}
	}
	
	return [decodedObject autorelease];
}

- (id)decodeObjectForKey:(NSString *)key
{
	id retVal = nil;
	id stackObject = [objectStack lastObject];
	if ([stackObject isKindOfClass:[NSDictionary class]]) {
		NSDictionary *dictionary = (NSDictionary *)stackObject;
		
		id obj = [dictionary objectForKey:key];
		if (obj) {
			[objectStack addObject:obj];
			retVal = [self decodeObject];
			[objectStack removeLastObject];
		}
	}
	return retVal;
}

@end
