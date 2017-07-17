//
//  UCShareView.h
//  webShare
//
//  Created by gxtc on 16/9/21.
//  Copyright © 2016年 gxtc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UCShareView : UIView

@property (nonatomic,copy)NSString * userID;
@property (nonatomic,copy)NSString * articalID;

@property (nonatomic,strong)UIButton * weixinFriend;
@property (nonatomic,strong)UIButton * weixin;
@property (nonatomic,strong)UIButton * sinaWeiBo;
@property (nonatomic,strong)UIButton * QQ;
@property (nonatomic,strong)UIButton * QZone;
@property (nonatomic,strong)UIButton * URLCopy;

@property (nonatomic,strong)UIButton * exitShare;

@property (nonatomic,strong)UIView * bgShareView;

@end
