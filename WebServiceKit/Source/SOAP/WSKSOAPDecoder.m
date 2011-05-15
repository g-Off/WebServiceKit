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

/*
 Stores a dictionary of dictionaries
 namespace --> elementName --> Class
 */
static NSMutableDictionary *classMapping;

__attribute__((constructor))
void constructor_soapDecoder()
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	classMapping = [[NSMutableDictionary alloc] init];
	
	[pool drain];
}

__attribute__((destructor))
void destructor_soapDecoder()
{
	[classMapping release];
	classMapping = nil;
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
		[self setClass:[NSString class] forName:@"string" withNamespace:@"http://www.w3.org/2001/XMLSchema"];
		
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
		
		if ([typePrefix isEqualToString:@"xsd"]) {
			if ([type isEqualToString:@"string"]) {
				obj = [[element stringValue] copyWithZone:[self objectZone]];
			}
		}
		
	} else {
		cls = [self classForElement:element];
	}
	
	if ([cls conformsToProtocol:@protocol(NSCoding)]) {
		obj = [[cls allocWithZone:[self objectZone]] initWithCoder:self];
	} else {
		obj = [[cls allocWithZone:[self objectZone]] init];
	}
	
	return [obj autorelease];
}

- (id)decodeObjectForKey:(NSString *)key
{
	/*
	 this can probably be replaced by the following:
	 NSXMLNode *node = [self nodeForKey:key];
	 [nodeStack addObject:node];
	 id obj = [self decodeObject];
	 [nodeStack removeLastObject];
	 return obj;
	 */
	
	id obj = nil;
	
	NSXMLNode *node = [self nodeForKey:key];
	Class cls = [self classForElement:(NSXMLElement *)node];
	if (cls) {
		[nodeStack addObject:node];
		obj = [[cls allocWithZone:[self objectZone]] initWithCoder:self];
		[nodeStack removeLastObject];
	} else {
		obj = [[node stringValue] copyWithZone:[self objectZone]];
	}
	
	return [obj autorelease];
}

- (Class)classForElement:(NSXMLElement *)element
{
	Class cls = Nil;
	
	if (!cls) {
		cls = [[self class] classForName:[element localName] withNamespace:[element URI]];
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
