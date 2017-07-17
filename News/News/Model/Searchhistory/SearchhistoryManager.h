//
//  SearchhistoryManager.h
//  News
//
//  Created by ZZG on 16/6/28.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
@interface SearchhistoryManager : NSObject

@property (nonatomic , strong) FMDatabase *SearchHistoryDataBase;


+(instancetype)shareManager;


@end
