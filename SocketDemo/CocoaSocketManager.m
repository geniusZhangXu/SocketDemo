//
//  CocoaSocketManager.m
//  SocketDemo
//
//  Created by Zhangxu on 2017/8/16.
//  Copyright © 2017年 Zhangxu. All rights reserved.
//

#import "CocoaSocketManager.h"



@implementation CocoaSocketManager

+(instancetype) shareInstance{
  
    static CocoaSocketManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[ CocoaSocketManager alloc]init];
        [manager  initSocket];
        
    });

    return manager;
}


-(void)initSocket{

    // 初始化Socket
    _gcdSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}


// 连接Socket
-(BOOL)connectSocket{
   
    return [_gcdSocket connectToHost:host onPort:port error:nil];

}


//断开连接
- (void)disConnect
{
    [_gcdSocket disconnect];
}

//发送消息，构造一条假消息
-(void)sendMsg:(NSString *)msg
{
    
    NSData *data  = [msg dataUsingEncoding:NSUTF8StringEncoding];
    //第二个参数，请求超时时间
    [_gcdSocket writeData:data withTimeout:-1 tag:110];
    
}



//监听最新的消息
- (void)pullTheMsg{
    
    
    //貌似是分段读数据的方法
    //[gcdSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:10 maxLength:50000 tag:110];
    //监听读数据的代理，只能监听10秒，10秒过后调用代理方法  -1永远监听，不超时，但是只收一次消息
    //所以每次接受到消息还得调用一次
    [_gcdSocket readDataWithTimeout:-1 tag:110];
}


#pragma mark - GCDAsyncSocketDelegate
//连接成功调用
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"Socket连接成功,host:%@,port:%d",host,port);
    //
    [self pullTheMsg];
    // 不开启TLS
    [sock startTLS:nil];
}

//断开连接的时候调用
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    
    NSLog(@"连接已经断开,host:%@,port:%d",sock.localHost,sock.localPort);
    
}

//发送回调
- (void)socket:(GCDAsyncSocket*)sock didWriteDataWithTag:(long)tag{
    
    NSLog(@"发送消息回调信息,tag:%ld",tag);
    //判断是否成功发送，如果没收到响应，则说明连接断了，则想办法重连
    [self pullTheMsg];
}

// 接收
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    NSString *msg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到消息：%@",msg);
    [self pullTheMsg];
}


-(void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    
    NSLog(@"收到消息的回调,length:%ld,tag:%ld",partialLength,tag);
    
}

@end
