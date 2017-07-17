//
//  PersonManager.m
//  News
//
//  Created by ZZG on 16/6/2.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "PersonManager.h"

@implementation PersonManager

//单例 数据库只创建一次
+(instancetype)shareManager
{
    static PersonManager *manager;
    static dispatch_once_t oneToken;
    
    dispatch_once(&oneToken, ^{
        manager =[[PersonManager alloc]init];
    });
    return manager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path=[NSHomeDirectory() stringByAppendingString:@"/Documents/Person.db"];
        
        NSLog(@"[数据库地址%@]",path);
        
        self.PersonDataBase=[FMDatabase databaseWithPath:path];
        
        if (![self.PersonDataBase open]) {
            NSLog(@"数据库打开失败");
        }
        
        if (![self.PersonDataBase executeUpdate:@"create table if not exists Person(id integer primary key autoincrement,headimgurl text,nickname text,member_id text,phone text,level text)"]) {
            NSLog(@"person创建表格失败");
        }
    }
    return self;
    /*
     authcode = b787jJ8SJ39pTPp8L56guJZDQewfPDAvaoEAD5T0vJsbqWtc;
     code = 1;
     member =     {
     "app_shoutu_url" = "http://wzl.91huiduo.com/shoutu?u=2698797";
     "avatar_100" = "";
     "avatar_200" = "";
     city = "<null>";
     country = "<null>";
     day = 14;
     duobao = 0;
     headimgurl = "<null>";
     id = 2498678;
     inputtime = 1463649347;
     integral = "0.000";
     inviter = 0;
     "is_auth" = 1;
     "is_bind" = 1;
     "is_inviter_re" = 0;
     lasttime = 1464833245;
     level = 0;
     "member_auth" = b787jJ8SJ39pTPp8L56guJZDQewfPDAvaoEAD5T0vJsbqWtc;
     "member_id" = 2698797;
     "new_hb" = 0;
     "new_jiaochen" = 0;
     nickname = oZWGvqmg;
     oiv = 0;
     openid = "";
     ouid = 0;
     phone = 18025452961;
     "prentice_num" = 0;
     "prentice_sum_money" = "0.000";
     privilege = "<null>";
     province = "<null>";
     rate = "0.15";
     "residue_money" = "0.000";
     sex = "<null>";
     "shoutu_url" = "http://wz.lefei.com/shoutu?u=2698797";
     state = 1;
     "sum_money" = "0.000";
     "today_info" =         {
     "today_income" = 0;
     "today_prentice" = 0;
     };
     "uc_id" = 2698797;
     unionid = "<null>";
     };
     message = "\U767b\U5f55\U6210\U529f";
     */
}
@end
