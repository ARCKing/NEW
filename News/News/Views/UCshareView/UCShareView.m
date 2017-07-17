//
//  UCShareView.m
//  webShare
//
//  Created by gxtc on 16/9/21.
//  Copyright © 2016年 gxtc. All rights reserved.
//

#import "UCShareView.h"

#define Screen_W [UIScreen mainScreen].bounds.size.width
#define Screen_H [UIScreen mainScreen].bounds.size.height

@interface UCShareView ()

@property(nonatomic,retain)UILabel * titleLabel;

@end

@implementation UCShareView


- (instancetype)initWithFrame:(CGRect)frame{

//    NSArray * iconArray = @[@"pic_share_friends.png",@"pic_share_weixin.png",@"pic_share_sina.png",@"pic_share_tencent.png",@"pic_share_zone.png",@"pic_share_copy_link.png"];
    
    
    NSArray * iconArray = @[@"pic_share_friends.png",@"pic_share_weixin.png",@"pic_share_tencent.png",@"pic_share_zone.png",@"pic_share_copy_link.png"];

    
//    NSArray * buttonTitleArray = @[@"微信朋友圈",@"微信好友",@"新浪微博",@" QQ好友 ",@" QQ空间 ",@"复制链接"];
    NSArray * buttonTitleArray = @[@"微信朋友圈",@"微信好友",@" QQ好友 ",@" QQ空间 ",@"复制链接"];

    
    if (self = [super initWithFrame:frame]) {
        self.bgShareView = [[UIView alloc]init];
        
//        self.bgShareView.frame = CGRectMake(0, Screen_H * 2 /3, Screen_W, Screen_H/3);
          self.bgShareView.frame = CGRectMake(0, Screen_H, Screen_W, Screen_H/3);

        self.bgShareView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        [self addSubview:_bgShareView];
        
        NSMutableArray * buttonArray = [NSMutableArray new];
        
        for (int i = 0; i < 5; i++) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
#pragma mark- button.tag-1110+i;
            button.tag = 1110 + i;
            button.frame = CGRectMake(Screen_W/5/2 + ((Screen_W/5/2 + Screen_W/5) * (i % 3)), (10 + Screen_W/5) * (i / 3), Screen_W/5, Screen_W/5);
//            button.backgroundColor = [UIColor purpleColor];
            [button setImage:[UIImage imageNamed:iconArray[i]] forState:UIControlStateNormal];
            
            [button setTitle:buttonTitleArray[i] forState:UIControlStateNormal];
            
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            
            button.titleEdgeInsets = UIEdgeInsetsMake(50, -35, 0, 0);
            button.imageEdgeInsets = UIEdgeInsetsMake(-15, 12, 0, 0);
            
            
            [buttonArray addObject:button];
            
            [_bgShareView addSubview:button];
        }
        
        self.weixinFriend = buttonArray[0];
        self.weixin = buttonArray[1];
//        self.sinaWeiBo = buttonArray[2];
        self.QQ = buttonArray[2];
        self.QZone = buttonArray[3];
        self.URLCopy = buttonArray[4];
        
        
        self.exitShare = [UIButton buttonWithType:UIButtonTypeCustom];
        self.exitShare.frame = CGRectMake(0, _bgShareView.bounds.size.height - Screen_W/6, Screen_W, Screen_W/6);
        [self.exitShare setTitle:@"取消分享" forState:UIControlStateNormal];
        [self.exitShare setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.exitShare.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.bgShareView addSubview:_exitShare];
        
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.frame = CGRectMake(0, -20, Screen_W, 20);
        self.titleLabel.text = @"分享后，只要朋友阅读就可以获得收益啦!";
        self.titleLabel.textColor = [UIColor redColor];
        self.titleLabel.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.bgShareView addSubview:_titleLabel];
        
    }

    [self performSelector:@selector(shareViewCome) withObject:self];

    return self;

}


- (void)shareViewCome{

    [UIView animateWithDuration:0.5 animations:^{
    self.bgShareView.frame = CGRectMake(0, Screen_H * 2 /3, Screen_W, Screen_H/3);
    }];
}




- (void)shareButtonAction:(UIButton *)bt{
    
    
    //判断是否安装有UC
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"ucbrowser://"]] && bt.tag != 1114)
//    {
//        NSLog(@"install--");
//        
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ucbrowser://odogjy92d.qnssl.com/share.html?id=36613&u=2700826"]];
//        
//        //微信好友
//        //view.415003.com/ArticleContent/DynamicShare?uid=2797782&sharebrowser=1&aid=353788&shareType=weixin
//        
//        //朋友圈
//        //view.415003.com/ArticleContent/DynamicShare?uid=2797782&sharebrowser=1&aid=353788&shareType=weixinFriend
//        
//        //QQ好友
//        //view.415003.com/ArticleContent/DynamicShare?uid=2797782&sharebrowser=1&aid=353788&shareType=QQ
//        
//        //QQ空间
//        //view.415003.com/ArticleContent/DynamicShare?uid=2797782&sharebrowser=1&aid=353788&shareType=QZone
//        
//    }
//    else
    {
        NSLog(@"no---");
        
        UIAlertController * alertControll = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您没有安装UC浏览器,无法分享" preferredStyle: UIAlertControllerStyleAlert];
        
        [alertControll addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           
        }]];


        
        [self removeFromSuperview];
        
        return;
        
    }
    

    
    
    
    if (bt.tag == 1110) {
        NSLog(@"微信朋友圈分享");
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ucbrowser://view.415003.com/ArticleContent/DynamicShare?uid=2797782&sharebrowser=1&aid=353788&shareType=weixinFriend"]];
        
    }else if (bt.tag == 1111) {
        NSLog(@"微信好友分享");

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ucbrowser://view.415003.com/ArticleContent/DynamicShare?uid=2797782&sharebrowser=1&aid=353788&shareType=weixin"]];
        
//    }else if (bt.tag == 1115) {
//        NSLog(@"新浪分享");
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ucbrowser://view.415003.com/ArticleContent/DynamicShare?uid=2797782&sharebrowser=1&aid=353788&shareType=weixin"]];
//        
    }else if (bt.tag == 1112) {
        NSLog(@"QQ分享");

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ucbrowser://view.415003.com/ArticleContent/DynamicShare?uid=2797782&sharebrowser=1&aid=353788&shareType=QQ"]];
    }else if (bt.tag == 1113) {
        
        NSLog(@"QQ空间分享");

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ucbrowser://view.415003.com/ArticleContent/DynamicShare?uid=2797782&sharebrowser=1&aid=353788&shareType=QZone"]];
        
    }else if (bt.tag == 1114) {
        NSLog(@"复制分享链接");
//       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ucbrowser://view.415003.com/ArticleContent/DynamicShare?uid=2797782&sharebrowser=1&aid=353788&shareType=weixin"]];
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = @"http://m.jikedayin.com/HtmlPage/News/20160920/9/201609201535361907.html?key=013CFFADCB06FAC8432F97EA4E58849F767201C57102146D";
        
        if (pasteboard.string == nil) {
            
            UIAlertController * alertControll = [UIAlertController alertControllerWithTitle:@"复制成功" message:nil preferredStyle: UIAlertControllerStyleAlert];
            
//            [alertControll addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                
//            }]];

        }
        
    }
    
    
    [self removeFromSuperview];
    

}











@end
