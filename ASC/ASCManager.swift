//
//  ASCManager.swift
//  ASC
//
//  Created by cocoa on 2023/5/17.
//

import Foundation
import AppStoreConnect_Swift_SDK

class ASCManager {
    
    /// 根据project生成manager
    /// - Parameter project: project description
    /// - Returns: description
    static func project(_ project: String) throws -> ASCManager {
        let issuerID = ASCConfiger.issuser_id(project)
        let privateKeyID = ASCConfiger.key_id(project)
        let key = ASCConfiger.token(project)
        if issuerID.count == 0 || privateKeyID.count == 0 || key.count == 0 {
            throw NSError(domain: "IssuerID、KeyID、Key 不能为空", code: 998, userInfo: ASCConfiger.data(project))
        } else {
            return ASCManager.init(issuerID: issuerID, privateKeyID: privateKeyID, privateKey: key)
        }
    }
    
    /// API请求provider
    var provider: APIProvider
    
    /// 初始化方法
    /// - Parameters:
    ///   - issuerID: issuerID description
    ///   - privateKeyID: privateKeyID description
    ///   - privateKey: privateKey description
    init(issuerID: String,
         privateKeyID: String,
         privateKey: String) {
        guard let configuration = try? APIConfiguration(issuerID: issuerID, privateKeyID: privateKeyID, privateKey: privateKey) else { fatalError() }
        provider = APIProvider(configuration: configuration)
    }
    
}
