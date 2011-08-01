//
//  WSKKeyedArchiver.h
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-07-31.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSKKeyedArchiver : NSCoder {
	NSMutableDictionary *_root;
	NSMutableDictionary *_current;
}

+ (BOOL)archiveRootObject:(id)rootObject toFile:(NSString *)path;
- (void)encodeRootObject:(id)rootObject;
- (id)rootObject;

@end
