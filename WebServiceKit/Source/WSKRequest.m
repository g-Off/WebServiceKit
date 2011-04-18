//
//  WSKRequest.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-16.
//  Copyright 2011 . All rights reserved.
//

#import "WSKRequest.h"

@interface WSKRequest (NSURLConnectionDelegate) <NSURLConnectionDelegate>
@end

@implementation WSKRequest

+ (WSKRequest *)requestWithURL:(NSURL *)aURL
{
	return [[[[self class] alloc] initWithURL:aURL] autorelease];
}

- (id)initWithURL:(NSURL *)aURL
{
	if ((self = [super init])) {
		url = [aURL retain];
	}
	
	return self;
}

- (void)dealloc
{
	[url release];
	[responseData release];
	[urlRequest release];
	[urlConnection release];
	
	[super dealloc];
}

- (BOOL)isFinished
{
	return finished;
}

- (BOOL)isConcurrent
{
	return YES;
}

- (BOOL)isExecuting
{
	return executing;
}

- (void)start
{
	responseData = [[NSMutableData alloc] init];
	urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
	urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
	[urlConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]  forMode:NSDefaultRunLoopMode];
	[urlConnection start];
	[self willChangeValueForKey:@"isExecuting"];
	executing = YES;
	[self didChangeValueForKey:@"isExecuting"];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"%s - %@", __PRETTY_FUNCTION__, response);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"%s - %@", __PRETTY_FUNCTION__, error);
	
	[self willChangeValueForKey:@"isExecuting"];
	executing = NO;
	[self didChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	finished = YES;
	[self didChangeValueForKey:@"isFinished"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	//NSError *error = nil;
	//NSXMLDocument *xmlDocument = [[NSXMLDocument alloc] initWithData:responseData options:<#(NSUInteger)#> error:&error];
	NSLog(@"%s - %@", __PRETTY_FUNCTION__, responseData);
	
	[self willChangeValueForKey:@"isExecuting"];
	executing = NO;
	[self didChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	finished = YES;
	[self didChangeValueForKey:@"isFinished"];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

@end
