//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Showable)

- (void)show;

- (void)presentAnimated:(BOOL)animated
             completion:(void (^)(void))completion;

- (void)presentFromController:(UIViewController *)viewController
                     animated:(BOOL)animated
                   completion:(void (^)(void))completion;

@end
