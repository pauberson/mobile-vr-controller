//
//  InstructionPageViewController.m
//  mobile-vr-controller
//
//  Created by Pascal Auberson on 12/01/2015.
//  Copyright (c) 2015 Lumacode Ltd. All rights reserved.
//

#import "InstructionPageViewController.h"

@interface InstructionPageViewController ()
@end


@implementation InstructionPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundImageView.image = [UIImage imageNamed:self.imageFile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
