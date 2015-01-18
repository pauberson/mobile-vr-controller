//
//  Background3dView.m
//  mobile-vr-controller
//
//  Created by Pascal Auberson on 17/12/2014.
//  Copyright (c) 2014 Lumacode Ltd. All rights reserved.
//

#import "Background3dView.h"

@interface Background3dView ()
{
    bool isTouching;
    CGPoint touchPoint;
    double curTime;
    bool isInteractive;
}

@property SCNGeometry *planeGeometry;

@end

@implementation Background3dView


- (void)setup {
    
    self.scene = [SCNScene sceneNamed:@"scene"];
    
    self.antialiasingMode = SCNAntialiasingModeMultisampling2X;
    self.backgroundColor = [UIColor blackColor];
    self.preferredFramesPerSecond = 60;
    self.userInteractionEnabled = YES;
    
    self.allowsCameraControl = NO;
    self.showsStatistics = NO;
    
    SCNNode *planeNode = [self.scene.rootNode childNodeWithName:@"Plane" recursively:NO];
    self.planeGeometry = planeNode.geometry;

    NSError *error = nil;
    NSString *shaderSource = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"plane" ofType:@"shader"] encoding:NSUTF8StringEncoding error:&error];
    NSDictionary *shaderModifiers = [NSDictionary dictionaryWithObject:shaderSource forKey:SCNShaderModifierEntryPointGeometry];
    
    self.planeGeometry.shaderModifiers = shaderModifiers;
    
    [self setStandbyMode];
    
    [self play:nil];
    
    self.delegate = self;
}

- (void) setStandbyMode {
    isInteractive = NO;
    
    [self.planeGeometry setValue:[NSValue valueWithCGPoint:CGPointMake(-300,300)] forKey:@"waveCentre"];
    [self.planeGeometry setValue:[NSNumber numberWithFloat:1000.0f] forKey:@"waveLength"];
    [self.planeGeometry setValue:[NSNumber numberWithFloat:20.0f] forKey:@"amplitude"];
    [self.planeGeometry setValue:[NSNumber numberWithFloat:5.0f] forKey:@"phaseDuration"];
    [self.planeGeometry setValue:[NSNumber numberWithFloat:5000.0f] forKey:@"fallOffRadius"];
    
    [self.planeGeometry setValue:[NSNumber numberWithFloat:0.0f] forKey:@"animStartTime"];
    [self.planeGeometry setValue:[NSNumber numberWithFloat:FLT_MAX] forKey:@"animEndTime"];
    [self.planeGeometry setValue:[NSNumber numberWithFloat:1.0f] forKey:@"animFadeTime"];
    [self.planeGeometry setValue:[NSNumber numberWithFloat:0.0f] forKey:@"curTime"];
}

- (void) setInteractiveMode {
    isInteractive = YES;
    
    [self.planeGeometry setValue:[NSValue valueWithCGPoint:CGPointMake(0,0)] forKey:@"waveCentre"];
    [self.planeGeometry setValue:[NSNumber numberWithFloat:700.0f] forKey:@"waveLength"];
    [self.planeGeometry setValue:[NSNumber numberWithFloat:0.0f] forKey:@"amplitude"];
    [self.planeGeometry setValue:[NSNumber numberWithFloat:1.0f] forKey:@"phaseDuration"];
    [self.planeGeometry setValue:[NSNumber numberWithFloat:600.0f] forKey:@"fallOffRadius"];
    
    
    [self.planeGeometry setValue:[NSNumber numberWithFloat:0.0f] forKey:@"animStartTime"];
    [self.planeGeometry setValue:[NSNumber numberWithFloat:FLT_MAX] forKey:@"animEndTime"];
    [self.planeGeometry setValue:[NSNumber numberWithFloat:1.0f] forKey:@"animFadeTime"];
    [self.planeGeometry setValue:[NSNumber numberWithFloat:0.0f] forKey:@"curTime"];
    
}

- (void)renderer:(id<SCNSceneRenderer>)aRenderer updateAtTime:(NSTimeInterval)time {

    curTime = time;
    
    [self.planeGeometry setValue:[NSNumber numberWithDouble:curTime] forKey:@"curTime"];
    
    if (isTouching){
        [self.planeGeometry setValue:[NSNumber numberWithFloat:curTime] forKey:@"animStartTime"];
        [self.planeGeometry setValue:[NSNumber numberWithFloat:FLT_MAX] forKey:@"animEndTime"];
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handleTouches:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handleTouches:touches withEvent:event];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self sendTouchesEnded];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self sendTouchesEnded];
}

- (void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (!isTouching){
        
        if (!isInteractive){
            [self setInteractiveMode];
        }
        [self.planeGeometry setValue:[NSNumber numberWithFloat:0.0f] forKey:@"amplitude"];
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        [self.planeGeometry setValue:[NSNumber numberWithFloat:120.0f] forKey:@"amplitude"];
        [SCNTransaction commit];
    }
    
    isTouching = true;
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    touchPoint = [touch locationInView:self];

    NSArray *hitTestResults = [self hitTest:touchPoint options:@{}];

    if (hitTestResults.count>0){
        
        SCNHitTestResult *hitTestResult = [hitTestResults objectAtIndex:0];
        
        SCNVector3 touchPos = hitTestResult.worldCoordinates;
        
        [self.planeGeometry setValue:[NSValue valueWithCGPoint:CGPointMake(-touchPos.z, -touchPos.x)] forKey:@"waveCentre"];
        [self.planeGeometry setValue:[NSNumber numberWithFloat:curTime] forKey:@"animStartTime"];
        
    }

}

- (void)sendTouchesEnded{
    isTouching = false;
    [self.planeGeometry setValue:[NSNumber numberWithFloat:curTime+1.5f] forKey:@"animEndTime"];
}


@end
