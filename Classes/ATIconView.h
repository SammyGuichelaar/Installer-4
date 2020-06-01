//
//  ATIconView.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ATIconView : UIView {
	UIImage *icon;
	UIImage *iconMirror;
	bool isTrusted;
	bool isNew;
	
	BOOL hasErrors;
	BOOL drawShadow;
}

@property (assign, nonatomic) BOOL hasErrors;
@property (assign, nonatomic) BOOL drawShadow;

- (void) setIcon:(UIImage*) iconSource;
- (void) setTrusted:(bool)isT;
- (void) setNew:(bool) isN;

@end
