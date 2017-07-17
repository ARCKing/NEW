//
//  AlipayView.m
//  News
//
//  Created by ZZG on 16/6/4.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "AlipayView.h"

@implementation AlipayView


- (void)drawRect:(CGRect)rect {
    
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    
    UIImageView *ImgView=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 20 , 20)];
    ImgView.image=[UIImage imageNamed:@"ic_alipay"];
    
    [view addSubview:ImgView];
    
    self.NameTF.leftView=view;
    self.NameTF.leftViewMode=UITextFieldViewModeAlways;
    
    UIView *view1=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIImageView *ImgView1=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 20 , 20)];
    
    ImgView1.image=[UIImage imageNamed:@"ic_alipay"];
    [view1 addSubview:ImgView1];
    self.nikeNameTF.leftView=view1;
    self.nikeNameTF.leftViewMode=UITextFieldViewModeAlways;
    
    self.NameTF.layer.cornerRadius=5;
    self.NameTF.layer.masksToBounds=YES;
    
    self.nikeNameTF.layer.cornerRadius=5;
    self.nikeNameTF.layer.masksToBounds=YES;
}


@end
