//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "ATInstaller.h"
#import "ATSource.h"
#import "ATTableViewCell.h"

@interface ATSourceTableViewCell : ATTableViewCell {
	UILabel *sourceNameView;
	UILabel *sourceDescriptionView;
	UIImageView *iconView;

	ATSource* source;
}

@property (retain) ATSource* source;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier source:(ATSource*)s;
- (void)setSource:(ATSource*)source;
@end
