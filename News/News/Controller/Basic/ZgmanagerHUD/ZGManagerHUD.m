//
//  ZGManagerHUD.m
//  
//
//  Created by siyue on 16/5/21.
//
//

#import "ZGManagerHUD.h"

#import "JGProgressHUD.h"

@interface ZGManagerHUD ()

@property (nonatomic ,strong) JGProgressHUD *hud;

@end

@implementation ZGManagerHUD

+(instancetype)shareInstance
{
    static ZGManagerHUD *manager;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager =[[ZGManagerHUD alloc]init];
    });
    return manager;
}

-(instancetype)init
{
    if (self==[super init]) {
        self.hud=[JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    }
    return self;
}

+(void)showHUDViewController:(UIViewController *)viewController
{
    [self showHUDwithMessage:nil inViewController:viewController];
}
+(void)showHUDwithMessage:(NSString *)msg inViewController:(UIViewController *)viewController
{
    ZGManagerHUD *manager=[ZGManagerHUD shareInstance];
    
    manager.hud.textLabel.text=msg;
    
    CGRect rect=CGRectMake(0, -64, viewController.view.bounds.size.width, viewController.view.bounds.size.height);
    //HUD的显示
    [manager.hud showInRect:rect inView:viewController.view animated:YES];
    
}
+(void)hidesHUDComplection:(void(^)())complection
{
    ZGManagerHUD *manager=[ZGManagerHUD shareInstance];
    
    //HUD的隐藏
    [manager.hud dismissAnimated:YES];
    if (complection) {
        complection();
    }
}


@end
