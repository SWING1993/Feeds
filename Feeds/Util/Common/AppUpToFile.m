//
//  AppUpToFile.m
//  Feeds
//
//  Created by 宋国华 on 2018/8/8.
//  Copyright © 2018年 swing. All rights reserved.
//

#import "AppUpToFile.h"
static NSString *const P_QiniuUpToken = @"P_QiniuUpToken";
static NSString *const P_QiniuUpTokenTime = @"P_QiniuUpTokenTime";
/** upToken 七牛上传 token */
static NSString *const SG_QiniuUpToken = @"SG_QiniuUpToken";
/** upToken 七牛上传 time */
static NSString *const SG_QiniuUpTokenTime = @"SG_QiniuUpTokenTime";

@implementation AppUpToFile

+ (void)upToData:(NSData *)data backInfo:(QNUpCompletionHandler)backInfo {
    QNUploadOption *aQNUploadOption = nil;
    NSString *strUptoken = [AppUpToFile isNeedRequestToGetUptoken];
    if ([strUptoken length] > 0) {
        QNUploadManager *upManager = [[QNUploadManager alloc] init];
        [upManager putData:data key:[AppUpToFile getFileName] token:strUptoken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            backInfo(info, key, resp);
            if (resp == nil) {
                [AppUpToFile uploadQiNiuFailed:info key:key];
                [AppUpToFile removeSG_UpToken];
            }
        } option:aQNUploadOption];
    } else {
        [AppUpToFile getUptoken:^(NSString *upToken) {
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putData:data key:[AppUpToFile getFileName] token:upToken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                backInfo(info, key, resp);
                if (resp == nil) {
                    [AppUpToFile uploadQiNiuFailed:info key:key];
                    [AppUpToFile removeSG_UpToken];
                }
            } option:aQNUploadOption];
        } doLaterFail:^{
            [AppUpToFile removeSG_UpToken];
            backInfo([QNResponseInfo new], [NSString new], [NSDictionary new]);
        }];
    }
}

+ (void)privateUpToData:(NSData *)data backInfo:(QNUpCompletionHandler)backInfo {
    QNUploadOption *aQNUploadOption = [[QNUploadOption alloc] initWithMime:@"image/jpeg" progressHandler:nil params:nil checkCrc:NO cancellationSignal:nil];
    
    NSString *strUptoken = nil;
    NSString *strTime = [[NSUserDefaults standardUserDefaults] objectForKey:P_QiniuUpTokenTime];
    if ([strTime length] > 0) {
        NSDate *dateNow = [NSDate date];
        NSDate *date    = [NSDate dateWithString:strTime format:@"YYYY-MM-dd HH:mm:ss"];
        
        if ([dateNow compare:date] == NSOrderedAscending) {
            strUptoken = [[NSUserDefaults standardUserDefaults] objectForKey:P_QiniuUpToken];
        }
    }
    
    if ([strUptoken length] > 0) {
        QNUploadManager *upManager = [[QNUploadManager alloc] init];
        [upManager putData:data key:[AppUpToFile getFileName] token:strUptoken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            backInfo(info, key, resp);
            if (resp == nil) {
                [AppUpToFile uploadQiNiuFailed:info key:key];
                [AppUpToFile removeP_UpToken];
            }
        } option:aQNUploadOption];
    } else {
        [AppUpToFile getPrivateUptoken:^(NSString *upToken) {
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putData:data key:[AppUpToFile getFileName] token:upToken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                backInfo(info, key, resp);
                if (resp == nil) {
                    [AppUpToFile uploadQiNiuFailed:info key:key];
                    [AppUpToFile removeP_UpToken];
                }
            } option:aQNUploadOption];
        } doLaterFail:^{
            [AppUpToFile removeP_UpToken];
            backInfo([QNResponseInfo new], [NSString new], [NSDictionary new]);
        }];
    }
}

+ (void)upToPHAsset:(PHAsset *)asset index:(NSInteger)index resultHandler:(PHResultHandler)resultHandler completionHandler:(PHAssetCompletionHandler)completionHandler {
    PHImageRequestOptions *request = [PHImageRequestOptions new];
    request.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    request.resizeMode = PHImageRequestOptionsResizeModeExact;
    request.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(1920, 1080) contentMode:PHImageContentModeDefault options:request resultHandler:^(UIImage *result, NSDictionary *info) {
        resultHandler(result, info);
        
        QNUploadOption *aQNUploadOption = [[QNUploadOption alloc] initWithMime:@"image/jpeg" progressHandler:nil params:nil checkCrc:NO cancellationSignal:nil];
        
        NSString *strUptoken = [AppUpToFile isNeedRequestToGetUptoken];
        NSString *strFileName = [AppUpToFile getFileName];
        if ([strUptoken length] > 0) {
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putPHAsset:asset key:strFileName token:strUptoken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                completionHandler(info, key, resp, index, asset);
                if (resp == nil) {
                    [AppUpToFile uploadQiNiuFailed:info key:key];
                    [AppUpToFile removeSG_UpToken];
                }
            } option:aQNUploadOption];
        } else {
            [AppUpToFile getUptoken:^(NSString *upToken) {
                QNUploadManager *upManager = [[QNUploadManager alloc] init];
                [upManager putPHAsset:asset key:strFileName token:upToken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                    completionHandler(info, key, resp, index, asset);
                    if (resp == nil) {
                        [AppUpToFile uploadQiNiuFailed:info key:key];
                        [AppUpToFile removeSG_UpToken];
                    }
                } option:aQNUploadOption];
            } doLaterFail:^{
                [AppUpToFile removeSG_UpToken];
                completionHandler([QNResponseInfo new], [NSString new], [NSDictionary new], index, asset);
            }];
        }
    }];
}

+ (void)upToPHAssetResource:(PHAssetResource *)assetResource index:(NSInteger)index resultHandler:(PHResultHandler)resultHandler completionHandler:(PHAssetResourceCompletionHandler)completionHandler {
    NSString *pathToWrite = [NSTemporaryDirectory() stringByAppendingString:assetResource.originalFilename];
    NSURL *localpath = [NSURL fileURLWithPath:pathToWrite];
    PHAssetResourceRequestOptions *options = [PHAssetResourceRequestOptions new];
    options.networkAccessAllowed = YES;
    [[PHAssetResourceManager defaultManager] writeDataForAssetResource:assetResource toFile:localpath options:options completionHandler:^(NSError *_Nullable error) {
        if (error) {
            completionHandler([QNResponseInfo new], [NSString new], [NSDictionary new], index, assetResource);
            return;
        }
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:localpath options:nil];
        NSNumber *fileSize = nil;
        [urlAsset.URL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        int64_t _fileSize = [fileSize unsignedLongLongValue];
        NSURL   *_assetURL = urlAsset.URL;
        UIImage *_result = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlAsset.URL]];
        NSDictionary *info = @{[NSNumber numberWithLongLong:_fileSize] : @"size", _assetURL : @"url"};
        
        resultHandler(_result, info);
        
        QNUploadOption *aQNUploadOption = [[QNUploadOption alloc] initWithMime:@"image/jpeg" progressHandler:nil params:nil checkCrc:NO cancellationSignal:nil];
        
        NSString *strUptoken = [AppUpToFile isNeedRequestToGetUptoken];
        NSString *strFileName = [AppUpToFile getFileName];
        if ([strUptoken length] > 0) {
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putPHAssetResource:assetResource key:strFileName token:strUptoken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                completionHandler(info, key, resp, index, assetResource);
                if (resp == nil) {
                    [AppUpToFile uploadQiNiuFailed:info key:key];
                    [AppUpToFile removeSG_UpToken];
                }
            } option:aQNUploadOption];
        } else {
            [AppUpToFile getUptoken:^(NSString *upToken) {
                QNUploadManager *upManager = [[QNUploadManager alloc] init];
                [upManager putPHAssetResource:assetResource key:strFileName token:upToken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                    completionHandler(info, key, resp, index, assetResource);
                    if (resp == nil) {
                        [AppUpToFile uploadQiNiuFailed:info key:key];
                        [AppUpToFile removeSG_UpToken];
                    }
                } option:aQNUploadOption];
            } doLaterFail:^{
                [AppUpToFile removeSG_UpToken];
                completionHandler([QNResponseInfo new], [NSString new], [NSDictionary new], index, assetResource);
            }];
        }
    }];
    
}

/** 图片的路径名 */
+ (NSString *)getFileName {
//    NSString *newUuidStr = [[[NSString generateUuidString] stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    NSString *newUuidStr = @"";
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    return [NSString stringWithFormat:@"i/%@/%@/%@/%@",@(components.year),@(components.month),@(components.day),newUuidStr];
}

/** 请求上传七牛Uptoken */
+ (NSString *)isNeedRequestToGetUptoken {
    NSString *strTime = [[NSUserDefaults standardUserDefaults] objectForKey:SG_QiniuUpTokenTime];
    if ([strTime length] > 0) {
        NSDate *dateNow = [NSDate date];
        NSDate *date    = [NSDate dateWithString:strTime format:@"YYYY-MM-dd HH:mm:ss"];
        
        if ([dateNow compare:date] == NSOrderedAscending) {
            NSString *strUpToken = [[NSUserDefaults standardUserDefaults] objectForKey:SG_QiniuUpToken];
            if ([strUpToken length] > 0) {
                return strUpToken;
            }
        }
    }
    return @"";
}

+ (void)removeSG_UpToken {
    NSUserDefaults *useDefault = [NSUserDefaults standardUserDefaults];
    [useDefault removeObjectForKey:SG_QiniuUpToken];
    [useDefault removeObjectForKey:SG_QiniuUpTokenTime];
    [useDefault synchronize];
}

+ (void)removeP_UpToken {
    NSUserDefaults *useDefault = [NSUserDefaults standardUserDefaults];
    [useDefault removeObjectForKey:P_QiniuUpToken];
    [useDefault removeObjectForKey:P_QiniuUpTokenTime];
    [useDefault synchronize];
}

+ (void)getUptoken:(void (^ __nonnull) (NSString *upToken))doLaterSuccess
       doLaterFail:(void (^ __nonnull) (void))doLaterFaill {
    
    /*
    [[HK_NetAPIClient sharedManager] POST:@"/1.0/system/upToken" params:@{} flag:YES  Success:^(id result) {
        if (![result[@"success"] boolValue]) {
            [HKTools showErrorHUDWithMsg:result[@"msg"]];
            return;
        }
        if ([result[@"success"] boolValue]) {
            if (result[@"data"]) {
                
                NSString *upToken = [NSString stringWithFormat:@"%@",result[@"data"]];
                NSDate   *date = [NSDate dateWithTimeIntervalSinceNow:24*60*60];
                NSString *strDate = [NSDate stringWithDate:date format:@"YYYY-MM-dd HH:mm:ss"];
                
                NSUserDefaults *useDefault = [NSUserDefaults standardUserDefaults];
                [useDefault setValue:upToken forKey:SG_QiniuUpToken];
                [useDefault setValue:strDate forKey:SG_QiniuUpTokenTime];
                [useDefault synchronize];
                
                doLaterSuccess(upToken);
            } else {
                doLaterFaill();
            }
        }
    } Failed:^(NSError *error) {
        doLaterFaill();
    }];
     */
}

+ (void)getPrivateUptoken:(void (^ __nonnull) (NSString *upToken))doLaterSuccess
              doLaterFail:(void (^ __nonnull) (void))doLaterFaill {
    /*
    NSString *str_url = @"https://finance-img.ultimavip.cn";
    
    [[HKNetworkManager sharedNetwork] POSTWithBaseURL:str_url urlString:@"/upload/uptoken" params:@{} Success:^(id result) {
        DebugLog(@"result:%@",result);
        if (![result[@"success"] boolValue]) {
            [HKTools showErrorHUDWithMsg:result[@"msg"]];
            return;
        }
        if ([result[@"success"] boolValue]) {
            if (result[@"data"]) {
                
                NSString *upToken = [NSString stringWithFormat:@"%@",result[@"data"]];
                NSDate   *date = [NSDate dateWithTimeIntervalSinceNow:24*60*60];
                NSString *strDate = [NSDate stringWithDate:date format:@"YYYY-MM-dd HH:mm:ss"];
                
                NSUserDefaults *useDefault = [NSUserDefaults standardUserDefaults];
                [useDefault setValue:upToken forKey:P_QiniuUpToken];
                [useDefault setValue:strDate forKey:P_QiniuUpTokenTime];
                [useDefault synchronize];
                
                doLaterSuccess(upToken);
            } else {
                doLaterFaill();
            }
        }
    } Failed:^(NSError *error) {
        DebugLog(@"error:%@",error);
        doLaterFaill();
    }];
     */
}

+ (void)uploadQiNiuFailed:(QNResponseInfo *)info key:(NSString *)key {
    
    //状态码，请求ID，
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[NSString stringWithFormat:@"状态码:%@",@(info.statusCode)] forKey:@"statusCode"];
    [param setObject:[NSString stringWithFormat:@"请求时间:%@",@(info.duration)] forKey:@"duration"];
    if ([info.reqId length] > 0) {
        [param setObject:[NSString stringWithFormat:@"请求ID:%@",info.reqId] forKey:@"reqId"];
    }
    if ([info.xlog length] > 0) {
        [param setObject:[NSString stringWithFormat:@"七牛记录:%@",info.xlog] forKey:@"xlog"];
    }
    if ([info.xvia length] > 0) {
        [param setObject:[NSString stringWithFormat:@"cdn记录:%@",info.xvia] forKey:@"xvia"];
    }
    if (info.error) {
        [param setObject:[NSString stringWithFormat:@"error:%@",info.error.description] forKey:@"error"];
    }
    if ([info.host length] > 0) {
        [param setObject:[NSString stringWithFormat:@"服务器域名:%@",info.host] forKey:@"host"];
    }
    if ([info.serverIp length] > 0) {
        [param setObject:[NSString stringWithFormat:@"服务器IP:%@",info.serverIp] forKey:@"serverIp"];
    }
    if ([info.id length] > 0) {
        [param setObject:[NSString stringWithFormat:@"客户端id:%@",info.id] forKey:@"id"];
    }
    if ([info.id length] > 0) {
        [param setObject:[NSString stringWithFormat:@"客户端id:%@",info.id] forKey:@"id"];
    }
    if ([key length] > 0) {
        [param setObject:[NSString stringWithFormat:@"文件名:%@",key] forKey:@"key"];
    }
    
    [param setObject:@(info.timeStamp) forKey:@"timeStamp"];
    [param setObject:@(info.canceled) forKey:@"canceled"];
    [param setObject:@(info.ok) forKey:@"ok"];
    [param setObject:@(info.broken) forKey:@"broken"];
    [param setObject:[NSString stringWithFormat:@"是否为七牛响应:%@",@(info.notQiniu)] forKey:@"notQiniu"];
    
    NSString *strContent = [param mj_JSONString];
    NSDictionary *params = @{@"content":strContent ?: @""};
    
    /*
    [[HKNetworkManager sharedNetwork] POSTWithBaseURL:kNetworkManager urlString:@"/log/qiniu/upload" params:params Success:^(id result) {
        DebugLog(@"result:%@",result);
        
    } Failed:^(NSError *error) {
        DebugLog(@"error:%@",error);
        
    }];
     */
}


@end
