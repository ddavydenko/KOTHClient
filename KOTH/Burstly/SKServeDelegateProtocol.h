//
//  SKServeDelegateProtocol.h
//  SKServe
//
//  Created by Nikolay Remizevich on 20.10.09.
//  Copyright 2009 App Media Group, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKSProduct.h"


@protocol SKServeDelegate

- (void)productPurchased:(SKSProduct*)product;

@optional

- (UIViewController*)viewControllerForModalPresentation;	/* Required unless you use your own UI */


- (bool)showBuiltinUI;

- (void)requestingForProductInfo:(SKSProduct*)product;
- (void)failedToGetProductInfo:(SKSProduct*)product;
- (void)purchaceCancelled:(SKSProduct*)product;
- (void)purchaseFailed:(SKSProduct*)product;
- (void)verificationStarted:(SKSProduct*)product;
- (void)verificationFailed:(SKSProduct*)product;
- (void)downloadStarted:(SKSProduct*)product;
- (void)setDownloadProgress:(float)progress forProduct:(SKSProduct*)product;
- (void)downloadFailed:(SKSProduct*)product;
- (void)decompressionStarted:(SKSProduct*)product;

@end
