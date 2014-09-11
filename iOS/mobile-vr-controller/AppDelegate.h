//
//  AppDelegate.h
//  mobile-vr-controller
//
//  Created by Pascal Auberson on 29/07/2014.
//  Copyright (c) 2014 Lumacode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    
    CMMotionManager *motionManager;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (readonly) CMMotionManager *motionManager;

@end
