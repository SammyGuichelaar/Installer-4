//
//  ATRatingView.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <stdio.h>
#include <stdlib.h> //For malloc
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
@interface ATRatingView : UIView {
	IBOutlet id		delegate;
	
	IBOutlet UIView*		popupView;
	IBOutlet UIImageView*	popup1;
	IBOutlet UIImageView*	popup2;
	IBOutlet UIImageView*	popup3;
	IBOutlet UIImageView*	popup4;
	IBOutlet UIImageView*	popup5;
	
	float			userRating;
	float			myRating;
	float			previousRating;
	
	@private
		UIImage*		mMask;
		UIImage*		mBackground;
		UIImage*		mMyStars;
		UIImage*		mUserStars;
		
		CGFloat			mStarWidth;
}

@property (nonatomic, assign) float userRating;
@property (nonatomic, assign) float myRating;

- (void)adjustRating:(UITouch*)touch;

@end
