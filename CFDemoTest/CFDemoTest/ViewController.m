//
//  ViewController.m
//  CFDemoTest
//
//  Created by abc on 2019/4/25.
//  Copyright © 2019 com.ClownFish.www. All rights reserved.
//

#import "ViewController.h"
#import "CFCProxy.h"
#import "CFCFirstView.h"
#import "CFCSecondView.h"
#import "CFCDelegate.h"

@interface ViewController ()

@property (nonatomic, strong) id proxy;
@property (nonatomic, strong) CFCFirstView *firstView;
@property (nonatomic, strong) CFCSecondView *secondView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // 自定义协议基类
    [self.proxy registerRelatedProtocols:@[@"CFBaseDelegate"]];
    
    [self.navigationItem setTitle:@"标题"];
    
    [self.view addSubview:self.firstView];
    [self.view addSubview:self.secondView];
    
    // 注册
    [self.proxy registerComponent:self.firstView];
    [self.proxy registerComponent:self.secondView];
}

- (id)proxy {
    if (!_proxy) {
        _proxy = [CFCProxy newInstance];
    }
    
    return _proxy;
}

- (CFCFirstView *)firstView {
    if (!_firstView) {
        _firstView = [[CFCFirstView alloc] init];
        _firstView.proxy = self.proxy;
        _firstView.frame = CGRectMake(100, 100, 100, 100);
    }
    
    return _firstView;
}

- (CFCSecondView *)secondView {
    if (!_secondView) {
        _secondView = [[CFCSecondView alloc] init];
        _secondView.frame = CGRectMake(100, 300, 100, 100);
    }
    
    return _secondView;
}

@end
