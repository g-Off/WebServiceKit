//
//  WSKService.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-16.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import "WSKService.h"
#import "WSKRequest.h"

#define kWSKOperationQueueName @"net.g-Off.WebServiceKit"

@implementation WSKService

- (id)init
{
	if ((self = [super init])) {
		requestQueue = [[NSOperationQueue alloc] init];
		[requestQueue setName:kWSKOperationQueueName];
		[requestQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
	}
	
	return self;
}

- (void)dealloc
{
	[requestQueue release];
	
	[super dealloc];
}

- (void)sendRequest:(WSKRequest *)aRequest
{
	[requestQueue addOperation:aRequest];
}

@end
