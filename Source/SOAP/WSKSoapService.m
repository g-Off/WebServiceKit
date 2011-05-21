//
//  WSKSoapService.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-18.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import "WSKSoapService.h"
#import "WSKSOAPEncoder.h"
#import "WSKSoapRequest.h"
#import "WSKSoapResponse.h"

#import "NSXMLElement+WebServiceKit.h"

NSString * const WSKSoap12EnvelopeURI = @"http://www.w3.org/2003/05/soap-envelope";
NSString * const WSKSoap12EncodingURI = @"http://www.w3.org/2003/05/soap-encoding";
NSString * const WSKSoapRPCURI = @"http://www.w3.org/2003/05/soap-rpc";
NSString * const WSKSoapEnvelopePrefix = @"env";

@interface WSKSoapService () <WSKRequestDelegate>

- (NSXMLDocument *)packageElementInEnvelope:(NSXMLElement *)element;

@end

@implementation WSKSoapService

@synthesize serviceURL;

+ (WSKSoapService *)serviceWithURL:(NSURL *)aURL
{
	return [[[[self class] alloc] initWithServiceURL:aURL] autorelease];
}

- (id)init
{
	return [self initWithServiceURL:nil];
}

- (id)initWithServiceURL:(NSURL *)aURL
{
	if ((self = [super init])) {
		self.serviceURL = aURL;
		namespaces = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	self.serviceURL = nil;
	[namespaces release];
	
	[super dealloc];
}

- (void)addURI:(NSString *)uri forNamespace:(NSString *)ns
{
	[namespaces setObject:ns forKey:uri];
}

#pragma mark -

- (NSXMLDocument *)packageElementInEnvelope:(NSXMLElement *)element
{
	NSXMLElement *envelope = [NSXMLElement wsk_elementWithName:@"Envelope" prefix:WSKSoapEnvelopePrefix URI:WSKSoap12EnvelopeURI];
	NSXMLNode *soapNamespace = [NSXMLNode namespaceWithName:WSKSoapEnvelopePrefix stringValue:WSKSoap12EnvelopeURI];
	[envelope addNamespace:soapNamespace];
	[envelope addNamespace:[NSXMLNode predefinedNamespaceForPrefix:@"xsi"]];
	[envelope addNamespace:[NSXMLNode predefinedNamespaceForPrefix:@"xs"]];
	
	[namespaces enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[envelope addNamespace:[NSXMLNode namespaceWithName:key stringValue:obj]];
	}];
	
	NSXMLElement *header = [NSXMLElement wsk_elementWithName:@"Header" prefix:WSKSoapEnvelopePrefix URI:WSKSoap12EnvelopeURI];
	NSXMLElement *body = [NSXMLElement wsk_elementWithName:@"Body" prefix:WSKSoapEnvelopePrefix URI:WSKSoap12EnvelopeURI];
	[body addChild:element];
	
	[envelope addChild:header];
	[envelope addChild:body];
	
	NSXMLDocument *envelopeDocument = [NSXMLDocument documentWithRootElement:envelope];
	[envelopeDocument setCharacterEncoding:@"UTF-8"];
	[envelopeDocument setVersion:@"1.0"];
//	[envelopeDocument setStandalone:YES];
	
	return envelopeDocument;
}

#pragma mark - WSKRequestDelegate

- (void)request:(WSKRequest *)request didFinishWithResponse:(WSKResponse *)response
{
	
}

- (WSKRequest *)requestWithAction:(NSString *)action withObjects:(NSArray *)objects andKeys:(NSArray *)keys
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
	
	NSXMLDocument *envelope = [self packageElementInEnvelope:methodElement];
	NSLog(@"%@", envelope);
	NSData *body = [envelope XMLData];
	
	WSKRequest *request = [WSKSoapRequest requestWithAction:action URL:serviceURL];
	[request setResponseClass:[WSKSoapResponse class]];
	NSMutableURLRequest *urlRequest = [request urlRequest];
	[urlRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:body];
	[urlRequest setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[urlRequest setValue:@"\"\"" forHTTPHeaderField:@"SOAPaction"];
	[urlRequest setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
	
	return request;
}

- (WSKRequest *)requestWithAction:(NSString *)action withObjects:(const id [])objects andKeys:(const id [])keys count:(NSUInteger)cnt
{
	return [self requestWithAction:action withObjects:[NSArray arrayWithObjects:objects count:cnt] andKeys:[NSArray arrayWithObjects:keys count:cnt]];
}

- (WSKRequest *)requestWithAction:(NSString *)action withArgumentsAndKeys:(id)firstObject, ...
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
	
	return [self requestWithAction:action withObjects:objects andKeys:keys];
}

@end
