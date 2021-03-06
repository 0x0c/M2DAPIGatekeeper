//
//  NSMutableURLRequest+HTTPMethod.h
//
//  Created by 暁 松田 on 12/06/01.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (M2DHTTPMethod)

- (void)m2d_setParameter:(NSDictionary * _Nonnull)params method:(NSString * _Nonnull)method;

@end

@interface NSMutableData (M2DHTTPMethod)

- (void)m2d_setParameterWithKey:(NSString * _Nonnull)key value:(NSString * _Nonnull)value;

@end
