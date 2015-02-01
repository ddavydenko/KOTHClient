/*
 
 Copyright 2009 App Media Group LLC.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

#import "OAIAdManagerDelegateProtocol.h"
@class OAIAutoRefreshManager,OAIAdNetworkController,OAINetworkControllerFactory;

@interface OAIAdManager : NSObject {
	@private id<OAIAdManagerDelegate>	_delegate;
	@private OAIAutoRefreshManager		*_autoRefreshManager;
	@private BOOL _cachedRequest;
	@private BOOL _haveReceivedAds;
	@private NSString	*_cachedNetworkName;
	@private BOOL _isPrecachingAd;
	@private BOOL _havePrecachedAd;
	@private OAIAdNetworkController* _precachedController;
	@private id _currentView;
	UIView	*view;
	CGSize	prevViewSize;
	CGSize	currentViewSize;
	OAINetworkControllerFactory	*factory;
	id		coreManager;
}


- (void)awakeFromNib;
- (id)initWithDelegate:(id<OAIAdManagerDelegate>)aDelegate;
- (void)requestRefreshAd;
- (void)precacheAd;
- (void)updateView;
- (void)setPaused:(BOOL)isPaused;
- (BOOL)isPaused;
- (UIDeviceOrientation)currentOrientation;
- (void)enableWatchdogWithTimeout:(NSTimeInterval)timeout;
- (void)disableWatchdog;
- (void)setGSDownloadDelayInterval:(float)interval; // from 0.03 to 1.0. Higher value means slower.


@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) id<OAIAdManagerDelegate> delegate;
@end
