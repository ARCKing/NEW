//
//  ReuseManager.m
//  News
//
//  Created by ZZG on 16/5/30.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "ReuseManager.h"

@implementation ReuseManager

//单例 数据库只创建一次
+(instancetype)shareManager
{
    static ReuseManager *manager;
    static dispatch_once_t oneToken;
    
    dispatch_once(&oneToken, ^{
        manager =[[ReuseManager alloc]init];
        
    });
    return manager;
}


-(NSMutableArray *)dataSource
{
    if (_dataSource==nil) {
        _dataSource=[[NSMutableArray alloc]init];
    }
    return _dataSource;
}

@end
