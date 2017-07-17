//
//  weixinView.m
//  News
//
//  Created by ZZG on 16/6/4.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "weixinView.h"

@implementation weixinView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    UIView *view1=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIImageView *ImgView1=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 20 , 20)];
    
    ImgView1.image=[UIImage imageNamed:@"ic_wxpay"];
    [view1 addSubview:ImgView1];
    self.URLTF.leftView=view1;
    self.URLTF.leftViewMode=UITextFieldViewModeAlways;
    
    self.URLTF.layer.cornerRadius=5;
    self.URLTF.layer.masksToBounds=YES;
    
}


@end
