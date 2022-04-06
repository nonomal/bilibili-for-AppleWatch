//
//  Vedio.swift
//  bilibili WatchKit Extension
//
//  Created by mac on 2022/3/26.
//

import Foundation
import SwiftUI
import AVKit
import AVFoundation

struct VedioView: View {
    
    var url : URL
    

    var body: some View {
        let 播放器 = AVPlayer(url: url)
     
    
        VStack {
           
            VideoPlayer(player: 播放器)
        

        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
}
}
