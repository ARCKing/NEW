//
//  ZGManagerHUD.h
//  
//
//  Created by siyue on 16/5/21.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ZGManagerHUD : NSObject

/**
 *  单例入口
 *
 *  @return 单例的实例对象
 */
+(instancetype)shareInstance;

/**
 *  在指定的ViewController里显示HUD
 *
 *  @param viewController 指定的ViewController
 */
+(void)showHUDViewController:(UIViewController *)viewController;

/**
 *  在指定的ViewController里显示HUD，并指定显示的文本
 *
 *  @param msg            显示的文本
 *  @param viewController 指定的ViewController
 */
+(void)showHUDwithMessage:(NSString *)msg inViewController:(UIViewController *)viewController;

/**
 *  隐藏HUD
 *
 *  @param complection 隐藏动画结束之后的回调Block
 */
+(void)hidesHUDComplection:(void(^)())complection;



@end
