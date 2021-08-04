//
//  HMACAuthentication.m
//  FilGoalIOS
//
//  Created by Nada Gamal on 8/21/17.
//  Copyright © 2017 Sarmady. All rights reserved.
//

#import "HMACAuthentication.h"
#import "NSData+Base64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (NSString_Extended)

- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end

@implementation HMACAuthentication
static NSString * appIdStr;
static NSString * apiKeyStr;

- (id)initWithAppId:(NSString*) appId andApiSecret:(NSString*) apiKey
{
    self = [super init];
    if (self) {
        appIdStr = appId;
        apiKeyStr = apiKey;
    }
    return self;
}

-(NSString*)getHeaderStringUsingUrlString:(NSString*)urlString parameters:(NSDictionary*)parameters requestType:(NSString*)requestType andTimeStamp:(NSString*)timestamp {
    if (parameters != nil) {
        urlString = [self addQueryStringToUrlString:urlString withDictionary:parameters];
    }
    NSString * encodedUrl = [[urlString urlencode]lowercaseString];
    NSString *nowTimestamp = [NSString stringWithFormat:@"%.f", [[NSDate date]timeIntervalSince1970]];
    if (![timestamp isEqualToString: @""]) {
        nowTimestamp = timestamp;
    }
    NSString * nonce = [NSString stringWithFormat:@"%@",[[[[NSUUID UUID] UUIDString]stringByReplacingOccurrencesOfString:@"-" withString:@""]lowercaseString]];
    NSString * requestHttpMethod = requestType;
    NSString * signatureRawData = [NSString stringWithFormat:@"%@%@%@%@%@",appIdStr,requestHttpMethod,encodedUrl,nowTimestamp, nonce];
    NSData *decodedString = [NSData dataFromBase64String:apiKeyStr];
    NSString * requestSignatureBase64String =  [self hmacSha256:[signatureRawData dataUsingEncoding:NSUTF8StringEncoding] key:decodedString];
    NSString * header = [NSString stringWithFormat:@"amx %@:%@:%@:%@",appIdStr, requestSignatureBase64String,nonce,nowTimestamp];
    [header stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [header stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSLog(@"Header is %@ ",header);
    return header;
    
}
- (NSString *)hmacSha256:(NSData *)dataIn
                     key:(NSData *)key
{
    NSMutableData *macOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CCHmac( kCCHmacAlgSHA256,
           key.bytes,
           key.length,
           dataIn.bytes,
           dataIn.length,
           macOut.mutableBytes);
    return [self base64forData:macOut];
}


- (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {  value |= (0xFF & input[j]);  }  }  NSInteger theIndex = (i / 3) * 4;  output[theIndex + 0] = table[(value >> 18) & 0x3F];
        output[theIndex + 1] = table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6) & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0) & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

-(NSString*)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary
{
    NSMutableString *urlWithQuerystring = [[NSMutableString alloc] initWithString:urlString];
    
    for (id key in dictionary) {
        NSString *keyString = [key description];
        NSString *valueString = [[dictionary objectForKey:key] description];
        
        if ([urlWithQuerystring rangeOfString:@"?"].location == NSNotFound) {
            [urlWithQuerystring appendFormat:@"?%@=%@", keyString, valueString];
        } else {
            [urlWithQuerystring appendFormat:@"&%@=%@", keyString, valueString];
        }
    }
    return urlWithQuerystring;
}

@end
