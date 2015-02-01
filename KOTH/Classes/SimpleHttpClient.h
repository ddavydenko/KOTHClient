//
//  SimpleHttpClient.h
//  KOTH
//
//  Created by Denis Davydenko on 12/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^RequestSuccessResultBlock)(NSString *responseString);
typedef void (^RequestFailedResultBlock)(NSError *error);

@interface SimpleHttpClient : NSObject {
	
@private
	NSMutableData *responseData_;
	RequestSuccessResultBlock successResultBlock_;
	RequestFailedResultBlock failedResultBlock_;
}

+(SimpleHttpClient*)requestUrl:(NSString*)url withBlock:(RequestSuccessResultBlock)block 
				 andErrorBlock:(RequestFailedResultBlock)errorBlock;

-(SimpleHttpClient*)initWithUrl:(NSString*)url andWithBlock:(RequestSuccessResultBlock)block 
				  andErrorBlock:(RequestFailedResultBlock)errorBlock;

@end
