//
//  CFCSecondView.m
//  CFDemoTest
//
//  Created by abc on 2019/5/18.
//  Copyright © 2019 com.ClownFish.www. All rights reserved.
//

#import "CFCSecondView.h"
#import "CFCDelegate.h"

@interface CFCSecondView ()<CFCDelegate>

@end

@implementation CFCSecondView

- (void)handleFirstViewResponse {
    NSLog(@"%s", __func__);
}

@end
