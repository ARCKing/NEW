//
//  WxPayView.m
//  News
//
//  Created by ZZG on 16/6/6.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "WxPayView.h"

@implementation WxPayView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    UIView *view1=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIImageView *ImgView1=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 20 , 20)];
    
    ImgView1.image=[UIImage imageNamed:@"ic_money"];
    [view1 addSubview:ImgView1];
    self.moneyTF.leftView=view1;
    self.moneyTF.leftViewMode=UITextFieldViewModeAlways;
}


@end
