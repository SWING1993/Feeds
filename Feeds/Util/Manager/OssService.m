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
NSString * const AccessKeyId = @"LTAIn5TU8CkkVdIp";
NSString * const AccessKeySecret = @"vFp8Zxg0apNnNByoeswRfbS4WzjJ9q";

@interface OssService () {
    OSSClient * client;
    NSString * callbackAddress;
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
 *    @param     objectKey     objectKey
 *    @param     image         图片
 */
- (void)asyncPutImage:(NSString *)objectKey
        image:(UIImage *)image {
    if (objectKey == nil || [objectKey length] == 0) {
        return;
    }
    putRequest = [OSSPutObjectRequest new];
    putRequest.bucketName = BUCKET_NAME;
    putRequest.objectKey = objectKey;
    putRequest.uploadingData = UIImagePNGRepresentation(image); // 直接上传NSData
    putRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    if (callbackAddress != nil) {
        putRequest.callbackParam = @{
                                     @"callbackUrl": callbackAddress,
                                     // callbackBody可自定义传入的信息
                                     @"callbackBody": @"filename=${object}"
                                     };
    }
    OSSTask * task = [client putObject:putRequest];
    [task continueWithBlock:^id(OSSTask *task) {
        OSSPutObjectResult * result = task.result;
        // 查看server callback是否成功
        if (!task.error) {
            NSLog(@"Put image success!");
            NSLog(@"server callback : %@", result.serverReturnJsonString);
            dispatch_async(dispatch_get_main_queue(), ^{
//                [viewController showMessage:@"普通上传" inputMessage:@"Success!"];
            });
        } else {
            NSLog(@"Put image failed, %@", task.error);
            if (task.error.code == OSSClientErrorCodeTaskCancelled) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [viewController showMessage:@"普通上传" inputMessage:@"任务取消!"];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [viewController showMessage:@"普通上传" inputMessage:@"Failed!"];
                });
            }
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


@end
