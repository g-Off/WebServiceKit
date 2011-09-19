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

extern NSString * const WSKSoapErrorDomain;
extern NSString * const WSKSoapFaultKey;

@class WSKSoapRequest;
@class WSKSoapResponse;

typedef void(^WSKSoapResponseHandler)(WSKSoapResponse *response, id obj, NSError *error);

@interface WSKSoapService : WSKService {
@private
    NSURL *serviceURL;
	NSMutableDictionary *namespaces;
}

@property (readwrite, nonatomic, copy) NSURL *serviceURL;

+ (WSKSoapService *)serviceWithURL:(NSURL *)aURL;

- (id)initWithServiceURL:(NSURL *)aURL;

- (void)addURI:(NSString *)uri forNamespace:(NSString *)ns;

// TODO: need requestWithAction that has a namespace variant
- (WSKSoapRequest *)requestWithAction:(NSString *)action withObjects:(NSArray *)objects andKeys:(NSArray *)keys;
- (WSKSoapRequest *)requestWithAction:(NSString *)action withObjects:(const id [])objects andKeys:(const id [])keys count:(NSUInteger)cnt;
- (WSKSoapRequest *)requestWithAction:(NSString *)action withArgumentsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

- (void)performRequest:(WSKSoapRequest *)request withSoapResponseHandler:(WSKSoapResponseHandler)handler;

@end