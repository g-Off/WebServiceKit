//
//  WSKService.h
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-16.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSKRequest;

@interface WSKService : NSObject {
@private
    NSOperationQueue *requestQueue;
}

- (void)sendRequest:(WSKRequest *)aRequest;

@end
