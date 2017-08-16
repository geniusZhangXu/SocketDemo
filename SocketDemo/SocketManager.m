//
//  SocketManager.m
//  SocketDemo
//
//  Created by Zhangxu on 2017/8/2.
//  Copyright © 2017年 Zhangxu. All rights reserved.
//

#import "SocketManager.h"
#import <sys/socket.h>
#import <sys/types.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface SocketManager()

@property (nonatomic,assign)int clientScoket;      // Socket
@property (nonatomic,assign)int connetSocketResult;// Socket连接结果

@end

@implementation SocketManager

/**
      NOTE： 里面涉及到一些Socket的创建的具体的方法你要是不理解可以暂时放下
             等读完CocoaAsyncSocket的源码的具体注释就可以理解
 
 */

+(instancetype)shareInstance{
   
    static SocketManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[SocketManager alloc]init];
        manager.connetSocketResult = -1; // 初始化连接状态是断开状态
        // 在创建单例的时候就去初始化Socket和开辟一条新的线程去接收消息
        [manager initSocket];
        [manager ReceiveMessageThread];
        
    });
    
    return manager;
}


-(void)initSocket{

    //每次连接前，先判断是否在连接状态  0 在连接状态，直接Return
    if (_connetSocketResult == 0) {
        
        return;
    }
    
    _clientScoket = creatSocket();       //创建客户端socket
    
    const char * server_ip="127.0.0.1";  //服务器Ip
    short server_port = 6969;            //服务器端口
    
    //等于0说明连接成功，-1则连接失败
    if (connectionToServer(_clientScoket,server_ip, server_port) == 0) {
        
        _connetSocketResult = 0;
        printf("Connect to server Success\n");
        return ;
        
    }else{
        
        _connetSocketResult = -1;
        printf("Connect to server error\n");
    }
}

/**
 创建Socket

 @return 返回Socket
 */
static int  creatSocket(){
    
    int ClinetSocket = 0;
    // NOTE: Socket本质上就是int类型
    ClinetSocket = socket(AF_INET, SOCK_STREAM, 0);
    // 返回创建的Socket
    return ClinetSocket;
}

/**
 连接 Socket

 @param client_socket Socket
 @param server_ip     服务器IP
 @param port          端口
 
 @return 返回时候连接成功，返回0则连接成功，-1连接失败
 */
static int connectionToServer(int client_socket,const char * server_ip,unsigned short port){

    //生成一个sockaddr_in类型结构体
    struct sockaddr_in sAddr={0};
    sAddr.sin_len=sizeof(sAddr);
    
    //设置IPv4, 这个区分可以看前面在解释Socket方法的时候写的注释
    sAddr.sin_family=AF_INET;
    
    //inet_aton是一个改进的方法来将一个字符串IP地址转换为一个32位的网络序列IP地址
    //如果这个函数成功，函数的返回值非零，如果输入地址不正确则会返回零。
    inet_aton(server_ip, &sAddr.sin_addr);
    
    //htons是将整型变量从主机字节顺序转变成网络字节顺序，赋值端口号
    sAddr.sin_port=htons(port);
    
    // 防止发送SO_NOSIGPIPE信号导致崩溃
    int nosigpipe = 1;
    setsockopt(client_socket, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe, sizeof(nosigpipe));
    
    //用scoket和服务端地址，发起连接。
    //客户端向特定网络地址的服务器发送连接请求，连接成功返回0，失败返回 -1。
    //注意：该接口调用会阻塞当前线程，直到服务器返回。
    
    int connectResult = connect(client_socket, (struct sockaddr *)&sAddr, sizeof(sAddr));
    return connectResult;
}

// 开辟一条线程接收消息
-(void)ReceiveMessageThread{
    
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(recieveAction) object:nil];
    [thread start];
}

/**
   连接Socket
 */
-(void)connectSocket{
    
    [self initSocket];
}


/**
  断开Socket连接
 */
-(void)disConnectSocket
{
    close(self.clientScoket);
}


/**
 
 发送消息
 @param msg 消息内容
 */
- (void)sendMsg:(NSString *)msg
{
    const char * send_Message = [msg UTF8String];
    send(self.clientScoket,send_Message,strlen(send_Message)+1,0);
}


/**
   死循环，看是否有消息发送过来
 */
- (void)recieveAction{
    
    while (1) {
        
        char recv_Message[1024] = {0};
        recv(self.clientScoket, recv_Message, sizeof(recv_Message), 0);
        printf("%s\n",recv_Message);
    }
}
@end






/*为了保证阅读的顺序和源码的顺序对应，方便大家查看，就不调整方法顺序，比如初始化的方法位置没有调整。解释的也是主要的，没有全部都解释
 __BEGIN_DECLS
 
 这个方法是在服务端用到，表示接受客户端请求，并讲客户端的网络地址保存在sockaddr类型指针__restrict，后面的__restrict是地址的长度
 int	accept(int, struct sockaddr * __restrict, socklen_t * __restrict)
 __DARWIN_ALIAS_C(accept);
 
 
 将Socket与指定的主机地址与端口号绑定，绑定成功返回0.失败返回-1，这个方法你可以在CocoaAsyncSocket源码中看到
 int	bind(int, const struct sockaddr *, socklen_t)    __DARWIN_ALIAS(bind);
 
 
 客户端Socket的连接方法，成功返回0，失败返回-1，第一个参数是你初始化一个Socket获取到的文件描述符，初始化Socket返回的文件描述符是int类型，这个你在下面可以看到。 第二个参数是一个指向要连接Socket的sockaddr结构体的指针, 第三个参数代表sockaddr结构体的字节长度
 参考：https://baike.baidu.com/item/connect%28%29/10081861?fr=aladdin
 int	connect(int, const struct sockaddr *, socklen_t) __DARWIN_ALIAS_C(connect);
 
 获取Socket的地址   参考：https://baike.baidu.com/item/getpeername%28%29
 int	getpeername(int, struct sockaddr * __restrict, socklen_t * __restrict)
 __DARWIN_ALIAS(getpeername);
 
 获取Socket的名称   参考：https://baike.baidu.com/item/getsockname%28%29
 int	getsockname(int, struct sockaddr * __restrict, socklen_t * __restrict)
 __DARWIN_ALIAS(getsockname);
 
 
 https://baike.baidu.com/item/getsockopt%28%29
 int	getsockopt(int, int, int, void * __restrict, socklen_t * __restrict);
 
 用于服务端监听客户端，传的两个参数一个是初始化Socket获取到的文件描述符， 第二个是等待连接队列的最大长度
 如无错误发生，listen()返回0。否则的话，返回-1
 方法带参数这样 int listen( int sockfd, int backlog)  ，这个方法在CocoaAsyncSocket源码中也用做判断
 参考：https://baike.baidu.com/item/listen%28%29
 int	listen(int, int) __DARWIN_ALIAS(listen);
 
 接收消息方法，详细https://baike.baidu.com/item/recv%28%29
 ssize_t	recv(int, void *, size_t, int) __DARWIN_ALIAS_C(recv);
 
 从UDP Socket中读取数据
 ssize_t	recvfrom(int, void *, size_t, int, struct sockaddr * __restrict,socklen_t * __restrict) __DARWIN_ALIAS_C(recvfrom);
 
 
 ssize_t	recvmsg(int, struct msghdr *, int) __DARWIN_ALIAS_C(recvmsg);
 
 
 发送消息方法  参考： https://baike.baidu.com/item/send%28%29#3
 ssize_t	send(int, const void *, size_t, int) __DARWIN_ALIAS_C(send);
 
 send，sendto以及sendmsg系统调用用于发送消息到另一个套接字。send函数在套接字处于连接状态时方可使用。
 而sendto和sendmsg在任何时候都可使用
 ssize_t	sendmsg(int, const struct msghdr *, int) __DARWIN_ALIAS_C(sendmsg);
 
 sendto()适用于发送未建立连接的UDP数据包
 ssize_t	sendto(int, const void *, size_t,int, const struct sockaddr *, socklen_t) __DARWIN_ALIAS_C(sendto);
 
 int	setsockopt(int, int, int, const void *, socklen_t);
 
 shutdown()是指禁止在一个Socket上进行数据的接收与发送。
 int	shutdown(int, int);
 
 int	sockatmark(int) __OSX_AVAILABLE_STARTING(__MAC_10_5, __IPHONE_2_0);
 
 
 重点理解一下Socket的初始化，完整的参数方法是这样： int socket(int domain, int type, int protocol)
 domain 参数表示制定使用何种的地址类型  比如：
 PF_INET,  AF_INET：  Ipv4网络协议
 PF_INET6, AF_INET6： Ipv6网络协议
 
 
 type 参数的作用是设置通信的协议类型
 SOCK_STREAM：    提供面向连接的稳定数据传输，即TCP协议。
 OOB：            在所有数据传送前必须使用connect()来建立连接状态。
 SOCK_DGRAM：     使用不连续不可靠的数据包连接。
 SOCK_SEQPACKET： 提供连续可靠的数据包连接。
 SOCK_RAW：       提供原始网络协议存取。
 SOCK_RDM：       提供可靠的数据包连接。
 SOCK_PACKET：    与网络驱动程序直接通信。
 参数protocol用来指定socket所使用的传输协议编号。这一参数通常不具体设置，一般设置为0即可。
 参考：https://baike.baidu.com/item/socket%28%29
 上面的解释要是结合CocoaAsyncSocket的源码再去理解，会理解的更透彻
 int	socket(int, int, int);
 
 
 int	socketpair(int, int, int, int *) __DARWIN_ALIAS(socketpair);
 
 #if !defined(_POSIX_C_SOURCE)
 
 int	sendfile(int, int, off_t, off_t *, struct sf_hdtr *, int);
 
 #endif	 !_POSIX_C_SOURCE
 
 
 #if !defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE)
 
 void	pfctlinput(int, struct sockaddr *);
 int     connectx(int, const sa_endpoints_t *, sae_associd_t, unsigned int,
 const struct iovec *, unsigned int, size_t *, sae_connid_t *);
 int     disconnectx(int, sae_associd_t, sae_connid_t);
 
 #endif	(!_POSIX_C_SOURCE || _DARWIN_C_SOURCE)
 __END_DECLS
 */


