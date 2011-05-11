//
//  NSXMLElement+WebServiceKit.h
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-23.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSXMLElement (WebServiceKit)

+ (id)elementWithName:(NSString *)name prefix:(NSString *)prefix URI:(NSString *)uri;

@end
