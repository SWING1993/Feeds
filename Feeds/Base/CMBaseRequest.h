//
//  CMBaseRequest.h
//  MpmPackStone
//
//  Created by 宋国华 on 2018/8/2.
//  Copyright © 2018年 7cm. All rights reserved.
//

#import "YTKBaseRequest.h"

@interface CMBaseRequest : YTKRequest

- (id)initWithRequestUrl:(NSString *)requestUrl requestMethod:(YTKRequestMethod)requestMethod requestArgument:(id)requestArgument;

@end
