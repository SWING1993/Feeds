//
//  CMBaseRequest.m
//  MpmPackStone
//
//  Created by 宋国华 on 2018/8/2.
//  Copyright © 2018年 7cm. All rights reserved.
//

#import "CMBaseRequest.h"

@interface CMBaseRequest ()

@property (nonatomic, copy) NSString *cmRequestUrl;

@property (nonatomic, assign) YTKRequestMethod cmRequestMethod;

@property (nonatomic, strong) id cmRequestArgument;

@end

@implementation CMBaseRequest

- (id)initWithRequestUrl:(NSString *)requestUrl requestMethod:(YTKRequestMethod)requestMethod requestArgument:(id)requestArgument {
    self = [super init];
    if (self) {
        if ([kBaseUrl hasPrefix:@"http://swing1993"]) {
            self.cmRequestUrl = [NSString stringWithFormat:@"/cuckoo%@",requestUrl];
        } else {
            self.cmRequestUrl = requestUrl;
        }
        self.cmRequestMethod = requestMethod;
        self.cmRequestArgument = requestArgument;
    }
    return self;
}

#pragma mark - 覆盖父类的方法

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeHTTP;
}

- (NSTimeInterval)requestTimeoutInterval {
    return 30.f;
}

- (NSString *)requestUrl {
    return self.cmRequestUrl;
}

- (YTKRequestMethod)requestMethod {
    return self.cmRequestMethod;
}

- (id)requestArgument {
    return self.cmRequestArgument;
}

@end
