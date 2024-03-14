//
//  ASCWhatsNew.swift
//  ASC
//
//  Created by cocoa on 2023/5/17.
//

import Foundation

struct ASCWhatsNew {
    
    /// 获取whatsnew信息，根据入参，拆分成不同语言的whats new
    /// - Parameters:
    ///   - locale: <#localize description#>
    ///   - whatsNewStr: "whats new，每种语言最少十个字。‘,’分割不同语言，语言信息和内容以‘:’分割，参考'en-US:1234567890,zh-Hans:1234567890'"
    /// - Returns: <#description#>
    static func fetchWhasNew(locale: String,
                            whatsNewStr: String) -> (locale: String, whatsNew: String)? {
        if whatsNewStr.contains(":") {
            let arr = whatsNewStr.components(separatedBy: ",")
            var map: [String : String] = [:]
            arr.forEach({ str in
                let infos = str.components(separatedBy: ":")
                map[infos[0]] = infos[1]
            })
            if let whatsNew = map[locale] {
                print("------------- whatsNewStr: \(whatsNewStr), locale: \(locale), finalMsg: \(whatsNew)")

                return (locale, whatsNew)
            } else {
                return nil
            }
        } else {
            return (locale, whatsNewStr)
        }
    
    }
    
}
