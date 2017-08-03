//
//  NSObject+LZBDBModelHelper.m
//  LZBDBHelper
//
//  Created by zibin on 2017/8/3.
//  Copyright © 2017年 lzbgithubcode. All rights reserved.
//

#import "NSObject+LZBDBModelHelper.h"
#import "LZBDBHelperMacro.h"
#import "LZBDBModelProtocol.h"
#import <objc/runtime.h>

@implementation NSObject (LZBDBModelHelper)

+ (NSString *)db_getTabbleName
{
    return NSStringFromClass(self);
}
+ (NSString *)db_getTabbleTempName
{
    return [NSStringFromClass(self) stringByAppendingString:@"_tmp"];
}

+ (NSDictionary *)db_ClassIvarNameAndIvarTypeDict
{
    if(![self checkModelClass]) return nil;
    //1.runtime获取成员变量,但是是带有下划线的，索引需要去掉下滑线
    unsigned int outCount = 0;
    Ivar *ivarList = class_copyIvarList(self, &outCount);
    NSMutableDictionary *nameTypeDict = [NSMutableDictionary dictionary];
    
    //1.1获取忽略字段数组
    Class cls = self;
    NSArray *ignoreNames = nil;
    if([cls respondsToSelector:@selector(model_ignoreColumnNames)])
    {
        ignoreNames = [cls model_ignoreColumnNames];
    }
    //2.遍历成员变量列表
    for (NSInteger i = 0; i < outCount; i++) {
        
        Ivar ivar = ivarList[i];
        //2.1获取成员变量名称
        const char *ivarNameC =  ivar_getName(ivar);
        NSString *ivarName = [NSString stringWithUTF8String:ivarNameC];
        if([ivarName hasPrefix:@"_"])
            ivarName = [ivarName substringFromIndex:1];
        
        //忽略字段
        if([ignoreNames containsObject:ivarName])
            continue;
        
        //2.2获取成员变量类型
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        type = [type stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        
        //2.3赋值
        [nameTypeDict setObject:type forKey:ivarName];
    }
    
    return nameTypeDict;
}

+ (NSDictionary *)db_ClassIvarNameAndMapSqliteTypeDict
{
    NSMutableDictionary *originDict = [[self db_ClassIvarNameAndIvarTypeDict] mutableCopy];
    NSDictionary *sqliteDict = [self ocTypeMapToSqliteTypeDict];
    [originDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        originDict[key] = sqliteDict[obj];
    }];
    return originDict;
}
+ (NSString *)db_ClassColumnNameAndMapSqliteTypeString
{
    NSDictionary *nameTypeDict = [self db_ClassIvarNameAndMapSqliteTypeDict];
    NSMutableArray *resultArray = [NSMutableArray array];
    [nameTypeDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        [resultArray addObject:[NSString stringWithFormat:@"%@ %@",key,obj]];
    }];
    return [resultArray componentsJoinedByString:@","];
}
+ (NSArray *)db_ClassAllSortedIvarNames
{
    NSDictionary *dict = [self db_ClassIvarNameAndIvarTypeDict];
    NSArray *keys = dict.allKeys;
    //不可变的排序需要手动接受
    keys  = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    return keys;
}


#pragma mark - private
+ (BOOL)checkModelClass
{
    if ([self isSubclassOfClass:[NSObject class]])
        return YES;
    LZBNSLog(@"%@ not used",self);
    return NO;
    
}

+ (NSDictionary *)ocTypeMapToSqliteTypeDict{
    return @{
             @"d": @"real", // double
             @"f": @"real", // float
             
             @"i": @"integer",  // int
             @"q": @"integer", // long
             @"Q": @"integer", // long long
             @"B": @"integer", // bool
             
             @"NSData": @"blob",
             @"NSDictionary": @"text",
             @"NSMutableDictionary": @"text",
             @"NSArray": @"text",
             @"NSMutableArray": @"text",
             
             @"NSString": @"text"
             };
}
@end
