//
//  SettingsViewController.h
//  mobile-vr-controller
//
//  Created by Pascal Auberson on 30/07/2014.
//  Copyright (c) 2014 Lumacode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SaveSettingsDelegate
- (void)saveIPAddress: (NSString *)ipAddress andPort: (int) port;
@end

@interface SettingsViewController : UIViewController

@property (weak) id <SaveSettingsDelegate> delegate;


@end

