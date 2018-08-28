//
//  NSString+Common.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Common)
+ (NSString *)userAgentStr;

- (NSString *)URLEncoding;
- (NSString *)URLDecoding;
- (NSString *)md5Str;
- (NSString*)sha1Str;
- (NSURL *)urlImageWithCodePathResize:(CGFloat)width crop:(BOOL)needCrop;
- (NSURL *)urlImageWithCodePathResizeToView:(UIView *)view;
+ (NSString *)handelRef:(NSString *)ref path:(NSString *)path;
- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGSize)getSizeWithFont:(UIFont *)font paragraphStyle:(NSMutableParagraphStyle *)paragraphStyle boundingRectWithSize:(CGSize)size;
- (CGFloat)getHeightWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGFloat)getWidthWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
+ (NSString *)sizeDisplayWithByte:(CGFloat)sizeOfByte;
- (NSString *)trimWhitespace;
//判断是否为空字符串 包括纯空格
- (BOOL)isEmptyString;
//判断是否为整形
- (BOOL)isPureInt;
//判断是否为浮点形
- (BOOL)isPureFloat;
/** 判断是非包涵汉字 (true-包含， false-不包含)*/
- (BOOL)isChineseNo;
/** 判断是否是手机号码或者邮箱 */
- (BOOL)isPhoneNo;
- (BOOL)isEmail;
/** 判断身份证号 18位 */
- (BOOL)isIDCard;
// 是否包含中文
- (BOOL)isChinese;

- (NSRange)rangeByTrimmingLeftCharactersInSet:(NSCharacterSet *)characterSet;
- (NSRange)rangeByTrimmingRightCharactersInSet:(NSCharacterSet *)characterSet;

- (NSString *)stringByTrimmingLeftCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingRightCharactersInSet:(NSCharacterSet *)characterSet;

//转换拼音
- (NSString *)transformToPinyin;

/** 获取随机的UUID 字符串 */
+ (NSString *)generateUuidString;

// 是否包含字符串
-(BOOL)containsString:(NSString *)subString;


- (NSString *)stringToTrimWhiteSpace ;

// 是否包含特殊字符
- (BOOL)isIncludeSpecialCharact;

// 是否包含emoji表情
- (BOOL)stringContainsEmoji;

// 去除首尾空格和换行
- (NSString *)removeLinefeedandSpace;

//去除风控换行 全部空格
- (NSString *)removeRiskBlankAndLinefeed;

//是否只包含数字，小数点
- (BOOL)isOnlyhasNumberAndpointWithString:(NSString *)string;

/** 格式化金额，金额三位一个逗号 */
+ (NSString *)stringMethodComma:(NSString *)string;

+ (NSString *)ret32bitString;

/**  判断string是否为空 */
+ (BOOL)isBlankString:(NSString *)string;

/** 去掉浮点型小数点，取绝对值 */
+ (NSString *)stringByRMBFloat:(CGFloat)temp;

/** 获取IP地址 */
+ (NSString *)getIPAddress;
/*手机号码4-7位隐藏为星*/
+ (NSString*)phoneNumToAsterisk:(NSString*)phoneNum;

/** 获取到所有子字符串的位置 */
+ (NSArray *)rangesOfString:(NSString *)searchString inString:(NSString *)str;
/**
 将汉字转成拼音
 */
+ (NSString *)firstCharactorWithString:(NSString *)string;

- (NSMutableAttributedString *)numberWithString:(NSString *)str;
/** 时间戳转化时间 */
+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString;

-(NSString *)formatOssStringWithOriginal;

- (NSString *)formatOssStringWithResizeWidth:(CGFloat)width;

- (NSURL *)formatOssUrlWithResizeWidth:(CGFloat)width;
@end
