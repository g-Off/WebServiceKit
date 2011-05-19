//
//  WSKResponse.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-16.
//  Copyright 2011 . All rights reserved.
//

#import "WSKResponse.h"
#import "WSKRequest.h"

@implementation WSKResponse

@synthesize error;
@synthesize request;

- (id)initWithRequest:(WSKRequest *)aRequest
{
	if ((self = [super init])) {
		data = [[aRequest responseData] copy];
		request = [aRequest retain];
	}
	
	return self;
}

- (void)dealloc
{
	[data release];
	[error release];
	[request release];
	
	[super dealloc];
}

@end
