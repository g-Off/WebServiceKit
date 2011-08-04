//
//  WSKSoapResponse.h
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-24.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebServiceKit/WSKResponse.h>

@class WSKSoapFault;

@interface WSKSoapResponse : WSKResponse {
@private
	NSXMLDocument *soapDocument;
	WSKSoapFault *fault;
	
	id result;
}

@property (readonly) id result;
@property (readonly) WSKSoapFault *fault;

- (BOOL)isSOAPFault;

@end
