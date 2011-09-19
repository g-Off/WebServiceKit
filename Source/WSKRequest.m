//
//  WSKRequest.m
//  WebServiceKit
//
//  Created by Geoffrey Foster on 11-04-16.
//  Copyright 2011 . All rights reserved.
//

#import "WSKRequest.h"
#import "WSKResponse.h"

@interface WSKRequest ()

@property (nonatomic, assign, getter = isExecuting) BOOL executing;
@property (nonatomic, assign, getter = isFinished) BOOL finished;

@end

@interface WSKRequest (NSURLConnectionDelegate) <NSURLConnectionDelegate>

- (void)requestFinishedWithResponse:(WSKResponse *)response;

@end

@implementation WSKRequest

@synthesize executing;
@synthesize finished;

@synthesize url;
@synthesize responseClass;
@synthesize urlRequest;
@synthesize responseData;
@synthesize responseHandler;
@synthesize response;

+ (WSKRequest *)request
{
	return [self requestWithURL:nil];
}

+ (WSKRequest *)requestWithURL:(NSURL *)aURL
{
	return [self requestWithURL:aURL responseHandler:NULL];
}

+ (WSKRequest *)requestWithURL:(NSURL *)aURL responseHandler:(WSKResponseBlock)aResponseHandler
{
	WSKRequest *request = [[[self class] alloc] initWithURL:aURL];
	[request setResponseHandler:aResponseHandler];
	return [request autorelease];
}

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
		if (url) {
			[urlRequest setURL:url];
		}
	}
	
	return self;
}

- (void)dealloc
{
	[url release];
	[responseData release];
	[urlRequest release];
	[urlConnection release];
	[responseHandler release];
	[response release];
	
	[super dealloc];
}

- (BOOL)isConcurrent
{
	return YES;
}

- (void)start
{
	[self setExecuting:YES];
	responseData = [[NSMutableData alloc] init];
	urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
	[urlConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[urlConnection start];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// TODO: handle this case
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self setExecuting:NO];
	
	response = [[responseClass alloc] init];
	[response setError:error];
	[self requestFinishedWithResponse:response];
	
	[self setFinished:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self setExecuting:NO];
	
	response = [[responseClass alloc] initWithRequest:self];
	[self requestFinishedWithResponse:response];
	
	[self setFinished:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

- (void)requestFinishedWithResponse:(WSKResponse *)aResponse
{
	if (responseHandler) {
		responseHandler(response);
	}
}

#pragma mark -
#pragma mark Private Methods

- (void)setExecuting:(BOOL)isExecuting
{
	[self willChangeValueForKey:@"isExecuting"];
	executing = isExecuting;
	[self didChangeValueForKey:@"isExecuting"];
}
- (void)setFinished:(BOOL)isFinished
{
	[self willChangeValueForKey:@"isFinished"];
	finished = isFinished;
	[self didChangeValueForKey:@"isFinished"];
}

@end
