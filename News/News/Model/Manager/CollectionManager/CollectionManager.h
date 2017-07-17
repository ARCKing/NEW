//
//  CollectionManager.h
//  
//
//  Created by siyue on 16/5/25.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"


@interface CollectionManager : NSObject

@property (nonatomic , strong) FMDatabase *CollectionDataBase;


+(instancetype)shareManager;

@end
