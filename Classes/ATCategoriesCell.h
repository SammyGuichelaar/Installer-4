//
//  ATCategoriesCell.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATTableViewCell.h"

#define ATCAtegoriesType_AllPackages		0
#define ATCategoriesTYPE_UpdatedPackages	1
#define ATCategoriesTYPE_InstalledPackages	2
#define ATCategoriesTYPE_RecentPackages		3
#define ATCategoriesTYPE_OtherCategories	4

@interface ATCategoriesCell : ATTableViewCell {
	NSString *text;
	UILabel *textViewer;
	UILabel *subtitle;
	NSUInteger packageCount;
}

@property (nonatomic, assign) NSUInteger packageCount;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier categoriesType:(int)type;
- (void) setCategoriesType:(int)type;

- (void)_reconcileViews;

@end
