//
//  ViewController.m
//  mobile-vr-controller
//
//  Created by Pascal Auberson on 29/07/2014.
//  Copyright (c) 2014 Lumacode Ltd. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "SettingsViewController.h"

struct TouchPoint {
    int x;
    int y;
};

typedef struct TouchPoint TouchPoint;

@interface ViewController ()
{
    long tag;
    GCDAsyncUdpSocket *udpSocket;
    int halfViewWidth;
    int halfViewHeight;
    bool isTouching;
    int touchPosX;
    int touchPosY;
    TouchPoint touchPoint;
}

@property (weak) NSString *udpHost;
@property int udpPort;
@property UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self loadSettings];
    
    // listen for changes made in setting app
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsDidChange:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    
    halfViewWidth = self.view.bounds.size.width/2;
    halfViewHeight = self.view.bounds.size.height/2;
    isTouching = false;
    
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(update:) userInfo:nil repeats:YES];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    // if no settings, show dialog to enter IP address / port
    if (!self.udpHost || [self.udpHost isEqual: @""] ){
        [self showSettings];
    }
    [super viewDidLoad];
}

- (void)update:(NSTimer*)theTimer
{
    if (isTouching){
        NSString *msg = [NSString stringWithFormat:@"touch,%d,%d", touchPoint.x, touchPoint.y];
        [self sendMessage:msg];
    }

}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handleTouches:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handleTouches:touches withEvent:event];
}


-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self sendTouchesEnded];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self sendTouchesEnded];
}

-(void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event{
    isTouching = true;
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    touchPoint = [self CGPointToTouchPoint:[touch locationInView:self.view]];
}

- (TouchPoint)CGPointToTouchPoint:(CGPoint)pnt{
    TouchPoint t;
    t.x = (int)round(pnt.x - halfViewWidth);
    t.y = (int)round(halfViewHeight - pnt.y);
    return t;
}

- (void)sendTouchesEnded{
    isTouching = false;
    [self sendMessage:@"touchend"];
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded){
        TouchPoint tapPoint = [self CGPointToTouchPoint:[sender locationInView:self.view]];
        NSString *msg = [NSString stringWithFormat:@"tap,%d,%d", tapPoint.x, tapPoint.y];
        [self sendMessage:msg];
    }
}

- (void)sendMessage:(NSString *)msg{
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:data toHost:self.udpHost port:self.udpPort withTimeout:-1 tag:tag++];
}

- (void)saveIPAddress: (NSString *)ipAddress andPort: (int) port {

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:ipAddress forKey:@"ip_address"];
    [userDefaults setInteger:port forKey:@"udp_port"];
    [userDefaults synchronize];

}

- (void)loadSettings {
    self.udpHost = [[NSUserDefaults standardUserDefaults] stringForKey:@"ip_address"];
    self.udpPort = [[NSUserDefaults standardUserDefaults] integerForKey:@"udp_port"];
}

- (void)settingsDidChange:(NSNotification *)notification {
    [self loadSettings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSettings{
    SettingsViewController *settingsController = [self.storyboard instantiateViewControllerWithIdentifier:@"Settings"];
    
    settingsController.delegate = self;
    
    [self presentViewController:settingsController animated:YES completion: nil];
    
}
@end
