//
//  CCLabelTTFx
//  KOTH
//
//  Created by Denis Davydenko on 10/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CCLabelTTFx.h"


@implementation CCLabelTTFx

+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [[[self alloc] initWithString: string dimensions:dimensions alignment:alignment fontName:name fontSize:size]autorelease];
}

+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [[[self alloc] initWithString: string fontName:name fontSize:size]autorelease];
}

- (void) setString:(NSString*)str
{
	if (![currentString_ isEqualToString:str]) {
		[currentString_ release];
		currentString_ = [str retain];
		[super setString:str];
		
		if (shadowLabel_) {
			[shadowLabel_ setString:str];
		}
		
		if (borderLabel_) {
			[borderLabel_ setString:str];
		}
	}
}

-(void)setShadowWithColor:(ccColor3B)color andOpacity:(GLubyte)opacity andOffset:(CGSize)offset
{
	if (shadowLabel_) {
		[shadowLabel_ removeFromParentAndCleanup:YES];
		[shadowLabel_ release];
	}
	
	shadowLabel_ = [[CCLabelTTFx labelWithString:currentString_ fontName:fontName_ fontSize:fontSize_] retain];
	shadowLabel_.position = ccp(position_.x + offset.width, position_.y + offset.height);
	shadowLabel_.color = color;
	shadowLabel_.anchorPoint = anchorPoint_;
	shadowLabel_.opacity = opacity;
	
	[parent_ addChild:shadowLabel_ z:[self zOrder] - 1];
}

-(void)setBorderWithColor:(ccColor3B)color andOpacity:(GLubyte)opacity andThickness:(CGFloat)thinkness
{
	if (borderLabel_) {
		[borderLabel_ removeFromParentAndCleanup:YES];
		[borderLabel_ release];
	}
	
	borderLabel_ = [[CCLabelTTFx labelWithString:currentString_ fontName:fontName_ fontSize:fontSize_ + thinkness*2] retain];
	borderLabel_.position = ccp(position_.x, position_.y);
	borderLabel_.color = color;
	borderLabel_.opacity = opacity;
	
	[parent_ addChild:borderLabel_];
}

- (void) dealloc
{
	[currentString_ release];
	[shadowLabel_ release];
	[borderLabel_ release];
	[super dealloc];
}


@end
