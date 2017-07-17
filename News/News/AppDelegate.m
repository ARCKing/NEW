//
//  AppDelegate.m
//  News
//
//  Created by siyue on 16/5/20.
//  Copyright (c) 2016年 siyue. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailsViewController.h"
#import "UMessage.h"
#import "VideoViewController.h"
#import "HomeViewController.h"
#import "FoundViewController.h"
#import "MyViewController.h"
#import "RankingViewController.h"
#import "MyNavigationController.h"

@interface AppDelegate ()<UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.tabBarController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    //设置 AppKey 及 LaunchOptions
    [UMessage startWithAppkey:@"577e09bc67e58e584c001c04" launchOptions:launchOptions];
    //1.3.0版本开始简化初始化过程。如不需要交互式的通知，下面用下面一句话注册通知即可。
    [UMessage registerForRemoteNotifications];
    
    //设置应用的日志输出的开关
//    [UMessage setLogEnabled:YES];
    
    if (launchOptions) {
        NSDictionary* userInfo =[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo) {
            //这里定义自己的处理方式
            [[NSNotificationCenter defaultCenter]postNotificationName:@"deviceToken" object:self userInfo:@{@"keyid":userInfo[@"id"],@"title":userInfo[@"aps"][@"alert"]}];
        }
    }
    return YES;
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //接受服务端推送通知传来的值，全部在userinfo里面。
    [UMessage didReceiveRemoteNotification:userInfo];
    
    if (application.applicationState == UIApplicationStateActive) {
        //第二种情况  前台工作
        if (userInfo[@"aps"][@"alert"]!=NULL) {
             [[NSNotificationCenter defaultCenter]postNotificationName:@"deviceToken" object:self userInfo:@{@"keyid":userInfo[@"id"],@"title":userInfo[@"aps"][@"alert"]}];
        }
    } else {
        //第三种情况   后台
        [[NSNotificationCenter defaultCenter]postNotificationName:@"deviceToken" object:self userInfo:@{@"keyid":userInfo[@"id"],@"title":userInfo[@"aps"][@"alert"]}];
    }
    //设置图标的徽章
    [UIApplication sharedApplication].applicationIconBadgeNumber=1;
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //向友盟注册该设备的deviceToken，便于发送Push消息  注册token
    [UMessage registerDeviceToken:deviceToken];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



-(UITabBarController *)tabBarController
{
    if (_tabBarController==nil) {
        _tabBarController=[[UITabBarController alloc]init];
        
        _tabBarController.delegate=self;
        
        HomeViewController *vc1 = [[HomeViewController alloc] init];
        MyNavigationController *nav1 = [[MyNavigationController alloc] initWithRootViewController:vc1];
        vc1.tabBarItem.image = [UIImage imageNamed:@"news"];
        vc1.tabBarItem.selectedImage=[[UIImage imageNamed:@"news_press"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [vc1.tabBarItem setTitle:@"首页"];
        
        
        VideoViewController *vc5 = [[VideoViewController alloc] init];
        MyNavigationController *nav5 = [[MyNavigationController alloc] initWithRootViewController:vc5];
        vc5.tabBarItem.image = [UIImage imageNamed:@"Video"];
        vc5.tabBarItem.selectedImage=[[UIImage imageNamed:@"Video_press"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [vc5.tabBarItem setTitle:@"视频"];
        
        RankingViewController *vc2 = [[RankingViewController alloc] initWithNibName:@"RankingViewController" bundle:nil];
        MyNavigationController *nav2 = [[MyNavigationController alloc] initWithRootViewController:vc2];
        vc2.tabBarItem.image = [[UIImage imageNamed:@"rank"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vc2.tabBarItem.selectedImage=[[UIImage imageNamed:@"rank_press"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        vc2.tabBarItem.title=@"排行";
        
        
        FoundViewController *vc3 = [[FoundViewController alloc] initWithNibName:@"FoundViewController" bundle:nil];
        MyNavigationController *nav3 = [[MyNavigationController alloc] initWithRootViewController:vc3];
        vc3.tabBarItem.image = [[UIImage imageNamed:@"search"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vc3.tabBarItem.selectedImage=[[UIImage imageNamed:@"search_press"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [vc3.tabBarItem setTitle:@"发现"];
        
        
        MyViewController *vc4 = [[MyViewController alloc] initWithNibName:@"MyViewController" bundle:nil];
        MyNavigationController *nav4 = [[MyNavigationController alloc] initWithRootViewController:vc4];
        
        vc4.tabBarItem.image = [UIImage imageNamed:@"mine"];
        vc4.tabBarItem.selectedImage=[[UIImage imageNamed:@"mine_press"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [vc4.tabBarItem setTitle:@"我的"];
        
        [[UITabBarItem appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:240/255.0f green:88/255.0f blue:91/255.0f alpha:1],UITextAttributeTextColor, nil] forState:UIControlStateSelected];
        
        _tabBarController.viewControllers=@[nav1,nav5,nav2,nav3,nav4];
    }
    return _tabBarController;
}
//-(void)VerSionButton
//{
//    //获取发布版本的Version
//    NSString *string=[NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://wz.lefei.com/?m=Api&c=ApiV2&a=ckUpdate"] encoding:NSUTF8StringEncoding error:nil];
//    if (string!=nil&&string.length>0&&[string rangeOfString:@"version"].length==7) {
//        [self cheakAppUpdata:string];
//    }
//}
////比较当前版本与新上线的版本比较
//-(void)cheakAppUpdata:(NSString *)appInfo{
//    
//    //获取当前版本
//    NSString *version=[[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"];
//    
//    NSLog(@"%@",version);
//    NSString *appInfo1=[appInfo substringFromIndex:[appInfo rangeOfString:@"\"version\":"].location+10];
//    
//    
//    appInfo=[[appInfo1 substringToIndex:[appInfo1 rangeOfString:@","].location]stringByReplacingOccurrencesOfString:@"" withString:@""];
//    
//    if (![appInfo1 isEqualToString:version]) {
//        
//        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"新版本%@已发布",appInfo1] delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
//        
//        alertView.delegate=self;
//        [alertView addButtonWithTitle:@"前往更新"];
//        [alertView show];
//        alertView.tag=20;
//    }
//}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1&alertView.tag==20) {
        NSString *url=@"";
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
    }
}
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DidSelectNotification" object:nil userInfo:nil];
}

@end
