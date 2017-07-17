//
//  CollectionManager.m
//  
//
//  Created by siyue on 16/5/25.
//
//

#import "CollectionManager.h"

@implementation CollectionManager


//单例 数据库只创建一次
+(instancetype)shareManager
{
    static CollectionManager *manager;
    static dispatch_once_t oneToken;
    
    dispatch_once(&oneToken, ^{
        manager =[[CollectionManager alloc]init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path=[NSHomeDirectory() stringByAppendingString:@"/Documents/Collection.db"];
        
        self.CollectionDataBase=[FMDatabase databaseWithPath:path];
        
        if (![self.CollectionDataBase open]) {
            NSLog(@"数据库打开失败");
        }
        
        if (![self.CollectionDataBase executeUpdate:@"create table if not exists Collection (id integer primary key autoincrement,renwuID text,title text)"]) {
            NSLog(@"history创建表格失败");
        }
        
        
    }
    return self;
}


@end
