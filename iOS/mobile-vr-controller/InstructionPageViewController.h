//
//  InstructionPageViewController.h
//  mobile-vr-controller
//
//  Created by Pascal Auberson on 12/01/2015.
//  Copyright (c) 2015 Lumacode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstructionPageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property NSUInteger pageIndex;
@property NSString *imageFile;

@end
