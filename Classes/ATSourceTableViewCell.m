//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import "ATSourceTableViewCell.h"
#import "ATIconView.h"

@implementation ATSourceTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier source:(ATSource*)src
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		// Initialization code
		
		sourceNameView = [[UILabel alloc] initWithFrame:CGRectMake(80, 3, 200, 35)];
		sourceDescriptionView = [[UILabel alloc] initWithFrame:CGRectMake(80, 25, 220, 55)];
		[sourceNameView setTextColor:[UIColor blackColor]];
		[sourceNameView setBackgroundColor:[UIColor clearColor]];
		sourceNameView.shadowColor = [UIColor colorWithWhite:0.8 alpha:1.];
		sourceNameView.shadowOffset = CGSizeMake(0,1);
		sourceNameView.adjustsFontSizeToFitWidth = YES;
		sourceNameView.numberOfLines = 1;
        [sourceNameView setMinimumScaleFactor:9.];
			
		[sourceNameView setFont:self.textLabel.font];
		
		UIFont *fontDescr = [UIFont fontWithName:@"Helvetica" size:12];
		[sourceDescriptionView setTextColor:[UIColor colorWithRed:.15 green:.3 blue:.45 alpha:1]];
		[sourceDescriptionView setBackgroundColor:[UIColor clearColor]];
		sourceDescriptionView.shadowColor = [UIColor colorWithWhite:0.8 alpha:1.];
		sourceDescriptionView.shadowOffset = CGSizeMake(0,1);
					
		[sourceDescriptionView setFont:fontDescr];
		sourceDescriptionView.numberOfLines = 3;
		[self.contentView addSubview:sourceNameView];
		[self.contentView addSubview:sourceDescriptionView];
		
		[self setSource:src];
	}
	return self;
}


- (ATSource*)source
{
	return source;
}

- (void)setSource:(ATSource*)src
{
	
	source = src;
	
	if ([source.name length])
		[sourceNameView setText:source.name];
	else
		[sourceNameView setText:NSLocalizedString(source.hasErrors ? @"Invalid Source" : @"New Source", @"")];
	
	if ([source.Description length])
		[sourceDescriptionView setText:source.Description];
	else
		[sourceDescriptionView setText:[source.location host]];
	
	if (iconView)
	{
		[iconView removeFromSuperview];
	}
	
	UIImage * icon = source.icon;
	
	iconView = (UIImageView*)[[ATIconView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
	
	if (!icon)
	{
		icon = [UIImage imageNamed:@"ATSource.png"];
		if(source.isTrustedSource) 
			icon = [UIImage imageNamed:@"ATSource_Trusted.png"];
		
		//iconView = [[UIImageView alloc] initWithImage:icon];
		[(ATIconView*)iconView setIcon:icon];
	}
	else
	{
		[(ATIconView*)iconView setIcon:icon];
	}
	
	((ATIconView*)iconView).hasErrors = [source.hasErrors boolValue];
	
	[self.contentView addSubview:iconView];
	
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	if(selected)
	{
		[sourceNameView setTextColor:[UIColor whiteColor]];
		[sourceDescriptionView setTextColor:[UIColor colorWithRed:0.85 green:.7 blue:.55 alpha:1]];
	}else
	{
		[sourceNameView setTextColor:[UIColor blackColor]];
		[sourceDescriptionView setTextColor:[UIColor colorWithRed:0.15 green:.3 blue:.45 alpha:1]];
	}
	
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}



@end
