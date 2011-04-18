//
//  WSKSOAPEnvelope.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-17.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import "WSKSOAPEnvelope.h"

NSString * const WSKSoapEnvelopeXMLNS = @"http://www.w3.org/2003/05/soap-envelope";
NSString * const WSKSoapEnvelopeURI = @"soap";

@implementation WSKSOAPEnvelope

- (NSXMLElement *)envelope
{
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
