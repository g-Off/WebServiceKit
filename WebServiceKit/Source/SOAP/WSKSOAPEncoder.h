//
//  WSKSOAPEncoder.h
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-17.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSKSOAPEncoder;

@protocol WSKSOAPEncoderDelegate <NSObject>

- (NSString *)encoder:(WSKSOAPEncoder *)encoder wantsNameForClass:(Class)cls;

@end

@interface WSKSOAPEncoder : NSCoder {
@private
    NSXMLElement *rootElement;
	NSXMLElement *currentElement;
	
	id delegate;
}

@property (readwrite, assign) id delegate;
@property (readonly) NSXMLElement *rootElement;

@end
