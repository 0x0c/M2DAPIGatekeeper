//
//  NSMutableURLRequest+FileUpload.m
//
//  Created by 暁 松田 on 12/05/01.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSMutableURLRequest+M2DFileUpload.h"
#import "M2DNSURLConnectionExtensionConstant.h"

@implementation NSMutableURLRequest (M2DFileUpload)

- (void)m2d_setData:(NSData *)data
{
	[self setHTTPShouldUsePipelining:YES];
	[self setHTTPMethod:M2DHTTPMethodPOST];
	[self addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
	[self addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", M2D_BOUNDARY] forHTTPHeaderField:@"Content-Type"];
	[self setHTTPBody:data];
}

@end

@implementation NSMutableData (M2DFileUpload)

- (void)m2d_setData:(NSData *)data key:(NSString *)key
{
	NSString *boundary = M2D_BOUNDARY;
	[self appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
    [self appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[self appendData:data];
    [self appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[self appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)m2d_setContent:(NSData *)data filename:(NSString *)filename contentType:(NSString *)contentType
{
	NSString *boundary = M2D_BOUNDARY;
	[self appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[self appendData:[[NSString stringWithFormat:@"Content-Disposition: attachment; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
	[self appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
	[self appendData:[[NSString stringWithFormat:@"Content-Transfer-Encoding: binary\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[self appendData:data];
	[self appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[self appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)m2d_setJpegImage:(UIImage *)image filename:(NSString *)filename
{
	NSString *contentType = @"image/jpeg";
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    [self m2d_setContent:imageData filename:filename contentType:contentType];
}

@end