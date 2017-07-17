//
//  DataMansger.m
//  News
//
//  Created by ZZG on 16/5/31.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "DataMansger.h"

@implementation DataMansger
//单例 数据库只创建一次
+(instancetype)shareManager
{
    static DataMansger *manager;
    static dispatch_once_t oneToken;
    
    dispatch_once(&oneToken, ^{
        manager =[[DataMansger alloc]init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path=[NSHomeDirectory() stringByAppendingString:@"/Documents/NetworkData.db"];
        self.NetWorkDataBase=[FMDatabase databaseWithPath:path];
        if (![self.NetWorkDataBase open]) {
            NSLog(@"数据库打开失败");
        }
        NSArray *array=@[@"NetworkDat",@"NetworkDat1",@"NetworkData2",@"NetworkData3",@"NetworkData4",@"NetworkData5",@"NetworkData6",@"NetworkDat7",@"NetworkDat8",@"NetworkDat9",@"NetworkDat10",@"NetworkDat11",@"NetworkDat12",@"NetworkDat13",@"NetworkDat14",@"NetworkDat15",@"NetworkDat16",@"NetworkDat17"];
        
        for (int i=0; i<array.count; i++) {
            NSString *sqlString = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement,title text,addtime text,img blob,view_count text,thumb text,NewsID text,is_hot text,is_rec text)",array[i]];
        
            if (![self.NetWorkDataBase executeUpdate:sqlString]) {
                 NSLog(@"NetworkDat创建表格失败");
             }
        }
    }
    return self;
}
@end
