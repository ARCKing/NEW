//
//  MyNavigationController.m
//  
//
//  Created by siyue on 16/5/20.
//
//

#import "MyNavigationController.h"

@interface MyNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation MyNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationBar setBarTintColor:[UIColor colorWithRed:211/255.0f green:76/255.0f blue:74/255.0 alpha:1]];
    
    self.navigationBar.tintColor = [UIColor colorWithRed:211/255.0f green:76/255.0f blue:74/255.0 alpha:1];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:211/255.0f green:76/255.0f blue:74/255.0 alpha:1]};
    
    //ios7之后  UINavigationController  的返回手势
    self.interactivePopGestureRecognizer.delegate=self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  状态栏的颜色
 *
 *  @return 状态栏的颜色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - UIGestureRecognizerDelegate

// 启用iOS7之后的返回手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.viewControllers.count <= 1) {
        return NO;
    }
    
    return YES;
}

@end
