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
#import "Background3dView.h"
#import "InstructionPageViewController.h"

#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

@import SceneKit;

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
    TouchPoint touchPoint;
    bool hasStarted;
}

@property (weak, nonatomic) IBOutlet UIView *interfaceHolder;
@property (weak, nonatomic) IBOutlet UIView *backgroundHolder;
@property (weak, nonatomic) IBOutlet UIView *instructionsHolder;
@property Background3dView *background3dView;
@property (weak) NSString *udpHost;
@property int udpPort;
@property UITapGestureRecognizer *tapGestureRecognizer;
@property (weak) CMMotionManager *motionManager;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *instructionPageImages;


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
    hasStarted = false;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    id appDelegate = [UIApplication sharedApplication].delegate;
    self.motionManager = [appDelegate motionManager];
    

    // add background view
    self.background3dView = [[Background3dView alloc] initWithFrame:self.view.frame options:nil];
    [self.background3dView setup];
    [self.backgroundHolder addSubview:self.background3dView];
    
    
    // add instructions page view controller
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor clearColor];
    
    _instructionPageImages = @[@"instruction1.png", @"instruction2.png", @"instruction3.png", @"instruction4.png", @"instruction5.png"];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    InstructionPageViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.instructionsHolder addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    // if no settings, show dialog to enter IP address / port
    if (!self.udpHost || [self.udpHost isEqual: @""] ){
        [self showSettings];
    }
    [super viewDidLoad];
}

- (void)start{

    [UIView animateWithDuration:0.5
                     animations:^{self.interfaceHolder.alpha = 0.0;}
                     completion:^(BOOL finished){ [self.interfaceHolder removeFromSuperview]; }];
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(update:) userInfo:nil repeats:YES];
    hasStarted = true;

}

- (void)update:(NSTimer*)theTimer
{
    if (isTouching){
        NSString *touchMsg = [NSString stringWithFormat:@"touch,%d,%d", touchPoint.x, touchPoint.y];
        [self sendMessage:touchMsg];
    }
    
    CMDeviceMotion *d = self.motionManager.deviceMotion;
    NSString *gyroMsg = [NSString stringWithFormat:@"gyro,%0.4f,%0.4f,%0.4f", d.attitude.pitch, d.attitude.roll, d.attitude.yaw];

    [self sendMessage:gyroMsg];
    
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
    if (!hasStarted){
        [self start];
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded){
        TouchPoint tapPoint = [self CGPointToTouchPoint:[sender locationInView:self.view]];
        NSString *msg = [NSString stringWithFormat:@"tap,%d,%d", tapPoint.x, tapPoint.y];
        [self sendMessage:msg];
    }
}

- (void)sendMessage:(NSString *)msg{
    if (!hasStarted) return;
    
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

- (InstructionPageViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.instructionPageImages count] == 0) || (index >= [self.instructionPageImages count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    InstructionPageViewController *instructionPageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InstructionPageViewController"];
    instructionPageViewController.imageFile = self.instructionPageImages[index];
    instructionPageViewController.pageIndex = index;
    
    return instructionPageViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((InstructionPageViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((InstructionPageViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.instructionPageImages count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.instructionPageImages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
