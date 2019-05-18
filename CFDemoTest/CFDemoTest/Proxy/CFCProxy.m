#import "CFCProxy.h"
#import <objc/runtime.h>

@interface CFCProxy ()

@property (nonatomic, strong) NSArray *protocols;
@property (nonatomic, strong) NSMutableDictionary *selectors;

@end

@implementation CFCProxy

#pragma mark - Factory methods

/** 获取Proxy实例 */
+ (id)newInstance {
    return [CFCProxy alloc];
}

#pragma mark - Public methods

/** 注册关注的协议集合 */
- (void)registerRelatedProtocols:(NSArray *)protocols {
    NSMutableArray *items = [NSMutableArray array];

    for (NSString *str in protocols) {
        const char *protocolName = [str UTF8String];
        Protocol *protocol = objc_getProtocol(protocolName);
        [items addObject:protocol];
    }

    self.protocols = [items copy];
}

/** 注册监控的组件 */
- (void)registerComponent:(id)component {
    // 使用NSValue封装弱引用
    NSValue *value = [NSValue valueWithNonretainedObject:component];
    
    // 提取对象的所有遵循的协议列表
    unsigned int count;
    Protocol * __unsafe_unretained *protocolList = class_copyProtocolList([component class], &count);

    // 记录遵循目标协议的协议方法和映射对象
    for (int i = 0; i < count; i++) {
        Protocol *pro = protocolList[i];
        
        // 是否遵循目标协议
        const char *protocolName = protocol_getName(pro);
        NSLog(@"%@",[NSString stringWithUTF8String:protocolName]);
        
        //
        BOOL shouldRegister = NO;
        for (Protocol *protocol in self.protocols) {
            // 判断协议是否遵循另一个协议
            if (protocol_conformsToProtocol(pro, protocol)) {
                shouldRegister = YES;
                break;
            }
        }
        
        // 是否需要注册该协议下的方法
        if (!shouldRegister) {
            continue;
        }
        
        // 获取协议下的方法,包括required和optional方法
        unsigned int methodsCnt = 0;
        struct objc_method_description *methodsList = [self protocolMethods:pro cnt:&methodsCnt];

        // 注册协议方法和对象
        for (unsigned int i = 0; i < methodsCnt; ++i) {
            // 提取方法字符串
            struct objc_method_description methodDescription = methodsList[i];
            NSString *selStr = [NSString stringWithCString:sel_getName(methodDescription.name) encoding:NSUTF8StringEncoding];
            NSLog(@"%@", selStr);
            
            // 判断是否实现了该方法
            if (![component respondsToSelector:NSSelectorFromString(selStr)]) {
                continue;
            }

            // 提取方法字符串对应的对象数组
            if (!self.selectors[selStr]) {
                self.selectors[selStr] = [NSMutableArray array];
            }

            // 添加对象
            [self.selectors[selStr] addObject:value];
        }

        // 释放内存
        free(methodsList);
    }

    // 释放内存
    free(protocolList);
}

#pragma mark - NSProxy methods

- (BOOL)respondsToSelector:(SEL)selector {
    // 获取选择子方法名
    NSString *methodName = NSStringFromSelector(selector);

    // 在字典中查找对应的target
    NSArray *vals = self.selectors[methodName];

    return vals.count > 0;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
//     获取选择子方法名
    NSString *methodName = NSStringFromSelector(selector);

    // 在字典中查找对应的target
    NSArray *vals = self.selectors[methodName];
    if (!vals || vals.count == 0) {
        NSString *errorMsg = [NSString stringWithFormat:@"没有注册方法名:%@", methodName];
        NSAssert(NO, errorMsg);
        return nil;
    }

    NSValue *value = [vals firstObject];
    id target = [value nonretainedObjectValue];

    // 检查target
    if (target && [target respondsToSelector:selector]) {
        return [target methodSignatureForSelector:selector];
    }

    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    // 获取返回类型
    NSString *returnType = [NSString stringWithCString:invocation.methodSignature.methodReturnType encoding:NSUTF8StringEncoding];
    BOOL voidReturnType = [returnType isEqualToString:@"v"];

    // 获取选择子方法名
    NSString *methodName = NSStringFromSelector(invocation.selector);

    // 查找对应的组件
    BOOL invoked = NO;
    for (NSValue *nonRetainedValue in self.selectors[methodName]) {
        id target = [nonRetainedValue nonretainedObjectValue];
        
        if (!invoked || !voidReturnType) {
            [invocation invokeWithTarget:target];
            invoked = YES;
        }
        else {
            NSAssert(NO, @"调用带返回值的方法的个数超过一个");
            return;
        }
    }
}

#pragma mark - Utility methods

- (struct objc_method_description *)protocolMethods:(Protocol *)protocol cnt:(unsigned int *)cnt {
    // 提取Required方法
    unsigned int requiredMethodsCnt = 0;
    struct objc_method_description *requiredMethodsList = protocol_copyMethodDescriptionList(protocol, YES, YES, &requiredMethodsCnt);
    
    // 提取Optional方法
    unsigned int optionalMethodsCnt = 0;
    struct objc_method_description *optionalMethodsList = protocol_copyMethodDescriptionList(protocol, NO, YES, &optionalMethodsCnt);
    
    // 合并后的方法数组
    struct objc_method_description *methodsList = (struct objc_method_description *)malloc(sizeof(struct objc_method_description) * (requiredMethodsCnt + optionalMethodsCnt));
    
    unsigned int idx = 0;
    for (unsigned int i = 0; i < requiredMethodsCnt; ++i) {
        methodsList[idx++] = requiredMethodsList[i];
    }

    for (unsigned int i = 0; i < optionalMethodsCnt; ++i) {
        methodsList[idx++] = optionalMethodsList[i];
    }

    // 释放内存
    free(requiredMethodsList);
    free(optionalMethodsList);

    // 统计个数
    *cnt = requiredMethodsCnt + optionalMethodsCnt;

    return methodsList;
}

#pragma mark - Setter & getter methods

- (NSMutableDictionary *)selectors {
    if (!_selectors) {
        _selectors = [NSMutableDictionary dictionary];
    }

    return _selectors;
}

- (NSArray *)protocols {
    if (!_protocols) {
        // 缺省协议
        _protocols = @[
                       objc_getProtocol("CFCProxyProtocol"),
                       ];
    }

    return _protocols;
}

@end
