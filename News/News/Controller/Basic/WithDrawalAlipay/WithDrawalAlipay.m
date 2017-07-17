//
//  WithDrawalAlipay.m
//  News
//
//  Created by ZZG on 16/6/6.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "WithDrawalAlipay.h"

@implementation WithDrawalAlipay


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIImageView *ImgView=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 20 , 20)];
    ImgView.image=[UIImage imageNamed:@"ic_money"];
     [view addSubview:ImgView];
    self.moneyTF.leftView=view;
    self.moneyTF.leftViewMode=UITextFieldViewModeAlways;
}

@end
