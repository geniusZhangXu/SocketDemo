//
//  CocoaSocketManager.h
//  SocketDemo
//
//  Created by Zhangxu on 2017/8/16.
//  Copyright © 2017年 Zhangxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"


static  NSString * host = @"127.0.0.1";
static  const uint16_t port = 6969;


@interface CocoaSocketManager : NSObject<GCDAsyncSocketDelegate>

@property(nonatomic,strong) GCDAsyncSocket * gcdSocket;


+(instancetype) shareInstance;

-(BOOL)connectSocket;

- (void)disConnect;

-(void)sendMsg:(NSString *)msg;

@end
