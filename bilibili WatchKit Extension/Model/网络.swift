//
//  网络.swift
//  bilibili WatchKit Extension
//
//  Created by mac on 2022/3/26.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit

class 网络控制器 : ObservableObject {
    
    @Published var 视频列表 : [视频] = []
    
    ///https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/video/info.md#%E8%8E%B7%E5%8F%96%E8%A7%86%E9%A2%91%E8%AF%A6%E7%BB%86%E4%BF%A1%E6%81%AF%EF%BC%88web%E7%AB%AF%EF%BC%89
    static func 处理视频对象(对象:JSON) -> 视频? {
        let BV号 = 对象["bvid"].string
        let 标题 = 对象["title"].string
        let 封面URL = 对象["pic"].string
        
        if let BV号 = BV号 {
            return 视频(bid: BV号,标题:标题,封面URL:封面URL)
        } else {
            printLog("找不到bvid\(对象)")
            return nil
        }
       
    }
    func 获取所有榜单() async -> [视频]  {
        
        var 准备返回 : [视频] = []
        let 所有分区的tid : [Int] = [1,13,167,3,129,4,36,188,234,223,160,211,217,119,155,202,5,181,177,23,11]
        let 序列化 : [分区] = 所有分区的tid.map({ 分区(tid: $0) })
        
        let 抽取 = 序列化.randomElement()!.tid
        
        //网络请求
        let 网址 = "http://api.bilibili.com/x/web-interface/ranking/region"
        let 负载 = ["rid":"\(抽取)"]
        do {
            let json = try await 异步网络请求(网址: 网址, 负载: 负载)
            if let 返回的视频 = json["data"].array {
                let 处理后的视频 = 返回的视频.map({ 网络控制器.处理视频对象(对象: $0) })
                
                处理后的视频.forEach({
                    if let 解包 = $0 {
                        准备返回.append(解包)
                    }
                })
            }
        } catch {
            printLog("\(error.localizedDescription)")
        }
        return 准备返回
    }
    func 获取相关视频(bvid:String) async -> [视频]  {
        
        var 准备返回 : [视频] = []
        
        //网络请求
        let 网址 = "http://api.bilibili.com/x/web-interface/archive/related"
        let 负载 = ["bvid":bvid]
        do {
            let json = try await 异步网络请求(网址: 网址, 负载: 负载)
            if let 返回的视频 = json["data"].array {
                let 处理后的视频 = 返回的视频.map({ 网络控制器.处理视频对象(对象: $0) })
                
                处理后的视频.forEach({
                    if let 解包 = $0 {
                        准备返回.append(解包)
                    }
                })
            }
        } catch {
            printLog("\(error.localizedDescription)")
        }
        return 准备返回
    }
    struct 视频 : Identifiable {
        
        
        var bid : String
        var 标题 : String? = nil
        var 封面URL : String? = nil
        
            //继承
           internal let id = UUID()
        
    }
    
    struct 分区 : Identifiable {
        
        
        var tid : Int
        var 名称 : String? = nil
        
            //继承
           internal let id = UUID()
        
    }
    static func 视频解析(bid:String) async -> URL? {
        let 网址 = "https://api.injahow.cn/bparse/?bv=\(bid)&p=1&format=mp4&otype=url"
        do {
            let url = try await 异步网络请求(网址: 网址)
            let 制作 = URL(string: url)
            return 制作
        } catch {
            printLog("\(error.localizedDescription)")
        }
        return nil
    }
}
func 异步网络请求(网址: String) async throws -> String {
    try await withUnsafeThrowingContinuation { continuation in
        AF.request(网址, method: .get).validate().responseData { response in
            if let data = response.data {
                ///⎡200⎦意味着成功
                let 状态码 = response.response?.statusCode
                if 状态码 == 200 {
                            let json = dataToStr(data)
                            if let json = json {
                                continuation.resume(returning: json)
                                return
                            } else {
                                let Meaasge = "未获取到String"
                                printLog(Meaasge)
                                continuation.resume(throwing: 错误.消息(message: Meaasge))
                                return
                            }
                } else {
                    let Meaasge = "请求失败：\(状态码)"
                    printLog(Meaasge)
                    continuation.resume(throwing: 错误.消息(message: Meaasge))
                    return
                }
            }
            if let err = response.error {
                continuation.resume(throwing: err)
                return
            }
            fatalError("should not get here")
        }
    }
}
func 异步网络请求(网址: String,负载: [String : String]) async throws -> JSON {
    try await withUnsafeThrowingContinuation { continuation in
        AF.request(网址, method: .get, parameters: 负载, encoder: URLEncodedFormParameterEncoder.default).validate().responseData { response in
            if let data = response.data {
                ///⎡200⎦意味着成功
                let 状态码 = response.response?.statusCode
                if 状态码 == 200 {
                        do {
                            let json = try JSON(data: data)
                            continuation.resume(returning: json)
                            return
                        } catch {
                            printLog("JSON解码失败\(error.localizedDescription)")
                            continuation.resume(throwing: error)
                            return
                        }
                } else {
                    printLog("请求失败：\(状态码)")
                    continuation.resume(throwing: 错误.消息(message: "请求失败：\(状态码)"))
                    return
                }
            }
            if let err = response.error {
                continuation.resume(throwing: err)
                return
            }
            fatalError("should not get here")
        }
    }
}
///使用Post方法
func 基本请求(网址: String,负载: [String : String],处理器: @escaping (JSON) -> ()) {

//    let 网址 = "http://api.bilibili.com/x/web-interface/ranking/region"
    /**
        即使它看起来像这样（只有一个对象）：
        ```
            curl -d "text=hello%20world" http://bark.phon.ioc.ee/punctuator
        ```
        也应该使用字典
    */
//    let 负载 = ["rid":"hello world"]
    
    AF.request(网址, method: .get, parameters: 负载, encoder: URLEncodedFormParameterEncoder.default).response { 回答 in

        
        
        
    }
}


enum 错误: LocalizedError {
    
  case 消息(message: String)
    
    public var errorDescription: String? {
      switch self {
      case .消息(message: let message):
        return "抛出异常：\(message)"
    }
  }

}
// MARK: - 处理返回数据
///如果Data内容不是String，会抛出nil
func dataToStr(_ Data:Data) -> String? {
    let 文字 = String(data: Data, encoding: .utf8)
    if 文字 == nil {
        print("Data内容不是String")
    }
    return 文字
}
