//
//  WSKSoapService.h
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-18.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebServiceKit/WSKService.h>

@interface WSKSoapService : WSKService {
@private
    NSURL *serviceURL;
}

+ (WSKSoapService *)serviceWithURL:(NSURL *)aURL;

- (id)initWithServiceURL:(NSURL *)aURL;

- (void)callAction:(NSString *)action withObjects:(NSArray *)objects andKeys:(NSArray *)keys;
- (void)callAction:(NSString *)action withObjects:(const id [])objects andKeys:(const id [])keys count:(NSUInteger)cnt;
- (void)callAction:(NSString *)action withArgumentsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

@end
