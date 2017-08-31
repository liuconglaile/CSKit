//
//  NSObject+Socket.m
//  CSCategory
//
//  Created by mac on 2017/5/27.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSObject+Socket.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#if __has_include(<CSkit/CSkit.h>)
#import <CSkit/CSMacrosHeader.h>

#else
#import "CSMacrosHeader.h"

#endif

@implementation NSObject (Socket)

# pragma mark - 网络请求

+ (BOOL)sendSocketMsg:(NSString *)msg withIP:(NSString *)ip andPort:(NSInteger)port{
    
    // 1. 创建代理
    // 参数一: 协议簇 默认为IPv4
    // 参数二: socket类型 默认为socket流
    // 参数三: 协议 默认为TCP
    // 返回: socket的标识
    int clientSocket = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
    
    // 2. 连接服务器
    struct sockaddr_in addr; // 地址信息
    addr.sin_family = AF_INET; // 指定协议
    addr.sin_addr.s_addr = inet_addr(ip.UTF8String); // 指定IP
    addr.sin_port = htons(port); // 指定端口
    
    int rs = connect(clientSocket, (const struct sockaddr *)&addr, sizeof(addr)); // 连接结果
    if(rs != 0){ // 成功为0,不为0返回失败
        close(clientSocket);
        return NO;
    }
    
    // 3. 发送消息
    const char * msgStr = msg.UTF8String;
    // 参数一: socket标识
    // 参数二: 字符数组
    // 参数三: 字符数组个数
    // 参数四: 是否阻塞
    // 返回: 发送的字符数
    ssize_t sendCount = send(clientSocket, msgStr, strlen(msgStr), 0);
    
    close(clientSocket);
    
    // 判断发送的消息是否完整
    if(sendCount == strlen(msgStr)){
        return YES;
    }
    else{
        return NO;
    }
    
}

// 获取socket信息
+ (NSString *)getSocketMsgFromIP:(NSString *)ip andPort:(NSInteger)port{
    // 1. 创建代理
    // 参数一: 协议簇 默认为IPv4
    // 参数二: socket类型 默认为socket流
    // 参数三: 协议 默认为TCP
    // 返回: socket的标识
    int clientSocket = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
    
    // 2. 连接服务器
    struct sockaddr_in addr; // 地址信息
    addr.sin_family = AF_INET; // 指定协议
    addr.sin_addr.s_addr = inet_addr(ip.UTF8String); // 指定IP
    addr.sin_port = htons(port); // 指定端口
    
    int rs = connect(clientSocket, (const struct sockaddr *)&addr, sizeof(addr)); // 连接结果
    if(rs != 0){ // 连接成功为0,不为0返回失败
        close(clientSocket);
        return nil;
    }
    
    // 3. 接收数据
    uint8_t buffer[1024];
    ssize_t recvCount = recv(clientSocket, buffer, sizeof(buffer), 0); // 接收数据数
    if(recvCount){
        // 把接收的二进制数据转化成字符串
        NSData * data = [NSData dataWithBytes:buffer length:recvCount];
        NSString * recvMsg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        close(clientSocket);
        CSNSLog(@"%@",recvMsg);
        return recvMsg;
    }
    
    close(clientSocket);
    return nil;
    
}


@end
