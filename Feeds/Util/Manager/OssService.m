//
//  OssService.m
//  Feeds
//
//  Created by 宋国华 on 2018/8/17.
//  Copyright © 2018年 swing. All rights reserved.
//

#import "OssService.h"
#import <AliyunOSSiOS/OSSService.h>

NSString * const BUCKET_NAME = @"mybucket-swing";
NSString * const endPoint = @"https://oss-cn-beijing.aliyuncs.com";
NSString * const AccessKeyId = @"LTAIPLIion21luIh";
NSString * const AccessKeySecret = @"1ouJ2PyLsjTECLQnbBaWP8YEomSXnx";

@interface OssService () {
    OSSClient * client;
    OSSPutObjectRequest * putRequest;
    BOOL isCancelled;
}

@end

@implementation OssService

- (id)init {
    if (self = [super init]) {
        isCancelled = NO;
        [self ossInit];
    }
    return self;
}

/**
 *    @brief    初始化获取OSSClient
 */
- (void)ossInit {
    id<OSSCredentialProvider> credential = [[OSSCustomSignerCredentialProvider alloc] initWithImplementedSigner:^NSString *(NSString *contentToSign, NSError *__autoreleasing *error) {
        // 您需要在这里依照OSS规定的签名算法，实现加签一串字符内容，并把得到的签名传拼接上AccessKeyId后返回
        // 一般实现是，将字符内容post到您的业务服务器，然后返回签名
        // 如果因为某种原因加签失败，描述error信息后，返回nil
        NSString *signature = [OSSUtil calBase64Sha1WithData:contentToSign withSecret:AccessKeySecret]; // 这里是用SDK内的工具函数进行本地加签，建议您通过业务server实现远程加签
        if (signature != nil) {
            *error = nil;
        } else {
            *error = [NSError errorWithDomain:@"<your domain>" code:-1001 userInfo:@{@"error":@"info"}];
            return nil;
        }
        return [NSString stringWithFormat:@"OSS %@:%@", AccessKeyId, signature];
    }];
    client = [[OSSClient alloc] initWithEndpoint:endPoint credentialProvider:credential];
}

/**
 *    @brief    上传图片
 *
 *    @param     image         图片
 */
- (void)putImage:(UIImage *)image
          compression:(BOOL)compression
              success:(SuccessBlock)succeesBlock
               failed:(FailedBlock)failedBlock {
    if (image == nil) {
        return;
    }
    
    putRequest = [OSSPutObjectRequest new];
    putRequest.bucketName = BUCKET_NAME;
    NSString *objectKey;
    NSData *objectData;
    if (compression) {
        objectKey = [NSString stringWithFormat:@"%@.jpg",[OssService getFileName]];
        objectData = UIImageJPEGRepresentation(image, 0.5);
    } else {
        objectKey = [NSString stringWithFormat:@"%@.png",[OssService getFileName]];
        objectData = UIImagePNGRepresentation(image);
    }
    putRequest.objectKey = objectKey;
    putRequest.uploadingData = objectData;
    putRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    OSSTask * task = [client putObject:putRequest];
    [task continueWithBlock:^id(OSSTask *task) {
        // 查看server callback是否成功
        if (!task.error) {
            NSLog(@"Put image success!");
            succeesBlock(objectKey);
        } else {
            NSLog(@"Put image failed, %@", task.error);
            failedBlock(task.error);
        }
        self->putRequest = nil;
        return nil;
    }];
}

- (void)deleteImage:(NSString *)key success:(SuccessBlock)succeesBlock failed:(FailedBlock)failedBlock {
    OSSDeleteObjectRequest * delete = [OSSDeleteObjectRequest new];
    delete.bucketName = BUCKET_NAME;
    delete.objectKey = key;
    OSSTask * deleteTask = [client deleteObject:delete];
    [deleteTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            succeesBlock(@"删除成功!");
        } else {
            NSLog(@"删除图片失败, %@", task.error);
            failedBlock(task.error);
        }
        self->putRequest = nil;
        return nil;
    }];
}

/**
 *    @brief    普通上传/下载取消
 */
- (void)normalRequestCancel {
    if (putRequest) {
        [putRequest cancel];
    }
}

/** 图片的路径名 */
+ (NSString *)getFileName {
    NSString *newUuidStr = [[[NSString generateUuidString] stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%@/%@-%@-%@-%@",kAppCurName,@(components.year),@(components.month),@(components.day),newUuidStr];
}


@end
