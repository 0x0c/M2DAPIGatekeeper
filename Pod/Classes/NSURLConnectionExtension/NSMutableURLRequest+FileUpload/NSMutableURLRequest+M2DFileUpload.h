//
//  NSMutableURLRequest+FileUpload.h
//
//  Created by 暁 松田 on 12/05/01.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMutableURLRequest (M2DFileUpload)

- (void)m2d_setData:(NSData * _Nonnull)data;

@end

@interface NSMutableData (M2DFileUpload)

- (void)m2d_setData:(NSData * _Nonnull)data key:(NSString * _Nonnull)key;
- (void)m2d_setContent:(NSData * _Nonnull)data filename:(NSString * _Nonnull)filename contentType:(NSString * _Nonnull)contentType;
- (void)m2d_setJpegImage:(UIImage * _Nonnull)image filename:(NSString * _Nonnull)filename;

@end
