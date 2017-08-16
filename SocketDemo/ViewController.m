//
//  ViewController.m
//  SocketDemo
//
//  Created by Zhangxu on 2017/8/2.
//  Copyright © 2017年 Zhangxu. All rights reserved.
//

#import "ViewController.h"
#import "SocketManager.h"
#import "CocoaSocketManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@property (weak, nonatomic) IBOutlet UIButton *disConnectButton;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UITextField *contentField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.connectButton addTarget:self action:@selector(connectButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.disConnectButton addTarget:self action:@selector(disConnectButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
        
}


-(void)connectButtonClick{
    
    // 原生Sokcet连接
    // [[SocketManager shareInstance]connectSocket];
    // CocoaAsyncSocket 连接
    [[CocoaSocketManager shareInstance]connectSocket];
    
}



-(void)sendButtonClick{
    
    NSString * content =  self.contentField.text;
    // 原生Socket 发送消息
    // [[SocketManager shareInstance]sendMsg:content];
    // CocoaAsyncSocket 发送消息
    [[CocoaSocketManager shareInstance]sendMsg:content];

}


-(void)disConnectButtonClick{
    
    // 原生断开连接
    // [[SocketManager shareInstance]disConnectSocket];
    // CocoaAsyncSocket 断开连接
    [[CocoaSocketManager shareInstance]disConnect];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
   
    [self.contentField resignFirstResponder];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
