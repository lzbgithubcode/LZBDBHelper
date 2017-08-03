//
//  LZBTestModel.h
//  LZBDBHelper
//
//  Created by zibin on 2017/8/2.
//  Copyright © 2017年 lzbgithubcode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZBDBModelProtocol.h"
@interface LZBTestModel : NSObject <LZBDBModelProtocol>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *icardId;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) CGFloat score;
@property (nonatomic, assign) BOOL sucess;
@end
