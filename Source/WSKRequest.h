//
//  WSKRequest.h
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-16.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSKResponse;
@class WSKRequest;

#if NS_BLOCKS_AVAILABLE
typedef void(^WSKResponseBlock)(WSKResponse *response);
#endif

@protocol WSKRequestDelegate <NSObject>

- (void)request:(WSKRequest *)request didFinishWithResponse:(WSKResponse *)response;

@end

@interface WSKRequest : NSOperation {
@private
	NSMutableData *responseData;
	
	NSURLConnection *urlConnection;
}

@property (retain) NSURL *url;
@property (assign) Class responseClass;
@property (readonly) NSMutableURLRequest *urlRequest;
@property (readonly) NSData *responseData;
@property (readonly) WSKResponse *response;
@property (copy) WSKResponseBlock responseHandler;

+ (WSKRequest *)request;
+ (WSKRequest *)requestWithURL:(NSURL *)aURL;
+ (WSKRequest *)requestWithURL:(NSURL *)aURL responseHandler:(WSKResponseBlock)aResponseHandler;

- (id)initWithURL:(NSURL *)aURL;

@end
