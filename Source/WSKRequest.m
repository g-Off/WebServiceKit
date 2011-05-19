//
//  WSKRequest.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-16.
//  Copyright 2011 . All rights reserved.
//

#import "WSKRequest.h"
#import "WSKResponse.h"

@interface WSKRequest (NSURLConnectionDelegate) <NSURLConnectionDelegate>

- (void)requestFinishedWithResponse:(WSKResponse *)response;

@end

@implementation WSKRequest

@synthesize url;
@synthesize responseClass;
@synthesize urlRequest;
@synthesize delegate;
@synthesize responseData;
#if NS_BLOCKS_AVAILABLE
@synthesize responseHandler;
#endif

+ (WSKRequest *)request
{
	return [[[[self class] alloc] init] autorelease];
}

+ (WSKRequest *)requestWithURL:(NSURL *)aURL
{
	return [[[[self class] alloc] initWithURL:aURL] autorelease];
}

+ (WSKRequest *)requestWithURL:(NSURL *)aURL delegate:(id)aDelegate
{
	WSKRequest *request = [self requestWithURL:aURL];
	[request setDelegate:aDelegate];
	return request;
}

#if NS_BLOCKS_AVAILABLE
+ (WSKRequest *)requestWithURL:(NSURL *)aURL responseHandler:(WSKRequestResponseBlock)aResponseHandler
{
	WSKRequest *request = [self requestWithURL:aURL];
	[request setResponseHandler:aResponseHandler];
	return request;
}
#endif

- (id)init
{
	if ((self = [super init])) {
		urlRequest = [[NSMutableURLRequest alloc] init];
		responseClass = [WSKResponse class];
	}
	
	return self;
}

- (id)initWithURL:(NSURL *)aURL
{
	if ((self = [self init])) {
		url = [aURL retain];
		[urlRequest setURL:url];
	}
	
	return self;
}

- (void)dealloc
{
	delegate = nil;
	
	[url release];
	[responseData release];
	[urlRequest release];
	[urlConnection release];
	
	delegate = nil;
	
#if NS_BLOCKS_AVAILABLE
	[responseHandler release];
#endif
	
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
	// TODO: handle this case
	NSLog(@"%s - %@", __PRETTY_FUNCTION__, response);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// TODO: handle this case
	NSLog(@"%s - %@", __PRETTY_FUNCTION__, error);
	
	[self willChangeValueForKey:@"isExecuting"];
	executing = NO;
	[self didChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	finished = YES;
	[self didChangeValueForKey:@"isFinished"];
	
	WSKResponse *response = [[[responseClass alloc] init] autorelease];
	[response setError:error];
	[self requestFinishedWithResponse:response];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
	
	[self willChangeValueForKey:@"isExecuting"];
	executing = NO;
	[self didChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	finished = YES;
	[self didChangeValueForKey:@"isFinished"];
	
	WSKResponse *response = [[[responseClass alloc] initWithRequest:self] autorelease];
	[self requestFinishedWithResponse:response];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

- (void)requestFinishedWithResponse:(WSKResponse *)response
{
#if NS_BLOCKS_AVAILABLE
	if (responseHandler) {
		responseHandler(self, response);
	} else
#endif
	{
		if (delegate && [delegate respondsToSelector:@selector(request:didFinishWithResponse:)]) {
//			[delegate request:self didFinishWithResponse:response];
		}
	}
}

@end
