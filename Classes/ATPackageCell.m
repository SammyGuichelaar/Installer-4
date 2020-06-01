//
//  ATPackageCell.m
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import "ATPackageCell.h"

//UIImage *backShadowImage = nil;
//bool needsIcon = NO;

UIFont* gDescriptionFont = nil;

@implementation ATPackageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier package:(ATPackage*)pack{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		// Initialization code
	
		//if(backShadowImage == nil)
		//	backShadowImage = [UIImage imageNamed:@"ATPCBackShadow.png"];
		
		//UIImageView *backShadowImageView = [[UIImageView alloc] initWithImage:backShadowImage];
		//self.backgroundView = backShadowImageView;
		

//		if (icon == nil)
//			icon = [UIImage imageNamed:@"SampleIcon.png"]; // <- testing
		
		iconView = [[ATIconView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
		
		packageNameView = [[UILabel alloc] initWithFrame:CGRectMake(80, 1, 180, 24)];
		packageDescriptionView = [[UILabel alloc] initWithFrame:CGRectMake(80, 20, 210, 59)];
		
		[packageNameView setTextColor:[UIColor blackColor]];
		
		[packageNameView setFont:self.textLabel.font];
		packageNameView.adjustsFontSizeToFitWidth = YES;
		packageNameView.numberOfLines = 1;
        packageNameView.minimumScaleFactor = 9.0 / [UIFont labelFontSize];
		packageNameView.shadowColor = [UIColor colorWithWhite:0.8 alpha:1.];
		packageNameView.shadowOffset = CGSizeMake(0,1);
		
		if (!gDescriptionFont)
			gDescriptionFont = [UIFont fontWithName:@"Helvetica" size:12];
			
		UIFont *fontDescr = gDescriptionFont;
		//[packageDescriptionView setTextColor:[UIColor colorWithRed:.15 green:.3 blue:.45 alpha:1]];
		[packageDescriptionView setTextColor:[UIColor blackColor]];
		[packageDescriptionView setFont:fontDescr];
		packageDescriptionView.numberOfLines = 3;
		packageDescriptionView.shadowColor = [UIColor colorWithWhite:0.8 alpha:1.];
		packageDescriptionView.shadowOffset = CGSizeMake(0,1);
		
		packageVersionView = [[UILabel alloc] initWithFrame:CGRectMake(270, 1, 50, 25)];
		[packageVersionView setTextColor:[UIColor colorWithRed:.45 green:.3 blue:.15 alpha:1]];
		packageVersionView.shadowColor = [UIColor colorWithWhite:0.8 alpha:1.];
		packageVersionView.shadowOffset = CGSizeMake(0,1);
		
		//packageVersionView.textAlignment = UITextAlignmentRight;

		packageDescriptionView.backgroundColor = [UIColor clearColor];
		packageNameView.backgroundColor = [UIColor clearColor];
		packageVersionView.backgroundColor = [UIColor clearColor];

		[packageVersionView setFont:fontDescr];
		
		[self.contentView addSubview:iconView];
		[self.contentView addSubview:packageDescriptionView];
		[self.contentView addSubview:packageNameView];
		[self.contentView addSubview:packageVersionView];
		
		isIndicatorShown = NO;
		indicator = nil;
		
		self.package = pack;
	}
	
	return self;
}

- (void)setOdd:(BOOL)isOdd
{
	[super setOdd:isOdd];
	
	//packageDescriptionView.backgroundColor = bg;
	//packageNameView.backgroundColor = bg;
	//packageVersionView.backgroundColor = bg;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<ATPackageCell: 0x%@ %@>", self, self.package];
}

- (void)setPackage:(ATPackage*)pack
{
	[ATPackageCell cancelPreviousPerformRequestsWithTarget:self];
	
	
	package = pack;
	
	[iconView setIcon:package.localIcon];
	iconFetched = NO;
	
	//[iconView setTrusted:[package isTrustedPackage]];
	[iconView setNew:[package isNewPackage]];

	NSString *version = package.version;
	[packageVersionView setText:version];
	[packageDescriptionView setText:package.Description];
	[packageNameView setText:package.name];
	
	[self setNeedsDisplay];
}

- (ATPackage*)package
{
	return package;
}

- (void) drawRect:(CGRect)Rect
{
	if (!iconFetched)
	{
		iconFetched = YES;
		
		if (package.iconURL && [[package.iconURL absoluteString] length])
			[self performSelector:@selector(fetchIcon:) withObject:nil afterDelay:1.];
	}

	[super drawRect:Rect];
}

- (void)prepareForReuse
{
	if (iconFetched)
	{
		[ATPackageCell cancelPreviousPerformRequestsWithTarget:self];
	}

	[super prepareForReuse];
}

- (void)fetchIcon:(id)sender
{
	UIImage* dummy = package.icon;
    NSLog(@"%@", dummy.debugDescription); //Display debug info
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	if (selected)
	{
		[packageNameView setTextColor:[UIColor whiteColor]];
		[packageDescriptionView setTextColor:[UIColor colorWithRed:0.85 green:.7 blue:.55 alpha:1]];
		[packageVersionView setTextColor:[UIColor colorWithRed:.55 green:.7 blue:.85 alpha:1]];
//		packageDescriptionView.backgroundColor = [UIColor clearColor];
//		packageNameView.backgroundColor = [UIColor clearColor];
//		packageVersionView.backgroundColor = [UIColor clearColor];
	}
	else
	{
		[packageNameView setTextColor:[UIColor blackColor]];
		[packageDescriptionView setTextColor:[UIColor colorWithRed:0.15 green:.3 blue:.45 alpha:1]];
		[packageVersionView setTextColor:[UIColor colorWithRed:.45 green:.3 blue:.15 alpha:1]];
//		packageDescriptionView.backgroundColor = bg;
//		packageNameView.backgroundColor = bg;
//		packageVersionView.backgroundColor = bg;
	}

	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

- (void) setShowIndicator:(bool)show
{
	if(show == isIndicatorShown)
		return;
	isIndicatorShown = show;
	if(isIndicatorShown)
	{
		if(indicator == nil)
			indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		
		[indicator startAnimating];
		
		CGRect r = indicator.frame;
		r.origin.x = 320 - r.size.width - 10;
		r.origin.y = 40 - r.size.height / 2;
		indicator.frame = r;
		[self setAccessoryType:UITableViewCellAccessoryNone];
		indicator.alpha = 0.0;
		[self.contentView addSubview:indicator];
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:.3];
		indicator.alpha = 1.0;
		[UIView commitAnimations];
		
	}
	else
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:.3];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(_didEndHideIndicatorAnimation:)];
		
		indicator.alpha = 0.0;
		[UIView commitAnimations];
		[self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
}


- (void) _didEndHideIndicatorAnimation:(id)sender
{
	[indicator removeFromSuperview];
	
	indicator = nil;
}



@end
