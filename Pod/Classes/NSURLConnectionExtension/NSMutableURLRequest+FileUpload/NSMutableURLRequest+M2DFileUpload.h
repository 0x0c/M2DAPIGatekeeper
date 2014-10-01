//
//  NSMutableURLRequest+FileUpload.h
//
//  Created by 暁 松田 on 12/05/01.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (M2DFileUpload)

- (void)m2d_setData:(NSData *)data;

@end

@interface NSMutableData (M2DFileUpload)

- (void)m2d_setData:(NSData *)data key:(NSString *)key;
- (void)m2d_setContent:(NSData *)data filename:(NSString *)filename contentType:(NSString *)contentType;
- (void)m2d_setJpegImage:(UIImage *)image filename:(NSString *)filename;

@end
