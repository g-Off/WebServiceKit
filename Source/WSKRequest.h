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
	Class responseClass;
	
	BOOL finished;
	BOOL executing;
	
	NSMutableData *responseData;
	
	NSURLConnection *urlConnection;
	NSMutableURLRequest *urlRequest;
	
	NSURL *url;
	
	__weak id delegate;
	
#if NS_BLOCKS_AVAILABLE
	WSKResponseBlock responseHandler;
#endif
}

@property (readwrite, nonatomic, retain) NSURL *url;
@property (readwrite, nonatomic, assign) Class responseClass;
@property (readonly) NSMutableURLRequest *urlRequest;
@property (readwrite, nonatomic, assign) id delegate;
@property (readonly) NSData *responseData;
#if NS_BLOCKS_AVAILABLE
@property (readwrite, nonatomic, copy) WSKResponseBlock responseHandler;
#endif

+ (WSKRequest *)request;
+ (WSKRequest *)requestWithURL:(NSURL *)aURL;
+ (WSKRequest *)requestWithURL:(NSURL *)aURL delegate:(id)aDelegate;
#if NS_BLOCKS_AVAILABLE
+ (WSKRequest *)requestWithURL:(NSURL *)aURL responseHandler:(WSKResponseBlock)aResponseHandler;
#endif

- (id)initWithURL:(NSURL *)aURL;

@end
