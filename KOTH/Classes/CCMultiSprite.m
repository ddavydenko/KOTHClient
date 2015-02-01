//
//  CCMultiSprite.m
//  KOTH
//
//  Created by Denis Davydenko on 11/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CCMultiSprite.h"


@implementation CCMultiSprite

@synthesize currentSprite  = currentSprite_;

-(void)addChild:(CCSprite *)child tag:(int)aTag
{
	child.tag = aTag;
	[super addChild:child];
	
	self.currentSpriteTag = aTag;
}

-(int)currentSpriteTag
{
	return currentSprite_ ? currentSprite_.tag : -1;
}

-(void)setCurrentSpriteTag:(int)tag
{
	for( CCSprite *child in children_ )
	{
		if (child.tag == tag)
			currentSprite_ = child;
			
		child.visible = (child.tag == tag);
	}
}

-(void)setFlipX:(BOOL)fX
{
	[super setFlipX:fX];
	for( CCSprite *child in children_ )
		child.flipX = fX;
}



@end
