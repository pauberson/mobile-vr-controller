//
//  ViewController.m
//  mobile-vr-controller
//
//  Created by Pascal Auberson on 29/07/2014.
//  Copyright (c) 2014 Lumacode Ltd. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"

@interface ViewController ()
{
    long tag;
    GCDAsyncUdpSocket *udpSocket;
    int halfViewWidth;
    int halfViewHeight;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.udpHost = @"192.168.0.9";

    self.udpPort = 11000;
    
    halfViewWidth = self.view.bounds.size.width/2;
    halfViewHeight = self.view.bounds.size.height/2;

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
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    
    CGPoint touchPoint = [touch locationInView:self.view];
    
    int posX = (int)round(touchPoint.x - halfViewWidth);
    int posY = (int)round(halfViewHeight - touchPoint.y);
    
    NSString *msg = [NSString stringWithFormat:@"touch,%d,%d",posX, posY];
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:data toHost:self.udpHost port:self.udpPort withTimeout:-1 tag:tag];
    
    tag++;
    
}

- (void)sendTouchesEnded{
    
    NSData *data = [@"touchend" dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:data toHost:self.udpHost port:self.udpPort withTimeout:-1 tag:tag];
    
    tag++;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
