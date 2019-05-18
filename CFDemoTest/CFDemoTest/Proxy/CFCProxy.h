#import <Foundation/Foundation.h>

@class UINavigationController;


@protocol CFCProxyProtocol <NSObject>

@end


@interface CFCProxy : NSProxy

/** 获取Proxy实例 */
+ (id)newInstance;

/** 注册组件 */
- (void)registerComponent:(id)component;

/** 注册关注的协议集合,缺省值为CFCProxyProtocol */
- (void)registerRelatedProtocols:(NSArray *)protocols;

@end
