//
//  WSKSOAPDecoder.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-17.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import "WSKSOAPDecoder.h"
#import "WSKSoapService.h"
#import "WSKSoapFault.h"
#import "NSXMLElement+WebServiceKit.h"

#import "ISO8601DateFormatter.h"

static ISO8601DateFormatter * kWSKSoapDecoderDateFormatter = nil;

static NSString * const kWSKSoapDecoderXSDNS = @"http://www.w3.org/2001/XMLSchema";

/*
 Stores a dictionary of dictionaries
 namespace --> elementName --> Class
 */
static NSMutableDictionary *classMapping;

__attribute__((constructor))
static void constructor_soapDecoder()
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	classMapping = [[NSMutableDictionary alloc] init];
	
	kWSKSoapDecoderDateFormatter = [[ISO8601DateFormatter alloc] init];
	
	[pool drain];
}

__attribute__((destructor))
static void destructor_soapDecoder()
{
	[classMapping release];
	classMapping = nil;
	
	[kWSKSoapDecoderDateFormatter release];
	kWSKSoapDecoderDateFormatter = nil;
}

@interface WSKSOAPDecoder ()

- (Class)classForElement:(NSXMLElement *)element;
- (NSXMLNode *)nodeForKey:(NSString *)key;

- (NSString *)xsiTypeForElement:(NSXMLElement *)element;

@end

@implementation WSKSOAPDecoder

+ (void)initialize
{
	if (self == [WSKSOAPDecoder class]) {
		[self setClass:[NSString class] forName:@"string" withNamespace:kWSKSoapDecoderXSDNS];
		[self setClass:[NSDate class] forName:@"dateTime" withNamespace:kWSKSoapDecoderXSDNS];
		[self setClass:[NSMutableArray class] forName:@"Array" withNamespace:WSKSoap12EncodingURI];
		
		[self setClass:[WSKSoapFault class] forName:@"Fault" withNamespace:WSKSoap12EnvelopeURI];
	}
}

+ (id)unarchiveObjectWithRoot:(NSXMLElement *)element
{
	id obj = nil;
	
	WSKSOAPDecoder *decoder = [[self alloc] initWithRootObject:element];
	obj = [decoder decodeObject];
	[decoder release];
	
	return obj;
}

- (id)initWithRootObject:(NSXMLElement *)element
{
	if ((self = [super init])) {
		nodeStack = [[NSMutableArray alloc] initWithObjects:element, nil];
	}
	
	return self;
}

- (void)dealloc
{
	[nodeStack release];
	
	[super dealloc];
}

+ (void)setClass:(Class)cls forName:(NSString *)elementName withNamespace:(NSString *)aNamespace
{
	id namespaceKey = aNamespace;
	if (!aNamespace) {
		namespaceKey = [NSNull null];
	}
	
	NSMutableDictionary *nameToClass = [classMapping objectForKey:namespaceKey];
	
	if (!nameToClass) {
		nameToClass = [NSMutableDictionary dictionary];
		[classMapping setObject:nameToClass forKey:namespaceKey];
	}
	
	[nameToClass setObject:cls forKey:elementName];
}

+ (Class)classForName:(NSString *)elementName withNamespace:(NSString *)aNamespace
{
	Class cls = Nil;
	
	id namespaceKey = aNamespace;
	if (!aNamespace) {
		namespaceKey = [NSNull null];
	}
	
	NSMutableDictionary *nameToClass = [classMapping objectForKey:namespaceKey];
	if (nameToClass) {
		cls = [nameToClass objectForKey:elementName];
	}
	
	return cls;
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
	// TODO: probably need to check for "true" or "false" string values
	return [[[self nodeForKey:key] stringValue] boolValue];
}

- (double)decodeDoubleForKey:(NSString *)key
{
	return [[[self nodeForKey:key] stringValue] doubleValue];
}

- (float)decodeFloatForKey:(NSString *)key
{
	return [[[self nodeForKey:key] stringValue] floatValue];
}

- (int)decodeIntForKey:(NSString *)key
{
	return [[[self nodeForKey:key] stringValue] intValue];
}

- (NSInteger)decodeIntegerForKey:(NSString *)key
{
	return [[[self nodeForKey:key] stringValue] integerValue];
}

- (int32_t)decodeInt32ForKey:(NSString *)key
{
	return [[[self nodeForKey:key] stringValue] intValue];
}

- (int64_t)decodeInt64ForKey:(NSString *)key
{
	return [[[self nodeForKey:key] stringValue] longLongValue];
}

- (id)decodeObject
{
	id obj = nil;
	
	NSXMLElement *element = [nodeStack lastObject];
	NSString *xsiType = [self xsiTypeForElement:element];
	
	Class cls = Nil;
	
	if (xsiType) {
		NSString *typePrefix = nil;
		NSString *type = nil;
		NSArray *components = [xsiType componentsSeparatedByString:@":"];
		if ([components count] > 1) {
			typePrefix = [components objectAtIndex:0];
			type = [components objectAtIndex:1];
		} else {
			type = [components objectAtIndex:0];
		}
		
		NSString *namespaceURI = [element wsk_namespaceForPrefix:typePrefix];
		cls = [[self class] classForName:type withNamespace:namespaceURI];
		
	} else {
		cls = [self classForElement:element];
	}
	
	if ([cls isSubclassOfClass:[NSString class]]) {
		NSString *stringValue = [element stringValue];
		if (stringValue && [stringValue length] > 0) {
			obj = [stringValue copyWithZone:[self objectZone]];
		}
	} else if ([cls isSubclassOfClass:[NSNumber class]]) {
		
	} else if ([cls isSubclassOfClass:[NSDate class]]) {
		NSString *dateString = [element stringValue];
		if (dateString && [dateString length] > 0) {
			obj = [[kWSKSoapDecoderDateFormatter dateFromString:dateString] retain];
		}
	} else if ([cls isSubclassOfClass:[NSMutableArray class]]) {
		NSXMLNode *arraySizeAttribute = [element attributeForLocalName:@"arraySize" URI:WSKSoap12EncodingURI];
		NSUInteger arraySize = arraySizeAttribute ? [[arraySizeAttribute stringValue] integerValue] : 1;
		NSMutableArray *array = [NSMutableArray arrayWithCapacity:arraySize];
		for (NSXMLElement *child in [element children]) {
			[nodeStack addObject:child];
			id childObj = [self decodeObject];
			if (childObj) {
				[array addObject:childObj];
			}
			[nodeStack removeLastObject];
		}
		obj = [array copyWithZone:[self objectZone]];
	} else if ([cls conformsToProtocol:@protocol(NSCoding)]) {
		obj = [[cls allocWithZone:[self objectZone]] initWithCoder:self];
	} else {
		obj = [[cls allocWithZone:[self objectZone]] init];
	}
	
	return [obj autorelease];
}

- (id)decodeObjectForKey:(NSString *)key
{
	id obj = nil;
	NSXMLNode *node = [self nodeForKey:key];
	if (node) {
		[nodeStack addObject:node];
		obj = [self decodeObject];
		[nodeStack removeLastObject];
	}
	return obj;
}

- (Class)classForElement:(NSXMLElement *)element
{
	Class cls = Nil;
	
	cls = [[self class] classForName:[element localName] withNamespace:[element URI]];
	if (!cls) {
		cls = [[self class] classForName:[[element localName] lowercaseString] withNamespace:[element URI]];
	}
	
	return cls;
}

- (NSXMLNode *)nodeForKey:(NSString *)key
{
	NSXMLNode *keyedNode = nil;
	for (NSXMLNode *node in [(NSXMLNode *)[nodeStack lastObject] children]) {
		if ([[node localName] isEqualToString:key]) {
			keyedNode = node;
			break;
		}
	}
	
	return keyedNode;
}

- (NSString *)xsiTypeForElement:(NSXMLElement *)element
{
	NSXMLNode *xsiNamespace = [NSXMLNode predefinedNamespaceForPrefix:@"xsi"];
	NSXMLNode *xsiType = [element attributeForLocalName:@"type" URI:[xsiNamespace URI]];
	if (xsiType == nil) {
		xsiType = [element attributeForName:@"xsi:type"];
	}
	
//	if (xsiType) {
//		NSString *typePrefix = nil;
//		NSString *type = nil;
//		NSArray *components = [[xsiType stringValue] componentsSeparatedByString:@":"];
//		if ([components count] > 1) {
//			typePrefix = [components objectAtIndex:0];
//			type = [components objectAtIndex:1];
//		} else {
//			type = [components objectAtIndex:0];
//		}
//	}
	
	return [xsiType stringValue];
}

@end
