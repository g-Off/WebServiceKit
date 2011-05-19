//
//  WSKSoapService.h
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-18.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebServiceKit/WSKService.h>

extern NSString * const WSKSoap12EnvelopeURI;
extern NSString * const WSKSoap12EncodingURI;
extern NSString * const WSKSoapRPCURI;

@interface WSKSoapService : WSKService {
@private
    NSURL *serviceURL;
	NSMutableDictionary *namespaces;
}

+ (WSKSoapService *)serviceWithURL:(NSURL *)aURL;

- (id)initWithServiceURL:(NSURL *)aURL;

- (void)addURI:(NSString *)uri forNamespace:(NSString *)ns;

// TODO: need requestWithAction that has a namespace variant
- (WSKRequest *)requestWithAction:(NSString *)action withObjects:(NSArray *)objects andKeys:(NSArray *)keys;
- (WSKRequest *)requestWithAction:(NSString *)action withObjects:(const id [])objects andKeys:(const id [])keys count:(NSUInteger)cnt;
- (WSKRequest *)requestWithAction:(NSString *)action withArgumentsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

@end