//
//  LZBDBHelperTest.m
//  LZBDBHelper
//
//  Created by zibin on 2017/8/3.
//  Copyright © 2017年 lzbgithubcode. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LZBDBHelper.h"
#import "LZBTestModel.h"

@interface LZBDBHelperTest : XCTestCase

@end

@implementation LZBDBHelperTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/**
 保存模型
 */
- (void)testSaveModel {
    LZBTestModel *model = [[LZBTestModel alloc]init];
    model.name = @"子彬";
    model.icardId = @"11";
    model.age = 14;
    model.score = 21.0;
    model.sucess = YES;
    BOOL result =  [LZBDBHelper saveDBModel:model userId:nil];
   XCTAssertTrue(result);
}


/**
 更新模型
 */
- (void)testUdpateModel {
    LZBTestModel *model = [[LZBTestModel alloc]init];
    model.name = @"燕子";
    model.icardId = @"12";
    model.age = 16;
    model.score = 21.0;
    model.sucess = YES;
    BOOL result =  [LZBDBHelper updateDBModel:model userId:nil];
    XCTAssertTrue(result);
}

/**
 删除模型
 */
- (void)testDeleteModel {
    LZBTestModel *model = [[LZBTestModel alloc]init];
    model.icardId = @"6";
    BOOL result =  [LZBDBHelper deleteDBModel:model userId:nil];
    XCTAssertTrue(result);
}

/**
 删除模型 年龄小于18
 */
- (void)testDeleteModelWhere{
    BOOL result =  [LZBDBHelper deleteDBModel:[LZBTestModel class] columnName:@"age" relation:LZBIvarNameToValueRelationType_LessEqual value:@(18) userId:nil];
    XCTAssertTrue(result);
}


- (void)testQueryModel{
    NSArray *result =  [LZBDBHelper queryDBModel:[LZBTestModel class] userId:nil];
    XCTAssertTrue(result.count > 0);
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
