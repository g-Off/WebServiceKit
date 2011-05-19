//
//  WSKSoapFault.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-25.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import "WSKSoapFault.h"


@implementation WSKSoapFault

- (id)init
{
	if ((self = [super init])) {
		
	}
	
	return self;
}

- (void)dealloc
{
	[faultCode release];
	[faultString release];
	
	[super dealloc];
}

@end
