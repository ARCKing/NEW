//
//  NikeNameView.m
//  News
//
//  Created by ZZG on 16/6/3.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "NikeNameView.h"

@implementation NikeNameView

- (void)drawRect:(CGRect)rect {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 5)];
    self.NameTF.leftView = view;
    self.NameTF.leftViewMode = UITextFieldViewModeAlways;
    
  
}

@end
