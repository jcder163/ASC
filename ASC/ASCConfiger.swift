//
//  ASCConfiger.swift
//  ASC
//
//  Created by cocoa on 2023/5/17.
//

import Foundation

class ASCConfiger {
    
    /// 设置配置
    /// - Parameters:
    ///   - project: 项目名称，用于比较方便的识别项目
    ///   - issuser_id: issuser_id description
    ///   - key_id: key_id description
    ///   - token: token description
    ///   - appId: appId description
    static func save(
        project: String,
        issuser_id: String,
        key_id: String,
        token: String,
        appId: String,
        groupId: String
    ) {
        if var data = UserDefaults.standard.object(forKey: "projects_config") as? [String : [String : String]] {
            data[project] = ["issuser_id" : issuser_id,
                             "key_id" : key_id,
                             "appId" : appId,
                             "groupId" : groupId,
                             "token" : token]
            UserDefaults.standard.set(data,
                                      forKey: "projects_config")
        } else {
            UserDefaults.standard.set([project : ["issuser_id" : issuser_id,
                                                    "key_id" : key_id,
                                                    "appId" : appId,
                                                  "groupId" : groupId,
                                                    "token" : token]],
                                      forKey: "projects_config")
        }

    }
    
    static func issuser_id(_ project: String) -> String {
        let data = UserDefaults.standard.object(forKey: "projects_config") as? [String : [String : String]]
        return data?[project]?["issuser_id"] ?? ""
    }
    
    static func key_id(_ project: String) -> String {
        let data = UserDefaults.standard.object(forKey: "projects_config") as? [String : [String : String]]
        return data?[project]?["key_id"] ?? ""
    }
    
    static func token(_ project: String) -> String {
        let data = UserDefaults.standard.object(forKey: "projects_config") as? [String : [String : String]]
        return data?[project]?["token"] ?? ""
    }
    
    static func data(_ project: String) -> [String : String] {
        let data = UserDefaults.standard.object(forKey: "projects_config") as? [String : [String : String]]
        return data?[project] ?? [:]
    }
    
    static func appId(_ project: String) -> String {
        let data = UserDefaults.standard.object(forKey: "projects_config") as? [String : [String : String]]
        return data?[project]?["appId"] ?? ""
    }
    
    static func projects() -> [String] {
        let data = UserDefaults.standard.object(forKey: "projects_config") as? [String : [String : String]]

        return data?.compactMap { $0.key } ?? []
    }
    
    static func groupId(_ project: String) -> String {
        let data = UserDefaults.standard.object(forKey: "projects_config") as? [String : [String : String]]
        return data?[project]?["groupId"] ?? ""
    }
}

@propertyWrapper
public struct WrappedDefault<T: Any> {

    private let userDefaults: UserDefaults

    public let key: String

    public var wrappedValue: T? {
        get {
            return userDefaults.object(forKey: key) as? T
        }
        set {
            userDefaults.set(newValue, forKey: key)
        }
    }

    public init(keyName: String,
                userDefaults: UserDefaults = .standard) {
        self.key = keyName
        self.userDefaults = userDefaults
    }
}
