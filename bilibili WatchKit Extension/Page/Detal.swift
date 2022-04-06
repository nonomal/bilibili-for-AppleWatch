//
//  Detal.swift
//  bilibili WatchKit Extension
//
//  Created by mac on 2022/3/27.
//

import Foundation
import SwiftUI


struct 详情: View {
    var item : 网络控制器.视频
    @StateObject var 控制器 = 网络控制器()
    var body: some View {
        NavigationView {
            VStack {
                
                List {
                    列表项目(item: item)
                        .overlay(ZStack {
                            Image(systemName: "play")
                                .imageScale(.large)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(.greatestFiniteMagnitude)
                        })
                    Section("相关视频") {
                        ForEach(控制器.视频列表) { item in
                            NavigationLink(item.标题 ?? "未知标题", destination: 详情(item: item))
                        }
                    }
                }
            
            }
            .onAppear(perform: {
                Task {
                    await 拉取相关视频()
                }
        })
        }
    }
    func 拉取相关视频() async {
        
        let 视频s = await 控制器.获取相关视频(bvid: item.bid)
//        print(视频s)
        控制器.视频列表.removeAll()
        控制器.视频列表 = 视频s
        if 视频s.isEmpty {
            触感引擎.失败触感()
        }
    }
}
