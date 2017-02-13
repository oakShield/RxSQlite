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

-(void)executeUpdateWithJsonArr:(NSArray *)jsonArr WithCompletion:(void (^)(NSError *error))completion{
    
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

-(NSArray *)executeStudentWithCondition:(NSString *)condition FromTable:(NSString *)tableName{
    
    //查询userID为condition或者NAME包含condition的
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE USERID = '%@' OR NAME LIKE '%%%@%%'",tableName,condition,condition];
    
    __block NSMutableArray *resultArr = [NSMutableArray array];
    
    //查询不需要开启事务
    [queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *set = [db executeQuery:sql];
        
        while ([set next]) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            for (int i = 0; i < [set columnCount]; ++i) {
                
                NSString *columnName = [set columnNameForIndex:i];
                
                NSString *columnValue = [set stringForColumnIndex:i];
                
//                DLog(@"%@ --- %@",columnName,columnValue);
                
                if (columnValue == nil) {
                    columnValue = @"";
                }
                
                [dict setValue:columnValue forKey:columnName];
            }
            
            [resultArr addObject:dict];
        }
        
    }];
    

    
    return resultArr;
}

-(NSArray *)executeAllStudentFrom:(NSString *)tableName{
    
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
    
    __block NSMutableArray *resultArr = [NSMutableArray array];
    
    //查询不需要开启事务
    [queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *set = [db executeQuery:sql];
        
        while ([set next]) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            for (int i = 0; i < [set columnCount]; ++i) {
                
                NSString *columnName = [set columnNameForIndex:i];
                
                NSString *columnValue = [set stringForColumnIndex:i];
                
                DLog(@"%@ --- %@",columnName,columnValue);
                
                if (columnValue == nil) {
                    columnValue = @"";
                }
                
                [dict setValue:columnValue forKey:columnName];
            }
            
            [resultArr addObject:dict];
        }
        
    }];
    
    return resultArr;
}

-(BOOL)executeTableExist:(NSString *)tableName{
    
    __block BOOL isExist = NO;
    
    [queue inDatabase:^(FMDatabase *db) {
       
        isExist = [db tableExists:tableName];
        
    }];
    
    return isExist;
}


-(void)executeDeleteWithCondition:(NSString *)condition FromTable:(NSString *)tableName{
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE userId = '%@'",tableName,condition];
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
       
        if (![db executeUpdate:sql]) {
            *rollback = YES;
        }
        
    }];
    
}

-(void)executeFixWithCondition:(NSString *)condition ToNewName:(NSString *)newName FromTable:(NSString *)tableName WithCompletion:(void (^)(NSError *error))completion{
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET name = '%@' WHERE userId = '%@'",tableName,newName,condition];
    
    __block NSError *error = nil;
    
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
       
        if (![db executeUpdate:sql]) {
            
            error = [NSError errorWithDomain:domain code:1 userInfo:nil];
            
            *rollback = YES;
        }
        NSLog(@"%@", [NSThread currentThread]);
        completion(error);
    }];
}

@end
