//
//  WSKKeyedUnarchiver.h
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-07-31.
//  Copyright 2011 g-Off.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSKKeyedUnarchiver : NSCoder {
	id rootObject;
	NSMutableArray *objectStack;
}

+ (id)unarchiveObjectWithObject:(id)obj;

- (id)initWithObject:(id)obj;

@end
