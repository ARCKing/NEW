//
//  PersonManager.h
//  News
//
//  Created by ZZG on 16/6/2.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"


@interface PersonManager : NSObject

@property (nonatomic , strong) FMDatabase *PersonDataBase;

+(instancetype)shareManager;


@end
