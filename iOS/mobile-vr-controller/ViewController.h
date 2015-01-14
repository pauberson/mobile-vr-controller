//
//  ViewController.h
//  mobile-vr-controller
//
//  Created by Pascal Auberson on 29/07/2014.
//  Copyright (c) 2014 Lumacode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "InstructionPageViewController.h"

@interface ViewController : UIViewController <SaveSettingsDelegate,  UIPageViewControllerDataSource>

@end
