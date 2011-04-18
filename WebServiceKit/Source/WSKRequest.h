//
//  WSKRequest.h
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-16.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSKResponse;

@interface WSKRequest : NSOperation {
@private
	BOOL finished;
	BOOL executing;
	
	NSMutableData *responseData;
	
	NSURLConnection *urlConnection;
	NSMutableURLRequest *urlRequest;
	
	NSURL *url;
}

+ (WSKRequest *)requestWithURL:(NSURL *)aURL;

- (id)initWithURL:(NSURL *)aURL;

@end
