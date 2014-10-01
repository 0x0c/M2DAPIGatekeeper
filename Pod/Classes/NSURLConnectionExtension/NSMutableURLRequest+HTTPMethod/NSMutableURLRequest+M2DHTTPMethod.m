//
//  NSMutableURLRequest+HTTPMethod.m
//
//  Created by 暁 松田 on 12/06/01.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSMutableURLRequest+M2DHTTPMethod.h"
#import "M2DNSURLConnectionExtensionConstant.h"

@implementation NSMutableURLRequest (M2DHTTPMethod)

- (void)m2d_setParameter:(NSDictionary *)params method:(NSString *)method
{
	[self setHTTPShouldUsePipelining:YES];
	if ([method isEqualToString:M2DHTTPMethodPOST]) {
		NSMutableData *data = [NSMutableData data];
		NSInteger cnt = [params count];
		NSInteger i = 0;
		for (NSString *key in params) {
			NSString *appendString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)key, NULL, CFSTR (";,/?:@&=+$#"), kCFStringEncodingUTF8));
			NSString *p1 = [NSString stringWithFormat:@"%@=",appendString];
			appendString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)([params[key] respondsToSelector:@selector(stringValue)] ? [params[key] stringValue] : params[key]), NULL, CFSTR (";,/?:@&=+$#"), kCFStringEncodingUTF8));
			NSString *p2 = [NSString stringWithString:appendString];
			[data appendData:[p1 dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:[p2 dataUsingEncoding:NSUTF8StringEncoding]];
			if (i < cnt - 1) {
				[data appendData:[@"&" dataUsingEncoding:NSUTF8StringEncoding]];
				i++;
			}
		}
		
		[self setHTTPMethod:method];
		[self setHTTPBody:data];
	}
	else if ([method isEqualToString:M2DHTTPMethodGET]) {
		NSMutableString *url = [NSMutableString stringWithString:self.URL.absoluteString];
		[url appendString:@"?"];
		NSInteger cnt = [params count];
		NSInteger i = 0;
		for (NSString *key in params) {
			[url appendFormat:@"%@=%@",key,params[key]];
			if (i < cnt - 1) {
				[url appendString:@"&"];
				i++;
			}
		}
		
		[self setURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	}
}

@end

@implementation NSMutableData (M2DHTTPMethod)

- (void)m2d_setParameterWithKey:(NSString *)key value:(NSString *)value
{
	NSString *boundary = M2D_BOUNDARY;
	[self appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
    [self appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [self appendData:[[NSString stringWithFormat:@"%@\r\n", value] dataUsingEncoding:NSUTF8StringEncoding]];
	[self appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
}

@end