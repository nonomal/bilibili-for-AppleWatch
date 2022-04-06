//
//  ContentView.swift
//  bilibili WatchKit Extension
//
//  Created by mac on 2022/3/26.
//

import SwiftUI



struct Main: View {
    
    @StateObject var 控制器 = 网络控制器()
    var body: some View {
        VStack {
            视频列表(控制器: 控制器)
            HStack {
                Button(action: {
                    触感引擎.中等触感()
                    Task {
                        await 刷新()
                    }
                }) {
                    Text("刷新")
                }
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationTitle("⚡️")
    }
    func 刷新() async {
        
        let 视频s = await 控制器.获取所有榜单()
//        print(视频s)
        控制器.视频列表.removeAll()
        控制器.视频列表 = 视频s
        if 视频s.isEmpty {
            触感引擎.失败触感()
        } else {
            触感引擎.成功触感()
        }
    }
}



struct 视频列表: View {
    @ObservedObject var 控制器 : 网络控制器
    var body: some View {
        
            List {
            ForEach(控制器.视频列表) { item in
                列表Row(item: item)
            }
        }
    }
}

struct 列表Row: View {
    var item : 网络控制器.视频

    @State var 播放 = false
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: item.封面URL ?? "")) { image in
                image
                    .格式化图片(方式: .fit)
            } placeholder: {
                ProgressView()
                    .frame(width: 174, height: 108)
            }
            Button(item.标题 ?? "无标题", action: {
                触感引擎.轻触()
                播放.toggle()
            })
        }
        .sheet(isPresented: $播放, onDismiss: nil, content: {详情(item: item)})
        .transition(.opacity.animation(.easeInOut))
        
    }
}


struct 列表项目: View {
    var item : 网络控制器.视频

    @State var 播放 = false
    @State var 内容 = {
        VedioView(url: URL(string: "https://cn-zjjh4-dx-v-14.bilivideo.com/upgcxcode/31/24/555162431/555162431-1-208.mp4?e=ig8euxZM2rNcNbhVhbdVhwdlhzdghwdVhoNvNC8BqJIzNbfq9rVEuxTEnE8L5F6VnEsSTx0vkX8fqJeYTj_lta53NCM=&uipk=5&nbs=1&deadline=1648300701&gen=playurlv2&os=bcache&oi=2030413803&trid=000089f8e57cc0104a4ab3a40724db5cdd03T&platform=html5&upsig=336c96cdccb589b7597e10f0be3aca9f&uparams=e,uipk,nbs,deadline,gen,os,oi,trid,platform&cdnid=22221&mid=35056091&bvc=vod&nettype=0&bw=302911&orderid=0,1&logo=80000000")!)
}
    @AppStorage("播放视频次数") var 播放视频次数 = 0
    @State var 弹出提示 = false
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: item.封面URL ?? "")) { image in
                image
                    .格式化图片(方式: .fit)
            } placeholder: {
                ProgressView()
                    .frame(width: 174, height: 108)
            }
            Button(item.标题 ?? "无标题", action: {
                触感引擎.轻触()
                Task {
                    let url = item.bid
                    let URL = await 网络控制器.视频解析(bid: url)
                    if let URL = URL {
                        内容 = {
                            VedioView(url: URL)
                    }
                        //弹窗
                        if 播放视频次数 == 0 {
                            弹出提示.toggle()
                        } else {
                            开始播放()
                        }
                        
                    } else {
                        触感引擎.失败触感()
                    }
                }
//                播放.toggle()
            })
        }
        .alert("开始播放前会加载一会儿，请耐心等待\n\n播放时双击视频画面可以放大缩小", isPresented: $弹出提示, actions: {Button("🫡收到", action: {开始播放()})})//\n点击进度条后可以用表冠快进
        .sheet(isPresented: $播放, onDismiss: nil, content: 内容)
        .transition(.opacity.animation(.easeInOut))
        
    }
    
    func 开始播放() {
        播放视频次数 += 1
        播放.toggle()
        触感引擎.成功触感()
    }
}
