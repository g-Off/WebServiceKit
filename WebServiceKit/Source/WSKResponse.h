//
//  WSKResponse.h
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-16.
//  Copyright 2011 . All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSKRequest;

@interface WSKResponse : NSObject {
	NSData *data;
	NSError *error;
	WSKRequest *request;
}

@property (readwrite, nonatomic, retain) NSError *error;
@property (readonly) WSKRequest *request;

- (id)initWithRequest:(WSKRequest *)aRequest;

@end
