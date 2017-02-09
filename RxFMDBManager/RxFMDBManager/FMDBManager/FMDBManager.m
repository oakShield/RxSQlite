//
//  FMDBManager.m
//  RxFMDBManager
//
//  Created by RXL on 17/2/9.
//  Copyright © 2017年 RXL. All rights reserved.
//

#import "FMDBManager.h"

@implementation FMDBManager
+ (instancetype)sharedFMDBManager {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return self;
}
@end
