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
-(void)executeUpdateWithJsonArr:(NSArray *)jsonArr WithCompletion:(void (^)(NSError *error))completion;



//查
-(NSArray *)executeStudentWithCondition:(NSString *)condition FromTable:(NSString *)tableName;

-(NSArray *)executeAllStudentFrom:(NSString *)tableName;

-(BOOL)executeTableExist:(NSString *)tableName;

@end
