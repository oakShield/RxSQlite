//
//  FMDBManager.m
//  RxFMDBManager
//
//  Created by RXL on 17/2/9.
//  Copyright © 2017年 RXL. All rights reserved.
//

#import "FMDBManager.h"

static NSString *domain = @"com.rxl.fmdbManager.ErrorDomain";
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

-(void)addStudentWithJsonArr:(NSArray *)jsonArr WithCompletion:(void (^)(NSError *error))completion{
    
    NSString *sql = @"INSERT INTO t_students (name,userId) VALUES (?,?);";
    
    __block NSError *error = nil;
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (NSDictionary *dict in jsonArr) {
            
            NSArray *studentData = @[dict[@"name"],dict[@"userId"]];
            
            if (![db executeUpdate:sql withArgumentsInArray:studentData]) {
                
                DLog(@"插入失败");
                
                error = [NSError errorWithDomain:domain code:1 userInfo:nil];
                
                //回滚
                *rollback = YES;
                
                break;
            }

        }
        completion(error);
        
    }];
    
}

-(NSArray *)selectStudentWithCondition:(NSString *)condition FromTable:(NSString *)tableName{
    
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",tableName,condition];
    
    __block NSMutableArray *resultArr = [NSMutableArray array];
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        FMResultSet *set = [db executeQuery:sql];
        
        for (int i = 0; i < [set columnCount]; ++i) {
            
            NSString *columnName = [set columnNameForIndex:i];
            
            NSString *columnValue = [set columnNameForIndex:i];
            
            DLog(@"%@ --- %@",columnName,columnValue);
            
            if (columnValue == nil) {
                columnValue = @"";
            }
            
            [resultArr addObject:@{columnName : columnValue}];
        }
        
    }];
    
    
    return resultArr;
}


@end
