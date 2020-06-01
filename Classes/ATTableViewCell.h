//
//  ATTableViewCell.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ATTableViewCell : UITableViewCell {
	BOOL		odd;
	UIColor*	bg;
}

@property (assign) BOOL odd;

@end
