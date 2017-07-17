//
//  HistoryManager.m
//  
//
//  Created by siyue on 16/5/25.
//
//

#import "HistoryManager.h"



@implementation HistoryManager

//单例 数据库只创建一次
+(instancetype)shareManager
{
    static HistoryManager *manager;
    static dispatch_once_t oneToken;
    
    dispatch_once(&oneToken, ^{
        manager =[[HistoryManager alloc]init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path=[NSHomeDirectory() stringByAppendingString:@"/Documents/History.db"];
        
        self.HistoryDataBase=[FMDatabase databaseWithPath:path];
        
        if (![self.HistoryDataBase open]) {
            NSLog(@"数据库打开失败");
        }
        
        if (![self.HistoryDataBase executeUpdate:@"create table if not exists history (id integer primary key autoincrement,HistoryID text,title text)"]) {
            NSLog(@"history创建表格失败");
        }
    }
    return self;
}
@end
