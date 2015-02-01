//
//  CCLabelTTFx.h
//  KOTH
//
//  Created by Denis Davydenko on 10/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface CCLabelTTFx : CCLabelTTF {
	
@private
	NSString *currentString_;
	
	CCLabelTTFx *shadowLabel_;
	CCLabelTTFx *borderLabel_;
}

/** creates a CCLabel from a fontname, alignment, dimension in points and font size in points*/
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
/** creates a CCLabel from a fontname and font size in points*/
+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size;

-(void)setShadowWithColor:(ccColor3B)color andOpacity:(GLubyte)opacity andOffset:(CGSize)offset;
-(void)setBorderWithColor:(ccColor3B)color andOpacity:(GLubyte)opacity andThickness:(CGFloat)thinkness;

@end
