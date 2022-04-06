//
//  Helper.swift
//  bilibili WatchKit Extension
//
//  Created by mac on 2022/3/26.
//

import Foundation
import SwiftUI

struct ContentView: View {
    
    var body: some View {
        Text("Hello, World!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - 打印Log
public func printLog(_ items: Any? = nil, separator: String = " ", terminator: String = "\n", file: String = #file, 函数名: String = #function, 行数: Int = #line) {
    
    if let 运算结果 = items {
        let 文件名 = (file as NSString).lastPathComponent
        let 时间 = Log扩展.dateToString(Date(), dateFormat: "yyyy/MM/dd HH:mm:ss")
        
        let 简洁版 = "\(文件名)[\(函数名)]\(运算结果)"
        let 完整版 = "[\(时间)][\(文件名)][\(函数名)][\(行数)]\(运算结果)"
        
        Swift.print(简洁版, terminator: terminator)
    } else {
        let 文件名 = (file as NSString).lastPathComponent
        let 时间 = Log扩展.dateToString(Date(), dateFormat: "yyyy/MM/dd HH:mm:ss")
        
        let 简洁版 = "\(文件名)[\(函数名)]"
        let 完整版 = "[\(时间)][\(文件名)][\(函数名)][\(行数)]"
        
        Swift.print(简洁版, terminator: terminator)
    }
    
    
    
}


public struct Log扩展 {
    static func stringToDate(_ string: String, dateFormat: String = "yyyyMMdd") -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = dateFormat
        let date = formatter.date(from: string)
        return date
    }
    
    static func dateToString(_ date: Date, dateFormat: String = "yyyy/MM/dd") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: date)
        return date
    }
    
    static func stringToDateString(_ string: String, fromFormat: String = "yyyyMMdd", toFormat: String = "yyyy/MM/dd") -> String {
        let fromFormatter = DateFormatter()
        fromFormatter.locale = Locale(identifier: "en_US_POSIX")
        fromFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        fromFormatter.dateFormat = fromFormat
        let date = fromFormatter.date(from: string)
        
        let toFormatter = DateFormatter()
        toFormatter.locale = Locale(identifier: "en_US_POSIX")
        toFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        toFormatter.dateFormat = toFormat
        
        let dateStr = toFormatter.string(from: date ?? Date())
        return dateStr
    }
}
// MARK: - 便利图片
extension Image {
    func 格式化图片(方式:ContentMode) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: 方式)
    }
}
extension URL {
    init() {
        self.init(string: "https://www.baidu.com/")!
    }
}
//
//  触感.swift
//  Experiment
//
//  Created by 凌嘉徽 on 2022/1/22.
//

import Foundation
import SwiftUI

class 触感引擎 {
    static func 轻触() {
#if os(watchOS)
        WKInterfaceDevice.current().play(.click)
#else
        UIImpactFeedbackGenerator.init(style: UIImpactFeedbackGenerator.FeedbackStyle.light).impactOccurred()
#endif
    }
    
    static func 中等触感() {
#if os(watchOS)
        WKInterfaceDevice.current().play(.click)
#else
        UIImpactFeedbackGenerator.init(style: UIImpactFeedbackGenerator.FeedbackStyle.medium).impactOccurred()
#endif
    }
    
    static func 成功触感() {
#if os(watchOS)
        WKInterfaceDevice.current().play(.success)
#else
        let notificationGenerator = UINotificationFeedbackGenerator()
        notificationGenerator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
#endif
    }
    
    static func 失败触感() {
#if os(watchOS)
        WKInterfaceDevice.current().play(.failure)
#else
        let notificationGenerator = UINotificationFeedbackGenerator()
        notificationGenerator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.error)
#endif
    }
}

