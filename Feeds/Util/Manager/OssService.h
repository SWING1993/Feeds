//
//  OssService.h
//  Feeds
//
//  Created by 宋国华 on 2018/8/17.
//  Copyright © 2018年 swing. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const BUCKET_NAME;
extern NSString* const endPoint;
extern NSString* const AccessKeyId;
extern NSString* const AccessKeySecret;

@interface OssService : NSObject

- (id)init;

- (void)asyncPutImage:(NSString *)objectKey
                image:(UIImage *)image;

- (void)normalRequestCancel;

@end
