//
//  ASCConfiger.swift
//  ASC
//
//  Created by cocoa on 2023/5/17.
//

import Foundation

class ASCConfiger {
    
    static func save(project: String, issuser_id: String, key_id: String, token: String, appId: String) {
        UserDefaults.standard.set([project : ["issuser_id" : issuser_id,
                                                "key_id" : key_id,
                                                "appId" : appId,
                                                "token" : token]],
                                  forKey: "projects_config")
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
