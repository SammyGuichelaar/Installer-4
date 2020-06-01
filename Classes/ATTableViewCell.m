//
//  ATTableViewCell
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import "ATTableViewCell.h"

static UIColor* gSeparatorColor = nil;
static UIColor* gBottomSeparatorColor = nil;

@implementation ATTableViewCell

- (void)setOdd:(BOOL)isOdd
{
	odd = isOdd;
	
	
	if (!odd)
		bg = [UIColor colorWithRed:.6 green:.6 blue:.61 alpha:1];
	else
		bg = [UIColor colorWithRed:.68 green:.68 blue:.69 alpha:1];
		
	
	
	[self setNeedsDisplay];
}

- (BOOL)odd
{
	return odd;
}


#pragma mark -

- (void) drawRect:(CGRect)Rect
{
	if (!bg)
        self.odd = NO; bg = [[UIColor alloc] initWithWhite:1 alpha:1];
		
	[bg set];
	UIRectFill(Rect);

	[super drawRect:Rect];
	
	// draw a line
	
	if (!gSeparatorColor)
		gSeparatorColor = [[UIColor alloc] initWithRed:.73 green:.73 blue:.74 alpha:1.];
		
	[gSeparatorColor set];
	UIRectFrame(CGRectMake(0, Rect.origin.y, Rect.size.width, 1));
	
	if (!gBottomSeparatorColor)
		gBottomSeparatorColor = [[UIColor alloc] initWithRed:.53 green:.54 blue:.55 alpha:1.];
	
	[gBottomSeparatorColor set];
	UIRectFrame(CGRectMake(0, Rect.origin.y + Rect.size.height - 1, Rect.size.width, 1));
}

@end
