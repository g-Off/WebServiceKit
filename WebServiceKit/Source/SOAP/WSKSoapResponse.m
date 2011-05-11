//
//  WSKSoapResponse.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-24.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import "WSKSoapResponse.h"
#import "WSKSoapRequest.h"
#import "WSKSoapService.h"
#import "WSKSoapFault.h"
#import "WSKSOAPDecoder.h"

@interface WSKSoapFault (WSKSoapResponseInit)

- (id)initWithElement:(NSXMLElement *)element;

@end

@implementation WSKSoapFault (WSKSoapResponseInit)

- (id)initWithElement:(NSXMLElement *)element
{
	if ((self = [super init])) {
		faultCode;
		faultString;
	}
	
	return self;
}

@end

@interface WSKSoapResponse ()

- (WSKSoapRequest *)soapRequest;

@end

@implementation WSKSoapResponse

@synthesize result;

- (id)initWithRequest:(WSKRequest *)aRequest
{
	if ((self = [super initWithRequest:aRequest])) {
		NSError *parseError = nil;
		soapDocument = [[NSXMLDocument alloc] initWithData:data options:0 error:&parseError];
		NSXMLElement *rootElement = [soapDocument rootElement];
		NSXMLElement *body = (NSXMLElement *)[[rootElement elementsForLocalName:@"Body" URI:WSKSoapEnvelopeURI] lastObject];
		NSLog(@"%@", body);
		
		NSXMLElement *faultElement = [[body elementsForLocalName:@"Fault" URI:WSKSoapEnvelopeURI] lastObject];
		if (faultElement) {
			fault = [[WSKSoapFault alloc] initWithElement:faultElement];
		} else {
			WSKSoapRequest *soapRequest = [self soapRequest];
			NSString *requestNamespace = [soapRequest requestNamespace];
			NSString *requestActionResponse = [NSString stringWithFormat:@"%@Response", soapRequest.action];
			NSArray *requestResponses = nil;
			if (requestNamespace) {
				requestResponses = [body elementsForLocalName:requestActionResponse URI:requestNamespace];
			} else {
				requestResponses = [body elementsForName:requestActionResponse];
			}
			
			if (requestResponses && [requestResponses count]) {
				NSXMLElement *responseElement = [requestResponses lastObject];
				NSXMLElement *resultObject = [[responseElement elementsForLocalName:@"result" URI:WSKSoapRPCURI] lastObject];
				if (resultObject) {
					NSString *returnName = [resultObject stringValue];
					
					if (returnName) {
						NSXMLElement *returnElement = [[responseElement elementsForName:returnName] lastObject];
						result = [[WSKSOAPDecoder unarchiveObjectWithRoot:returnElement] retain];
					}
				}
			}
		}
	}
	
	return self;
}

- (void)dealloc
{
	[result release];
	[soapDocument release];
	[fault release];
	
	[super dealloc];
}

- (BOOL)isSOAPFault
{
	return (fault == nil);
}

- (WSKSoapRequest *)soapRequest
{
	return (WSKSoapRequest *)request;
}

@end
