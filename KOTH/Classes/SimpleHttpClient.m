//
//  SimpleHttpClient.m
//  KOTH
//
//  Created by Denis Davydenko on 12/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SimpleHttpClient.h"


@interface SimpleHttpClient(Private)


@end


@implementation SimpleHttpClient

+(SimpleHttpClient*)requestUrl:(NSString*)url withBlock:(RequestSuccessResultBlock)block 
	andErrorBlock:(RequestFailedResultBlock)errorBlock
{
	return [[self alloc] initWithUrl:url andWithBlock:block andErrorBlock:errorBlock];
}

-(SimpleHttpClient*)initWithUrl:(NSString*)url andWithBlock:(RequestSuccessResultBlock)block 
				  andErrorBlock:(RequestFailedResultBlock)errorBlock
{
	if ((self = [super init])) {
		successResultBlock_ = _Block_copy(block);
		failedResultBlock_ = _Block_copy(errorBlock);
		responseData_ = [[NSMutableData data] retain];
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] 
												 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
		[[NSURLConnection alloc] initWithRequest:request delegate:self];
	}
	
	return self;
}

-(void)dealloc
{
	_Block_release(successResultBlock_);
	_Block_release(failedResultBlock_);
	[responseData_ release];
	[super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData_ setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData_ appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (failedResultBlock_) {
		failedResultBlock_(error);
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *str = [[[NSString alloc] initWithBytes:[responseData_ bytes] length:[responseData_ length] 
											encoding: NSUTF8StringEncoding] autorelease];
	if (successResultBlock_) {
		successResultBlock_(str);
	}
}


@end
