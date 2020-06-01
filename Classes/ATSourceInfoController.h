//
//  ATSourceInfoController.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATViewController.h"
#import "ATInstaller.h"


@interface ATSourceInfoController : ATViewController {
    IBOutlet UILabel *categoryLabel;
    IBOutlet UILabel *contactLabel;
    IBOutlet UILabel *definitionLabel;
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *sourceNameLabel;
    IBOutlet UITextField *urlLabel;
    IBOutlet UIImageView *movingBottomSeparator;
    IBOutlet UIButton *movingMailButton;

	ATSource *source;

}
- (IBAction)emailButtonPressed:(id)sender;
- (IBAction)refreshSource:(id)sender;
- (IBAction)editingDidEnd:(UITextField*)sender;
- (void)updateSource;

@property (retain, nonatomic) ATSource *source;

@end
