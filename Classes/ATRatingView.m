//
//  ATRatingView.m
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import "ATRatingView.h"
#include <stdlib.h> //For malloc

@implementation ATRatingView

@synthesize userRating;
@synthesize myRating;

- (void)drawRect:(CGRect)rect {
    // Preheat graphics
	
	if (!mMask)
		mMask = [UIImage imageNamed:@"ATRatingMask.png"];
		
	if (!mBackground)
		mBackground = [UIImage imageNamed:@"ATRatingBackground.png"];
		
	if (!mMyStars)
		mMyStars = [UIImage imageNamed:@"ATRatingMyStars.png"];
	
	if (!mUserStars)
		mUserStars = [UIImage imageNamed:@"ATRatingUserStars.png"];
	
	if (!mStarWidth)
		mStarWidth = ceil(mMask.size.width / 5.);

	CGRect r = rect;
	r.size = mBackground.size;
	CGSize sz = r.size;
	
	UIImage* compositedImage = nil;
	
	CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
	
    bitmapBytesPerRow   = sz.width * 4;
    bitmapByteCount     = bitmapBytesPerRow * sz.height;
	
    colorSpace = CGColorSpaceCreateDeviceRGB();
    bitmapData = malloc(bitmapByteCount);
    if (bitmapData != NULL)
    {
		context = CGBitmapContextCreate (bitmapData,
										 sz.width,
										 sz.height,
										 8,      // bits per component
										 bitmapBytesPerRow,
										 colorSpace,
										 kCGImageAlphaPremultipliedLast);
										 
		if (context != NULL)
		{
			CGContextClearRect(context, r);
						
			if (mMask)
			{
				CGContextClipToMask(context, r, [mMask CGImage]);
			}

			CGContextDrawImage(context, r, [mBackground CGImage]);
			
			if (self.userRating > 0)
			{
				// Now create subcontexts for our and user stars.
				CGRect userStarsRect = r;
				userStarsRect.size.width = ceil(mStarWidth * self.userRating);
				CGImageRef userStarsImage = CGImageCreateWithImageInRect([mUserStars CGImage], userStarsRect);
				if (userStarsImage)
				{
					CGContextDrawImage(context, userStarsRect, userStarsImage);
					CGImageRelease(userStarsImage);
				}
			}

			if (self.myRating > 0)
			{
				// And overlay the user stars with our stars
				CGRect myStarsRect = r;
				myStarsRect.size.width = ceil(mStarWidth * self.myRating);
				//myStarsRect.origin.y += userStarsRect.size.height / 2;
				//myStarsRect.size.height = ceil(myStarsRect.size.height/2);
				
				CGImageRef myStarsImage = CGImageCreateWithImageInRect([mMyStars CGImage], myStarsRect);
				if (myStarsImage)
				{
					CGContextDrawImage(context, myStarsRect, myStarsImage);
					CGImageRelease(myStarsImage);
				}
			}

			// Grab final image
			CGImageRef bImage = CGBitmapContextCreateImage(context);
			compositedImage = [[UIImage alloc] initWithCGImage:bImage];
			CGContextRelease(context);
			CGImageRelease(bImage);
		}

		free(bitmapData);
	}
	
	CGColorSpaceRelease(colorSpace);

	[compositedImage drawInRect:r];
}




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	previousRating = 0;
	// Show the helper bubble
	UITouch* touch = [[touches allObjects] objectAtIndex:0];
	
	popupView.alpha = 0.;
	CGPoint center = [touch locationInView:self.superview];
	center.y = self.frame.origin.y - popupView.frame.size.height/4;
	popupView.center = center;
	
	[self.superview addSubview:popupView];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.2];
	
	popupView.alpha = 1.;
	[self adjustRating:touch];
	
	[UIView commitAnimations];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [[touches allObjects] objectAtIndex:0];

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.2];
	
	CGPoint center = [touch locationInView:self.superview];
	center.y = self.frame.origin.y - popupView.frame.size.height/4;
	
	if (center.x < self.frame.origin.x-8)
		center.x = self.frame.origin.x-8;
	else if (center.x > self.frame.origin.x + self.frame.size.width)
		center.x = self.frame.origin.x + self.frame.size.width;
	
	popupView.center = center;

	[self adjustRating:touch];
	
	[UIView commitAnimations];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(popupViewDidDisappear:finished:context:)];
	
	popupView.alpha = 0.;
	
	[UIView commitAnimations];
}

- (void)popupViewDidDisappear:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[popupView removeFromSuperview];
    SEL ratingChanged = NSSelectorFromString(@"ratingChanged");
	if (delegate && [delegate respondsToSelector:ratingChanged])
		[delegate performSelector:ratingChanged withObject:[NSNumber numberWithFloat:myRating]];
}

- (void)adjustRating:(UITouch*)touch
{
	CGPoint location = [touch locationInView:self];
	float rat = 0;
	
	if (location.x > 0)
	{
		if (location.x > (mStarWidth*5))
			rat = 5;
		else
			rat = ceil(location.x/mStarWidth);
	}
	
	myRating = rat;
	
	if (previousRating != myRating)
	{
		int iRating = myRating;
		
		popup1.alpha = 0;
		popup2.alpha = 0;
		popup3.alpha = 0;
		popup4.alpha = 0;
		popup5.alpha = 0;
		
		if (iRating == 1)
			popup1.alpha = 1;
		else if (iRating == 2)
			popup2.alpha = 1;
		else if (iRating == 3)
			popup3.alpha = 1;
		else if (iRating == 4)
			popup4.alpha = 1;
		else if (iRating == 5)
			popup5.alpha = 1;
			
		previousRating = myRating;
	}
		
	[self setNeedsDisplay];
}

@end
