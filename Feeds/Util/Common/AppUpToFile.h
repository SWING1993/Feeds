//
//  AppUpToFile.h
//  Feeds
//
//  Created by 宋国华 on 2018/8/8.
//  Copyright © 2018年 swing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Qiniu/QiniuSDK.h>
#import <Photos/Photos.h>

typedef void (^PHAssetCompletionHandler)(QNResponseInfo *_Nonnull info, NSString *_Nonnull key, NSDictionary *_Nonnull resp, NSInteger index, PHAsset *_Nonnull asset);
typedef void (^PHAssetResourceCompletionHandler)(QNResponseInfo *_Nonnull info, NSString *_Nonnull key, NSDictionary *_Nonnull resp, NSInteger index, PHAssetResource *_Nonnull asset);
typedef void (^PHResultHandler)(UIImage *_Nonnull result, NSDictionary *_Nonnull info);

@interface AppUpToFile : NSObject

/**
 * 图片上传到七牛
 *  @param data     图片的data
 *  @param backInfo 上传完后的回调函数 info 上下文信息，包括状态码，错误值  key  上传时指定的key，原样返回 resp 上传成功会返回文件信息，失败为nil; 可以通过此值是否为nil 判断上传结果
 */
+ (void)upToData:(NSData *_Nonnull)data backInfo:(QNUpCompletionHandler _Nonnull)backInfo;

/** 上传私密照片 */
+ (void)privateUpToData:(NSData *_Nonnull)data backInfo:(QNUpCompletionHandler _Nonnull)backInfo;

/** 上传PHAsset文件(IOS8 andLater) */
+ (void)upToPHAsset:(PHAsset *_Nonnull)asset
              index:(NSInteger)index
      resultHandler:(PHResultHandler _Nonnull)resultHandler
  completionHandler:(PHAssetCompletionHandler _Nonnull)completionHandler;


/** 上传PHAssetResource文件(IOS9.1 andLater) */
+ (void)upToPHAssetResource:(PHAssetResource *_Nonnull)assetResource
                      index:(NSInteger)index
              resultHandler:(PHResultHandler _Nonnull)resultHandler
          completionHandler:(PHAssetResourceCompletionHandler _Nonnull)completionHandler;



+ (NSString *_Nonnull)getFileName;
+ (NSString *_Nonnull)isNeedRequestToGetUptoken;
+ (void)removeSG_UpToken;
+ (void)removeP_UpToken;
+ (void)getUptoken:(void (^ __nonnull) (NSString *__nonnull upToken))doLaterSuccess
       doLaterFail:(void (^ __nonnull) (void))doLaterFaill;

@end
