//
//  PassWordView.m
//  News
//
//  Created by ZZG on 16/5/30.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "PassWordView.h"

@implementation PassWordView

- (void)drawRect:(CGRect)rect {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 5)];
    self.OldPasswordTF.leftView = view;
    self.OldPasswordTF.leftViewMode = UITextFieldViewModeAlways;
  
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 5)];
    self.NewPasswordTF.leftView = view1;
    self.NewPasswordTF.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 5)];
    self.NewPassword2TF.leftView = view2;
    self.NewPassword2TF.leftViewMode = UITextFieldViewModeAlways;
}


@end
