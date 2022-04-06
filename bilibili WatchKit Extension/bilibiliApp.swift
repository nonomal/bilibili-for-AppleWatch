//
//  bilibiliApp.swift
//  bilibili WatchKit Extension
//
//  Created by mac on 2022/3/26.
//

import SwiftUI

@main
struct bilibiliApp: App {

    @State var 显示 = true

    var body: some Scene {
        WindowGroup {
            NavigationView {
                Main()
                    .alert("欢迎使用👏", isPresented: $显示, actions: {
                        Button("来自凌嘉徽的爱❤️", action: {print("按下")})
                    })
            }
        }
    }
}
