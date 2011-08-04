//
//  WSKSoapFault.h
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-25.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WSKSoapFault : NSObject {
@private
	NSString *faultCode;
	NSString *faultString;
}

@property (readonly) NSString *faultCode;
@property (readonly) NSString *faultString;

@end
