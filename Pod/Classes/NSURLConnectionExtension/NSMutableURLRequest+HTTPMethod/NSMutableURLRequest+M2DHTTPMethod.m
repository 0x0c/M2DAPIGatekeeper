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
	NSMutableString *parameterString = [NSMutableString new];
	[params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if (parameterString.length > 0) {
			[parameterString appendString:@"&"];
		}
		else {
			if ([method isEqualToString:M2DHTTPMethodGET]) {
				[parameterString appendString:@"?"];
			}
		}
		NSString *escapedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
		NSString *value = [params[key] respondsToSelector:@selector(stringValue)] ? [params[key] stringValue] : params[key];
		NSString *escapedValue = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
		[parameterString appendString:[NSString stringWithFormat:@"%@=%@", escapedKey, escapedValue]];
	}];
	
	
	if ([method isEqualToString:M2DHTTPMethodGET]) {
		[self setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.URL.absoluteString, parameterString]]];
	}
	else {
		[self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[self setHTTPMethod:method];
		[self setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
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
