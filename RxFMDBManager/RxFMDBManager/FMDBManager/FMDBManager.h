//
//  FMDBManager.h
//  RxFMDBManager
//
//  Created by RXL on 17/2/9.
//  Copyright © 2017年 RXL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMDBManager : NSObject

+ (instancetype)sharedFMDBManager;

//增
-(void)addStudentWithJsonArr:(NSArray *)jsonArr WithCompletion:(void (^)(NSError *error))completion;



//查
-(NSArray *)selectStudentWithCondition:(NSString *)condition FromTable:(NSString *)tableName;



@end
