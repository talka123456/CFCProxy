//
//  CFCDelegate.h
//  CFDemoTest
//
//  Created by abc on 2019/5/18.
//  Copyright © 2019 com.ClownFish.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFCProxy.h"
#import "CFBaseDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CFCDelegate <CFBaseDelegate>

- (void)handleFirstViewResponse;

@end

NS_ASSUME_NONNULL_END
