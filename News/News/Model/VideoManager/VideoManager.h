//
//  VideoManager.h
//  News
//
//  Created by ZZG on 16/6/15.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface VideoManager : NSObject

@property (nonatomic , strong) FMDatabase *VideoDataBase;


+(instancetype)shareManager;



@end
