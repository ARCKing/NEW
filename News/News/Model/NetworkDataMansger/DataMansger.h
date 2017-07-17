//
//  DataMansger.h
//  News
//
//  Created by ZZG on 16/5/31.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
@interface DataMansger : NSObject

@property (nonatomic , strong) FMDatabase *NetWorkDataBase;


+(instancetype)shareManager;



@end
