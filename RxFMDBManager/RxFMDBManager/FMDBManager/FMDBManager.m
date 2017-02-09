//
//  FMDBManager.m
//  RxFMDBManager
//
//  Created by RXL on 17/2/9.
//  Copyright © 2017年 RXL. All rights reserved.
//

#import "FMDBManager.h"

FMDatabaseQueue *queue;

@implementation FMDBManager
+ (instancetype)sharedFMDBManager {
    
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
        
        queue = [FMDatabaseQueue databaseQueueWithPath:SQlitePath(@"students")];
        
        [instance creatTable];
    });
    return instance;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    
    
    return self;
}

#pragma mark - 建表/增删改查

-(void)creatTable{
    //建表sql语句
    NSString *creatTableSql = @"CREATE TABLE IF NOT EXISTS t_students (userId TEXT PRIMARY KEY,name TEXT NOT NULL);";
    
    [queue inDatabase:^(FMDatabase *db) {
        
        if ([db executeStatements:creatTableSql]) {
            DLog(@"建表成功");
            
        }else{
            DLog(@"建表失败");
        }
        
    }];
}

-(void)addStudentWithJsonArr:(NSArray *)jsonArr WithErrorBlock:(void(^)())errorBlock{
    
    NSString *sql = @"INSERT OR REPLACE INTO t_students (name,userId) VALUES (?,?);";
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (NSDictionary *dict in jsonArr) {
            
            NSArray *studentData = @[dict[@"name"],dict[@"userId"]];
            
            if (![db executeUpdate:sql withArgumentsInArray:studentData]) {
                
                DLog(@"插入失败");
                
                //回滚
                *rollback = YES;
                
                break;
            }

        }
    }];
    
    
}

@end
