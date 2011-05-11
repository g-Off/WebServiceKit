//
//  NSXMLElement+WebServiceKit.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-23.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import "NSXMLElement+WebServiceKit.h"


@implementation NSXMLElement (WebServiceKit)

+ (id)elementWithName:(NSString *)name prefix:(NSString *)prefix URI:(NSString *)uri
{
	NSString *elementName = [NSString stringWithFormat:@"%@:%@", prefix, name];
	return [NSXMLElement elementWithName:elementName URI:uri];
}

@end
