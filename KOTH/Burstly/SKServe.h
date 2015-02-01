//
//  SKServe.h
//  SKServe
//
//  Created by Nikolay Remizevich on 20.10.09.
//  Copyright 2009 App Media Group, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKServeDelegateProtocol.h"


@interface SKServe : NSObject {

}

+ (void)initializeWithDelegate:(NSObject<SKServeDelegate>*)delegate;
+ (bool)handleUrl:(NSURL*)url;


@end
