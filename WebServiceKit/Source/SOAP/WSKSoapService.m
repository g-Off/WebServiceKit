//
//  WSKSoapService.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-18.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import "WSKSoapService.h"


@implementation WSKSoapService

- (id)initWithServiceURL:(NSURL *)aURL
{
	if ((self = [super init])) {
		
	}
	
	return self;
}

- (void)callAction:(NSString *)action withObjects:(NSArray *)objects andKeys:(NSArray *)keys
{
	
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

@end
