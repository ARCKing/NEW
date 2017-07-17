//
//  ZGNetAPI.h
//  News
//
//  Created by ZZG on 16/6/1.
//  Copyright © 2016年 siyue. All rights reserved.
//

#ifndef ZGNetAPI_h
#define ZGNetAPI_h

//评论列表
#define KURL_publishedList  @"http://wz.lefei.com/Api/Duoshuo/getComment"


//评论数目
#define KURL_publishedNumber @"http://wz.lefei.com/Api/Duoshuo/counts"

//发表评论
#define KURL_published  @"http://wz.lefei.com/Api/Duoshuo/create"

//详情页
#define KURL_Detail @"http://wz.lefei.com/?m=Api&c=Api&a=getInfo"


//点赞
#define KURL_Zan  @"http://wz.lefei.com/?m=Api&c=Video&a=zan"

//用户注册 发送验证码

#define KURL_UserCode @"http://wz.lefei.com/Api/MemberPublic/send_msm/"

//注册
#define KURL_Regis @"http://wz.lefei.com/Api/MemberPublic/register"

//登入
#define KURL_Login @"http://wz.lefei.com/?m=Api&c=Member&a=login"

//找回密码发送验证码
#define KURL_FindPasswordCode @"http://wz.lefei.com/Api/Service/sendAppMsm"

//找回密码
#define KURL_FindPassword @"http://wz.lefei.com/Api/Service/wjmm"

//修改密码

#define KURL_changePassWord @"http://wz.lefei.com/?m=Api&c=Member&a=password"

//我的等级
#define KURL_Level  @"http://wz.lefei.com/?m=api&c=member&a=level"

//修改昵称
#define KURL_changename  @"http://wz.lefei.com/?m=Api&c=Member&a=nickname"

//修改头像
#define KURL_changepersonImage  @"http://wz.lefei.com/?m=Api&c=MemberPublic&a=avatar"

//获取绑定数据信息
#define KURL_binding  @"http://wz.lefei.com/Api/MemberBind/index"

//绑定支付宝
#define KURL_Alipay  @"http://wz.lefei.com/Api/MemberBind/alipay"

//绑定微信
#define KURL_weixin  @"http://wz.lefei.com/Api/MemberBind/wxpay"

//立即兑换
#define KURL_WithDrawal  @"http://wz.lefei.com/Api/Integral/ex_index"

//支付宝提现
#define KURL_WithDrawalAlipay  @"http://wz.lefei.com/Api/Integral/put_alipay"

//微信提现
#define KURL_WithDrawalWxpay  @"http://wz.lefei.com/Api/Integral/put_wxpay"

//提现记录
#define KURL_Record  @"http://wz.lefei.com/Api/Integral/ex_log"

//我的邀请
#define KURL_MYInvitation  @"http://wz.lefei.com/Api/Integral/getMyFriend";

//邀请首页
#define KURL_Invitation @"http://wz.lefei.com/Api/Yaoqing/index"

//提交邀请码
#define KURL_UPInvitation @"http://wz.lefei.com/Api/Yaoqing/yqm"

//收入  支出
#define KURL_Income @"http://wz.lefei.com/?m=Api&c=Integral&a=getDetail"


//获取视频分类
#define KURL_VideoClass @"http://wz.lefei.com/?m=Api&c=video&a=getClass"

//获取视频数据
#define KURL_Video @"http://wz.lefei.com/?m=Api&c=video&a=getList"

#endif /* ZGNetAPI_h */
