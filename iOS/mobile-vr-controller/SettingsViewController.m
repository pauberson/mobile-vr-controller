//
//  SettingsViewController.m
//  mobile-vr-controller
//
//  Created by Pascal Auberson on 30/07/2014.
//  Copyright (c) 2014 Lumacode Ltd. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *ipAddress;
@property (weak, nonatomic) IBOutlet UITextField *udpPort;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int currentUdpPort = [[NSUserDefaults standardUserDefaults] integerForKey:@"udp_port"];
    self.udpPort.text = [NSString stringWithFormat:@"%i",(currentUdpPort == 0) ? 11000 : currentUdpPort ];
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonPressed:(id)sender{
    [self.delegate saveIPAddress:self.ipAddress.text andPort: [self.udpPort.text intValue]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
