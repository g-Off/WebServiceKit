//
//  WSKSoapService.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-18.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import "WSKSoapService.h"
#import "WSKSOAPEncoder.h"

NSString * const WSKSoapEnvelopeXMLNS = @"http://www.w3.org/2003/05/soap-envelope";
NSString * const WSKSoapEnvelopeURI = @"soap";

@interface WSKSoapService ()

- (NSXMLElement *)packageElementInEnvelope:(NSXMLElement *)element;

@end

@implementation WSKSoapService

- (id)initWithServiceURL:(NSURL *)aURL
{
	if ((self = [super init])) {
		
	}
	
	return self;
}

- (void)callAction:(NSString *)action withObjects:(NSArray *)objects andKeys:(NSArray *)keys
{
	NSAssert([objects count] == [keys count], @"Mismatched size of keys and objects");
	
	NSXMLElement *methodElement = [NSXMLElement elementWithName:action];
	WSKSOAPEncoder *encoder = [[WSKSOAPEncoder alloc] init];
	NSEnumerator *keyEnumerator = [keys objectEnumerator];
	NSEnumerator *objEnumerator = [objects objectEnumerator];
	
	NSString *key = nil;
	id obj = nil;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	while ((key = (NSString *)[keyEnumerator nextObject]) && (obj = [objEnumerator nextObject])) {
		[encoder encodeObject:obj forKey:key];
		
		NSXMLElement *element = [encoder rootElement];
		[methodElement addChild:element];
		
		[encoder reset];
	}
	[pool drain];
	[encoder release];
	
	
}

- (void)callAction:(NSString *)action withObjects:(const id [])objects andKeys:(const id [])keys count:(NSUInteger)cnt
{
	[self callAction:action withObjects:[NSArray arrayWithObjects:objects count:cnt] andKeys:[NSArray arrayWithObjects:keys count:cnt]];
}

- (void)callAction:(NSString *)action withArgumentsAndKeys:(id)firstObject, ...
{
	NSMutableArray *objects = [NSMutableArray array];
	NSMutableArray *keys = [NSMutableArray array];
	
	BOOL isObject = YES;
	va_list args;
    va_start(args, firstObject);
	for (id arg = firstObject; arg != nil; arg = va_arg(args, id)) {
		if (isObject) {
			[objects addObject:arg];
		} else {
			[keys addObject:arg];
		}
		isObject = !isObject;
	}
	va_end(args);
	
	[self callAction:action withObjects:objects andKeys:keys];
}

#pragma mark -

- (NSXMLElement *)packageElementInEnvelope:(NSXMLElement *)element
{
	/*
	 WSKSOAPEnvelope *env = [[WSKSOAPEnvelope alloc] init];
	 NSXMLElement *envelope = [env envelope];
	 NSXMLDocument *doc = [NSXMLDocument documentWithRootElement:envelope];
	 [doc setCharacterEncoding:@"UTF-8"];
	 [doc setVersion:@"1.0"];
	 [env release];
	 
	 NSLog(@"%@", doc);
	 NSError *error = nil;
	 [doc validateAndReturnError:&error];
	 NSLog(@"%@", error);
	 */
	NSXMLElement *envelope = [NSXMLElement elementWithName:@"Envelope" URI:WSKSoapEnvelopeURI];
	NSXMLNode *soapNamespace = [NSXMLNode namespaceWithName:WSKSoapEnvelopeURI stringValue:WSKSoapEnvelopeXMLNS];
	[envelope addNamespace:soapNamespace];
	
	NSXMLElement *header = [NSXMLElement elementWithName:@"Header" URI:WSKSoapEnvelopeURI];
	NSXMLElement *body = [NSXMLElement elementWithName:@"Body" URI:WSKSoapEnvelopeURI];
	
	[envelope addChild:header];
	[envelope addChild:body];
	
	return envelope;
}

@end
