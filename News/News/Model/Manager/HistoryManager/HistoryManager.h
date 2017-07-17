//
//  HistoryManager.h
//  
//
//  Created by siyue on 16/5/25.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface HistoryManager : NSObject

@property (nonatomic , strong) FMDatabase *HistoryDataBase;


+(instancetype)shareManager;


@end
