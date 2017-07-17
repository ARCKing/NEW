//
//  VideoManager.m
//  News
//
//  Created by ZZG on 16/6/15.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "VideoManager.h"

@implementation VideoManager

//单例 数据库只创建一次
+(instancetype)shareManager
{
    static VideoManager *manager;
    static dispatch_once_t oneToken;
    
    dispatch_once(&oneToken, ^{
        manager =[[VideoManager alloc]init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path=[NSHomeDirectory() stringByAppendingString:@"/Documents/Video.db"];
        
        self.VideoDataBase=[FMDatabase databaseWithPath:path];
        
        if (![self.VideoDataBase open]) {
            NSLog(@"数据库打开失败");
        }
        
        
        NSArray *array=@[@"video",@"video1",@"video2",@"video3",@"video4",@"video5",@"video6",@"video7",@"video8",@"video9",@"video10",@"video11",@"video12",@"video13",@"video14",@"video15"];
        
        for (int i=0; i<array.count; i++) {
            
            NSString *SQLStr=[NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement,caption text,cover_pic text,user_name text,video_id text,likes_count text,user_avatar text,video text)",array[i]];
            
            if (![self.VideoDataBase executeUpdate:SQLStr]) {
                NSLog(@"VideoDataBase创建表格失败");
            }
        }
        
    }
    return self;
}


@end
