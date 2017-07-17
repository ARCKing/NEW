//
//  ReuseManager.h
//  News
//
//  Created by ZZG on 16/5/30.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReuseManager : NSObject

@property (nonatomic ,strong)NSMutableArray *dataSource;

+(instancetype)shareManager;

@end
