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
-(void)addStudentWithJsonArr:(NSArray *)jsonArr WithSuccess:(void (^)(NSError *error))completion;

@end
