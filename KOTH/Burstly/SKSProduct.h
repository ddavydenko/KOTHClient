//
//  SKSProduct.h
//  SKServe
//
//  Created by Nikolay Remizevich on 20.10.09.
//  Copyright 2009 App Media Group, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


@interface SKSProduct : NSObject {
	NSString*				_productId;
	NSData*					_receipt;
	SKPaymentTransaction*	_transaction;
	NSString*				_title;
	NSString*				_description;
	NSString*				_localizedPrice;
	NSString*				_previewImageUrl;
	NSDecimalNumber*		_price;
}

@property (nonatomic, retain) NSString*				productId;
@property (nonatomic, retain) NSData*				receipt;
@property (nonatomic, retain) SKPaymentTransaction*	transaction;
@property (nonatomic, retain) NSString*				title;
@property (nonatomic, retain) NSString*				description;
@property (nonatomic, retain) NSString*				localizedPrice;
@property (nonatomic, retain) NSString*				previewImageUrl;
@property (nonatomic, retain) NSDecimalNumber*		price;


@end
