//
//  WSKSoapRequest.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-05-10.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import "WSKSoapRequest.h"


@interface WSKSoapRequest ()

@property (readwrite, nonatomic, copy) NSString *action;

@end

@implementation WSKSoapRequest

@synthesize action;
@synthesize requestNamespace;

+ (WSKSoapRequest *)requestWithAction:(NSString *)anAction
{
	WSKSoapRequest *request = (WSKSoapRequest *)[self request];
	return request;
}

+ (WSKSoapRequest *)requestWithAction:(NSString *)anAction URL:(NSURL *)aURL
{
	WSKSoapRequest *request = (WSKSoapRequest *)[self requestWithURL:aURL];
	request.action = anAction;
	return request;
}

- (void)dealloc
{
	[action release];
	
	[super dealloc];
}

@end
