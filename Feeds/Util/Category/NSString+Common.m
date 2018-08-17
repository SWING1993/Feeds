//
//  NSString+Common.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "NSString+Common.h"
#import <CommonCrypto/CommonDigest.h>
#import "sys/utsname.h"

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

//数字和点
#define NUMANDD @".0123456789"

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation NSString (Common)

- (NSURL *)urlImageWithCodePathResize:(CGFloat)width crop:(BOOL)needCrop
{
    return nil;
}

+ (NSString *)userAgentStr
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], deviceString, [[UIDevice currentDevice] systemVersion], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0f)];
}

- (NSString *)URLEncoding
{
    NSString * result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault,
                                                                                              (CFStringRef)self,
                                                                                              NULL,
                                                                                              CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                              kCFStringEncodingUTF8 ));
    return result;
}
- (NSString *)URLDecoding
{
    NSMutableString * string = [NSMutableString stringWithString:self];
    [string replaceOccurrencesOfString:@"+"
                            withString:@" "
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, [string length])];
    return [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


- (NSString *)md5Str
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSString*) sha1Str
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (NSURL *)urlImageWithCodePathResize:(CGFloat)width{
    return [self urlImageWithCodePathResize:width crop:NO];
}
- (NSURL *)urlImageWithCodePathResizeToView:(UIView *)view{
    return [self urlImageWithCodePathResize:[[UIScreen mainScreen] scale]*CGRectGetWidth(view.frame)];
}

+ (NSString *)handelRef:(NSString *)ref path:(NSString *)path{
    if (ref.length <= 0 && path.length <= 0) {
        return nil;
    }
    
    NSMutableString *result = [NSMutableString new];
    if (ref.length > 0) {
        [result appendString:ref];
    }
    if (path.length > 0) {
        [result appendFormat:@"%@%@", ref.length > 0? @"/": @"", path];
    }
    return [result URLEncoding];
}
- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size{
    CGSize resultSize = CGSizeZero;
    if (self.length <= 0) {
        return resultSize;
    }
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        resultSize = [self boundingRectWithSize:size
                                        options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin)
                                     attributes:@{NSFontAttributeName: font}
                                        context:nil].size;
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        resultSize = [self sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
#endif
    }
    resultSize = CGSizeMake(MIN(size.width, ceilf(resultSize.width)), MIN(size.height, ceilf(resultSize.height)));
    return resultSize;
}

- (CGSize)getSizeWithFont:(UIFont *)font paragraphStyle:(NSMutableParagraphStyle *)paragraphStyle boundingRectWithSize:(CGSize)size{
    //获取内容高度
    CGSize contentSize = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle} context:nil].size;
    //如果只有一行文字则去掉行高(纯英文不处理)
    if (contentSize.height - font.lineHeight <= paragraphStyle.lineSpacing) {
        if ([self containsChinese]) {
            contentSize = CGSizeMake(contentSize.width, contentSize.height - paragraphStyle.lineSpacing);
        }
    }else{
        //这里需要加上行间距
        contentSize = CGSizeMake(contentSize.width, contentSize.height + paragraphStyle.lineSpacing);
    }
    return contentSize;
}

// 判断是否包含中文字符
- (BOOL)containsChinese{
    for (int i = 0; i < self.length; i++) {
        unichar c = [self characterAtIndex:i];
        if (c >0x4E00 && c <0x9FFF) {
            return YES;
        }
    }
    return NO;
}

- (CGFloat)getHeightWithFont:(UIFont *)font constrainedToSize:(CGSize)size{
    return [self getSizeWithFont:font constrainedToSize:size].height + 2.5;
}
- (CGFloat)getWidthWithFont:(UIFont *)font constrainedToSize:(CGSize)size{
    return [self getSizeWithFont:font constrainedToSize:size].width + 2.5;
}

+ (NSString *)sizeDisplayWithByte:(CGFloat)sizeOfByte{
    NSString *sizeDisplayStr;
    if (sizeOfByte < 1024) {
        sizeDisplayStr = [NSString stringWithFormat:@"%.2f bytes", sizeOfByte];
    }else{
        CGFloat sizeOfKB = sizeOfByte/1024;
        if (sizeOfKB < 1024) {
            sizeDisplayStr = [NSString stringWithFormat:@"%.2f KB", sizeOfKB];
        }else{
            CGFloat sizeOfM = sizeOfKB/1024;
            if (sizeOfM < 1024) {
                sizeDisplayStr = [NSString stringWithFormat:@"%.2f M", sizeOfM];
            }else{
                CGFloat sizeOfG = sizeOfKB/1024;
                sizeDisplayStr = [NSString stringWithFormat:@"%.2f G", sizeOfG];
            }
        }
    }
    return sizeDisplayStr;
}

- (NSString *)trimWhitespace
{
    NSMutableString *str = [self mutableCopy];
    CFStringTrimWhitespace((__bridge CFMutableStringRef)str);
    return str;
}

- (BOOL)isEmptyString
{
    if (self == NULL) {
        return YES;
    }
    
    if ([self isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    if (self == nil) {
        return YES;
    }
    if (self.length <= 0) {
        return YES;
    }
    return [[self trimWhitespace] isEqualToString:@""];
}

//判断是否为整形
- (BOOL)isPureInt{
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点形
- (BOOL)isPureFloat{
    NSScanner* scan = [NSScanner scannerWithString:self];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}

/** 判断是否包涵汉字 (true-包含， false-不包含)*/
- (BOOL)isChineseNo
{
    // 汉字字符集
    NSString *pattern  = @"[\u4e00-\u9fa5]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSInteger numMatch = [regex numberOfMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length)];
    
    return numMatch > 0 ? YES : NO;
}

/** 判断是否是手机号码或者邮箱 */
- (BOOL)isPhoneNo{
    NSString *phoneRegex = @"^1(3|4|5｜7|8)\\d{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:self];
}

- (BOOL)isEmail{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

/** 判断身份证号 18位 */
- (BOOL)isIDCard {
    NSString *emailRegex = @"^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([\\d|x|X]{1})$";
    NSPredicate *cardTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if (![cardTest evaluateWithObject:self]) {
        return NO;
    }
    if (self.length < 18) {
        return NO;
    }
    //6位，地区代码
    NSString *address = [self substringWithRange:NSMakeRange(0, 6)];
    NSArray *arrayProvince = @[@"11:北京",@"12:天津",@"13:河北",@"14:山西",@"15:内蒙古",@"21:辽宁",@"22:吉林",@"23:黑龙江",@"31:上海",@"32:江苏",@"33:浙江",@"34:安徽",@"35:福建",@"36:江西",@"37:山东",@"41:河南",@"42:湖北",@"43:湖南",@"44:广东",@"45:广西",@"46:海南",@"50:重庆",@"51:四川",@"52:贵州",@"53:云南",@"54:西藏",@"61:陕西",@"62:甘肃",@"63:青海",@"64:宁夏",@"65:新疆",@"71:台湾",@"81:香港",@"82:澳门",@"91:国外"];
    BOOL valideAddress = NO;
    NSString *address_has = [address substringWithRange:NSMakeRange(0, 2)];
    for (NSString *objStr in arrayProvince) {
        NSArray *keys = [objStr componentsSeparatedByString:@":"];
        if (keys.count > 0) {
            NSString *provinceKey = keys.firstObject;
            if ([provinceKey isEqualToString:address_has]) {
                valideAddress = YES;
                break;
            }
        }
    }
    if (!valideAddress) {
        return NO;
    }
    //加权因子
    NSArray *weightedFactors = @[ @7, @9, @10, @5, @8, @4, @2, @1, @6, @3, @7, @9, @10, @5, @8, @4, @2, @1];
    //身份证验证位值，其中10代表X
    NSArray *valideCode = @[ @1, @0, @10, @9, @8, @7, @6, @5, @4, @3, @2];
    int sum = 0;//声明加权求和变量
    NSMutableArray *arrayCertificate = [NSMutableArray array];
    for (int i=0; i<self.length; i++) {
        NSRange rangeStr = NSMakeRange(i, 1);
        if (self.length >= NSMaxRange(rangeStr)) {
            NSString *subStr = [self substringWithRange:rangeStr];
            [arrayCertificate addObject:subStr];
        }
    }
    //将最后位为x的验证码替换为10
    if ([[arrayCertificate[17] lowercaseString] isEqualToString:@"x"]) {
        [arrayCertificate replaceObjectAtIndex:17 withObject:@"10"];
    }
    
    for (int i = 0; i < 17; i++) {
        int factor = [weightedFactors[i] intValue];
        int certificate = [arrayCertificate[i] intValue];
        sum += factor * certificate;//加权求和
    }
    
    int valCodePosition = sum%11; //得到验证码所在位置
    int certificateLast = [arrayCertificate[17] intValue];
    if (certificateLast == [valideCode[valCodePosition] intValue]) {
        return YES;
    } else {
        return NO;
    }
}

// 是否包含中文
- (BOOL)isChinese {
    NSString *chineseRegex  = @"[\u4e00-\u9fa5]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:chineseRegex options:NSRegularExpressionCaseInsensitive error:nil];
    NSInteger numMatch = [regex numberOfMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length)];
    return numMatch>0?YES:NO;
}

- (NSRange)rangeByTrimmingLeftCharactersInSet:(NSCharacterSet *)characterSet{
    NSUInteger location = 0;
    NSUInteger length = [self length];
    unichar charBuffer[length];
    [self getCharacters:charBuffer];
    for (location = 0; location < length; location++) {
        if (![characterSet characterIsMember:charBuffer[location]]) {
            break;
        }
    }
    return NSMakeRange(location, length - location);
}
- (NSRange)rangeByTrimmingRightCharactersInSet:(NSCharacterSet *)characterSet{
    NSUInteger location = 0;
    NSUInteger length = [self length];
    unichar charBuffer[length];
    [self getCharacters:charBuffer];
    for (length = [self length]; length > 0; length--) {
        if (![characterSet characterIsMember:charBuffer[length - 1]]) {
            break;
        }
    }
    return NSMakeRange(location, length - location);
}

- (NSString *)stringByTrimmingLeftCharactersInSet:(NSCharacterSet *)characterSet {
    return [self substringWithRange:[self rangeByTrimmingLeftCharactersInSet:characterSet]];
}

- (NSString *)stringByTrimmingRightCharactersInSet:(NSCharacterSet *)characterSet {
    return [self substringWithRange:[self rangeByTrimmingRightCharactersInSet:characterSet]];
}

//转换拼音
- (NSString *)transformToPinyin {
    if (self.length <= 0) {
        return self;
    }
    NSString *tempString = [self mutableCopy];
    CFStringTransform((CFMutableStringRef)tempString, NULL, kCFStringTransformToLatin, false);
    tempString = (NSMutableString *)[tempString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    tempString = [tempString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [tempString uppercaseString];
}

+ (NSString *)generateUuidString
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    CFRelease(uuid);
    
    return uuidString;
}

-(BOOL)containsString:(NSString *)subString {
    return ([self rangeOfString:subString].location == NSNotFound) ? NO : YES;
}


- (NSString *)stringToTrimWhiteSpace {
    NSCharacterSet *whitespace = [NSCharacterSet  whitespaceAndNewlineCharacterSet];
    NSString *resultString = [self stringByTrimmingCharactersInSet:whitespace];
    if (resultString && resultString.length > 0) {
        return resultString;
    }
    
    return nil;
}

#pragma mark -是否只包含数字，小数点，负号
-(BOOL)isOnlyhasNumberAndpointWithString:(NSString *)string{
    
    NSCharacterSet *cs=[[NSCharacterSet characterSetWithCharactersInString:NUMANDD] invertedSet];
    
    NSString *filter=[[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filter];
}

//是否含有特殊字符
-(BOOL)isIncludeSpecialCharact {
    
    NSString *str =@"^[A-Za-z0-9\\u4e00-\u9fa5]+$";
    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    if (![emailTest evaluateWithObject:self]) {
        return YES;
    }
    //***需要过滤的特殊字符：~￥#&*<>《》()[]{}【】^@￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$_€。
    NSRange urgentRange = [self rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @"~￥#&*<>《》()[]{}【】^@￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$_€?？。."]];
    if (urgentRange.location == NSNotFound)
    {
        return NO;
    }
    return YES;
}

//是否含有表情
- (BOOL)stringContainsEmoji {
    __block BOOL returnValue = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              const unichar hs = [substring characterAtIndex:0];
                              if (0xd800 <= hs && hs <= 0xdbff) {
                                  if (substring.length > 1) {
                                      const unichar ls = [substring characterAtIndex:1];
                                      const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                      if (0x1d000 <= uc && uc <= 0x1f77f) {
                                          returnValue = YES;
                                      }
                                  }
                              } else if (substring.length > 1) {
                                  const unichar ls = [substring characterAtIndex:1];
                                  if (ls == 0x20e3) {
                                      returnValue = YES;
                                  }
                              } else {
                                  if (0x2100 <= hs && hs <= 0x27ff) {
                                      returnValue = YES;
                                  } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                      returnValue = YES;
                                  } else if (0x2934 <= hs && hs <= 0x2935) {
                                      returnValue = YES;
                                  } else if (0x3297 <= hs && hs <= 0x3299) {
                                      returnValue = YES;
                                  } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                      returnValue = YES;
                                  }
                              }
                          }];
    
    return returnValue;
}

- (NSString *)removeLinefeedandSpace {
    //去除掉首尾的空白字符和换行字符
    NSString *content = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    return content;
}
- (NSString *)removeRiskBlankAndLinefeed {
    //去除掉首尾的空白字符和换行字符
    NSString *content = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@" " withString:@""];
    return content;
}

+ (NSString *)stringMethodComma:(NSString *)string {
    NSString *sign = nil;
    if ([string hasPrefix:@"-"] || [string hasPrefix:@"+"]) {
        sign = [string substringToIndex:1];
        string = [string substringFromIndex:1];
    }
    
    NSString *pointLast = [string substringFromIndex:[string length]-3];
    NSString *pointFront = [string substringToIndex:[string length]-3];
    
    NSInteger commaNum = ([pointFront length]-1)/3;
    NSMutableArray *arr = [NSMutableArray array];
    for (NSInteger i=0; i<commaNum+1; i++) {
        NSInteger index = [pointFront length] - (i+1)*3;
        NSInteger leng = 3;
        if(index < 0) {
            leng = 3+index;
            index = 0;
        }
        NSRange range = {index,leng};
        NSString *stq = [pointFront substringWithRange:range];
        [arr addObject:stq];
    }
    
    NSMutableArray *arr2 = [NSMutableArray array];
    for (NSInteger i=[arr count]-1; i>=0; i--) {
        [arr2 addObject:arr[i]];
    }
    
    NSString *commaString = [[arr2 componentsJoinedByString:@","] stringByAppendingString:pointLast];
    if (sign) {
        commaString = [sign stringByAppendingString:commaString];
    }
    return commaString;
    
}

+ (NSString *)ret32bitString {
    char data[32];
    for (int x=0;x<32;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
}

+ (BOOL)isBlankString:(NSString *)string
{
    if (string == nil) {
        return YES;
    } else if (string == NULL) {
        return YES;
    } else if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    } else if (![string isKindOfClass:[NSString class]]) {
        return YES;
    } else if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    } else if ([string isEqualToString:@"(null)"]) {
        return YES;
    } else if ([string isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

+ (NSString *)stringByRMBFloat:(CGFloat)temp {
    NSString *str_float = [NSString stringWithFormat:@"%.2f",temp];
    NSRange range_float = [str_float rangeOfString:@"."];
    if (range_float.location != NSNotFound) {
        NSString *str_1 = [str_float substringFromIndex:range_float.location+range_float.length];
        if ([str_1 floatValue] == 0) {
            str_float = [str_float substringToIndex:range_float.location];
        }
    }
    return str_float;
}

+ (NSString *)getIPAddress {
    NSString *address = @"error";
    NSError *error;
    NSURL *ipURL = [NSURL URLWithString:@"http://ipof.in/txt"];
    NSString *ip = [NSString stringWithContentsOfURL:ipURL encoding:NSUTF8StringEncoding error:&error];
    if (error == nil && [self isBlankString:ip]==NO) {
        address = ip;
    }
    return address;
}

+(NSString*)phoneNumToAsterisk:(NSString*)phoneNum
{
    if (phoneNum.length > 11) {
        return [phoneNum stringByReplacingCharactersInRange:NSMakeRange(3,4)withString:@"****"];
    }
    return phoneNum;
}

/** 获取到所有子字符串的位置 */
+ (NSArray *)rangesOfString:(NSString *)searchString inString:(NSString *)str
{
    NSMutableArray *results = [NSMutableArray array];
    
    NSRange searchRange = NSMakeRange(0, [str length]);
    NSRange range;
    while ((range = [str rangeOfString:searchString options:0 range:searchRange]).location != NSNotFound) {
        [results addObject:[NSValue valueWithRange:range]];
        searchRange = NSMakeRange(NSMaxRange(range), [str length] - NSMaxRange(range));
    }
    return results;
}
+ (NSString *)firstCharactorWithString:(NSString *)string
{
    if (string.length){
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    NSMutableString *str = [NSMutableString stringWithString:string];
    CFStringTransform((CFMutableStringRef) str, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    NSString *pinYin = [str capitalizedString];
    return [pinYin substringToIndex:1];
}

- (NSMutableAttributedString *)numberWithString:(NSString *)str {
    NSMutableAttributedString *rightAttCard = [[NSMutableAttributedString alloc] init];
    for (int i=0; i<self.length; i++) {
        NSRange rangeStr = NSMakeRange(i, 1);
        if (self.length >= NSMaxRange(rangeStr)) {
            NSString *strItem = [self substringWithRange:rangeStr];
            NSString *img_name = str.length>0 ? [NSString stringWithFormat:@"%@%@",str,strItem] : strItem;
            UIImage *img = [UIImage imageNamed:img_name];
            if (img == nil) {
                continue;
            }
            NSTextAttachment *itemImage = [[NSTextAttachment alloc] init];
            [itemImage setImage:img];
            [itemImage setBounds:CGRectMake(0, 0, img.size.width, img.size.height)];
            NSAttributedString *itemASString = [NSAttributedString attributedStringWithAttachment:itemImage];
            [rightAttCard insertAttributedString:itemASString atIndex:i];
        }
    }
    return rightAttCard;
}

+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:s"];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]/ 1000.0];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

@end
