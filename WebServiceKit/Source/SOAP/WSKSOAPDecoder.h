//
//  WSKSOAPDecoder.h
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-17.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WSKSOAPDecoder : NSCoder {
@private
	NSMutableArray *nodeStack;
}

+ (id)unarchiveObjectWithRoot:(NSXMLElement *)element;

- (id)initWithRootObject:(NSXMLElement *)element;

+ (void)setClass:(Class)cls forName:(NSString *)elementName withNamespace:(NSString *)aNamespace;
+ (Class)classForName:(NSString *)elementName withNamespace:(NSString *)aNamespace;

@end
