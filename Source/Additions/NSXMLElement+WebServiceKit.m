//
//  NSXMLElement+WebServiceKit.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-23.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import "NSXMLElement+WebServiceKit.h"


@implementation NSXMLElement (WebServiceKit)

+ (id)wsk_elementWithName:(NSString *)name prefix:(NSString *)prefix URI:(NSString *)uri
{
	NSString *elementName = [NSString stringWithFormat:@"%@:%@", prefix, name];
	return [NSXMLElement elementWithName:elementName URI:uri];
}

- (NSString *)wsk_namespaceForPrefix:(NSString *)prefix
{
	NSXMLNode *namespaceNode = nil;
	NSXMLNode *current = self;
	while (current != nil) {
		if ([current kind] == NSXMLElementKind) {
			NSXMLElement *currentElement = (NSXMLElement *)current;
			namespaceNode = [currentElement namespaceForPrefix:prefix];
			if (namespaceNode) {
				break;
			}
		}
		current = [current parent];
	}
	
	return [namespaceNode stringValue];
}

@end
