//
//  WSKSoapRequest.h
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-05-10.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebServiceKit/WSKRequest.h>

@interface WSKSoapRequest : WSKRequest {
@private
    NSString *action;
	NSString *requestNamespace;
}

@property (readonly, nonatomic, copy) NSString *action;
@property (readonly, nonatomic, copy) NSString *requestNamespace;

+ (WSKSoapRequest *)requestWithAction:(NSString *)anAction;
+ (WSKSoapRequest *)requestWithAction:(NSString *)anAction URL:(NSURL *)aURL;

@end
