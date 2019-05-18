//
//  CFCFirstView.m
//  CFDemoTest
//
//  Created by abc on 2019/5/17.
//  Copyright © 2019 com.ClownFish.www. All rights reserved.
//

#import "CFCFirstView.h"

@interface CFCFirstView ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation CFCFirstView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.button];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.button.frame = self.bounds;
}

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] init];
        _button.backgroundColor = [UIColor redColor];
        [_button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _button;
}

- (void)clickButton {
    if (self.proxy && [self.proxy respondsToSelector:@selector(handleFirstViewResponse)]) {
        [self.proxy handleFirstViewResponse];
    }
}

@end
