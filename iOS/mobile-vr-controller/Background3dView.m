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
}
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
    SCNGeometry *planeGeometry = planeNode.geometry;

    NSError *error = nil;
    NSString *shaderSource = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"plane" ofType:@"shader"] encoding:NSUTF8StringEncoding error:&error];
    NSDictionary *shaderModifiers = [NSDictionary dictionaryWithObject:shaderSource forKey:SCNShaderModifierEntryPointGeometry];
    
    planeGeometry.shaderModifiers = shaderModifiers;
    
    [self play:nil];
    
    self.delegate = self;
}


- (void)renderer:(id<SCNSceneRenderer>)aRenderer updateAtTime:(NSTimeInterval)time {


    //NSLog(@"-----touch pos %0.1f %0.1f", touchPoint.x, touchPoint.y);


    /*
     SCNNode *lightNode2 = [self.theView.scene.rootNode childNodeWithName:@"Omni013" recursively:NO];
     lightNode2.position = SCNVector3Make(lightNode2.position.x, lightNode2.position.y, lightNode2.position.z+0.01);
     */
    

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
    touchPoint = [touch locationInView:self];
    NSLog(@"touch at x:%0.1f y:%0.1f", touchPoint.x, touchPoint.y);
    
    SCNNode *lightNode1 = [self.scene.rootNode childNodeWithName:@"Omni012" recursively:NO];
    
    NSLog(@"light pos at x:%0.1f y:%0.1f z:%0.1f", lightNode1.position.x, lightNode1.position.y, lightNode1.position.z);
    
    
    SCNVector3 touchPos = [self unprojectPoint:SCNVector3Make(touchPoint.x, touchPoint.y, 0)];
    
    NSLog(@"touchPos at x:%0.1f y:%0.1f z:%0.1f", touchPos.x, touchPos.y, touchPos.z);
    
    touchPos.y = lightNode1.position.y;
    
    lightNode1.position = SCNVector3Make(touchPos.x, lightNode1.position.y, lightNode1.position.z);
    
    

}

- (void)sendTouchesEnded{
    isTouching = false;
}




@end
