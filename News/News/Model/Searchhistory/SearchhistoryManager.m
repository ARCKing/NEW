//
//  SearchhistoryManager.m
//  News
//
//  Created by ZZG on 16/6/28.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "SearchhistoryManager.h"

@implementation SearchhistoryManager

//单例 数据库只创建一次
+(instancetype)shareManager
{
    static SearchhistoryManager *manager;
    static dispatch_once_t oneToken;
    
    dispatch_once(&oneToken, ^{
        manager =[[SearchhistoryManager alloc]init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path=[NSHomeDirectory() stringByAppendingString:@"/Documents/SearchHistory.db"];
        
        self.SearchHistoryDataBase=[FMDatabase databaseWithPath:path];
        
        if (![self.SearchHistoryDataBase open]) {
            NSLog(@"数据库打开失败");
        }
        
        if (![self.SearchHistoryDataBase executeUpdate:@"create table if not exists SearchHistory (id integer primary key autoincrement,URlstr text,title text)"]) {
            NSLog(@"SearchHistory创建表格失败");
        }
    }
    return self;
}


@end
