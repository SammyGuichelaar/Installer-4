//
//  ATPackageCell.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATPackageManager.h"
#import "ATInstaller.h"
#import "ATPackage.h"
#import "ATIconView.h"
#import "ATTableViewCell.h"


@interface ATPackageCell : ATTableViewCell {
	UILabel *packageNameView;
	UILabel *packageDescriptionView;
	UILabel *packageVersionView;
	ATIconView *iconView;
	bool isIndicatorShown;
	UIActivityIndicatorView *indicator;
	
	ATPackage* package;
	
	BOOL iconFetched;
}

@property (retain) ATPackage* package;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier package:(ATPackage*)pack;
- (void) setShowIndicator:(bool)show;
- (void) _didEndHideIndicatorAnimation:(id)sender;
- (void)setPackage:(ATPackage*)package;
@end
