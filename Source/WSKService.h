//
//  WSKService.h
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-16.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSKRequest;
@class WSKResponse;

@interface WSKService : NSObject {
@private
    NSOperationQueue *requestQueue;
}

- (void)sendRequest:(WSKRequest *)aRequest;

- (void)performRequest:(WSKRequest *)request;
- (void)performRequest:(WSKRequest *)request target:(id)aTarget action:(SEL)anAction;
- (void)performRequest:(WSKRequest *)request delegate:(id)aDelegate;
#if NS_BLOCKS_AVAILABLE
- (void)performRequest:(WSKRequest *)request withResponseHandler:(void (^)(WSKResponse *response))handler;
#endif

@end
