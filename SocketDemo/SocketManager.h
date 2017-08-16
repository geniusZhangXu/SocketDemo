//
//  SocketManager.h
//  SocketDemo
//
//  Created by Zhangxu on 2017/8/2.
//  Copyright © 2017年 Zhangxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketManager : NSObject


+(instancetype)shareInstance;


-(void)connectSocket;


-(void)disConnectSocket;

- (void)sendMsg:(NSString *)msg;


@end
