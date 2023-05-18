//
//  ASCManager.swift
//  ASC
//
//  Created by cocoa on 2023/5/17.
//

import Foundation
import AppStoreConnect_Swift_SDK

class ASCManager {
    
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
    
    var provider: APIProvider
    
    init(issuerID: String,
         privateKeyID: String,
         privateKey: String) {
        guard let configuration = try? APIConfiguration(issuerID: issuerID, privateKeyID: privateKeyID, privateKey: privateKey) else { fatalError() }
        provider = APIProvider(configuration: configuration)
        
    }
    
}
extension ASCManager {
    
    
    /// 获取app信息
    /// - Parameter projectId: App id
    /// - Returns: app信息
    func fetchApp(with projectId: String) async throws -> App {
        let request = APIEndpoint.v1.apps.id(projectId).get(parameters: APIEndpoint.V1.Apps.WithID.GetParameters(fieldsApps: [.appStoreVersions, .appInfos, .bundleID, .preReleaseVersions]))
        
        let result = try await provider.request(request).data
        return result
            
       
        
    }
    
    
    /// 创建版本
    /// - Parameters:
    ///   - app: app
    ///   - versionString: 版本号
    /// - Returns: 版本信息
    func createVersion(app: App,
                       versionString: String) async throws -> AppStoreVersion {
        let request = APIEndpoint.v1.appStoreVersions.post(AppStoreVersionCreateRequest(data: AppStoreVersionCreateRequest.Data(type: .appStoreVersions,
                                                                                                                                attributes: AppStoreVersionCreateRequest.Data.Attributes(platform: .ios,
                                                                                                                                                                                         versionString: versionString,
                                                                                                                                                                                         releaseType: .manual),
                                                                                                                                relationships: AppStoreVersionCreateRequest.Data.Relationships(app: AppStoreVersionCreateRequest.Data.Relationships.App(data: AppStoreVersionCreateRequest.Data.Relationships.App.Data(type: .apps, id: app.id))))))
        
        let result = try await provider.request(request).data
        return result
    }
    
    
    /// 查找对应版本号的版本信息
    /// - Parameters:
    ///   - app: app
    ///   - versionString: 版本号
    /// - Returns: 版本信息
    func fetchAppVerion(app: App,
                        versionString: String) async throws -> AppStoreVersion {
        let req = APIEndpoint.v1.apps.id(app.id).appStoreVersions.get()
        
        
        let result = try await provider.request(req).data
        if let version = (result.first { $0.attributes?.versionString == versionString }) {
            return version
        } else {
            throw NSError(domain: "App: \(app.id), 不存在\(versionString) 版本", code: 999)
        }
        
    }
    
    /// 获取 版本信息
    /// - Parameter version: 版本
    /// - Returns: 版本信息
    func fetchLocalize(version: AppStoreVersion) async throws -> [AppStoreVersionLocalization] {
        
        let req = APIEndpoint.v1.appStoreVersions.id(version.id).appStoreVersionLocalizations.get()
        let result = try await provider.request(req).data
        return result
    }
    
    /// 更新app本地化信息
    /// - Parameters:
    ///   - whatsNew: whats new
    ///   - localize: 本地化信息
    /// - Returns: 本地化信息
    func update(whatsNew: String,
                localize: AppStoreVersionLocalization) async throws -> AppStoreVersionLocalization {
        
        let req = APIEndpoint.v1.appStoreVersionLocalizations.id(localize.id).patch(AppStoreVersionLocalizationUpdateRequest(data: AppStoreVersionLocalizationUpdateRequest.Data(type: .appStoreVersionLocalizations, id: localize.id, attributes: AppStoreVersionLocalizationUpdateRequest.Data.Attributes(whatsNew: whatsNew))))
            
        let result = try await provider.request(req).data
        return result
    }

    
    /// <#Description#>
    /// - Parameter appVersion: <#appVersion description#>
    /// - Returns: <#description#>
    func createPhasedRelease(appVersion: AppStoreVersion) async throws -> AppStoreVersionPhasedRelease {
        let req = APIEndpoint.v1.appStoreVersionPhasedReleases.post(AppStoreVersionPhasedReleaseCreateRequest(data: AppStoreVersionPhasedReleaseCreateRequest.Data(type: .appStoreVersionPhasedReleases, relationships: AppStoreVersionPhasedReleaseCreateRequest.Data.Relationships(appStoreVersion: AppStoreVersionPhasedReleaseCreateRequest.Data.Relationships.AppStoreVersion(data: AppStoreVersionPhasedReleaseCreateRequest.Data.Relationships.AppStoreVersion.Data(type: .appStoreVersions,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                           id: appVersion.id)
        )))))
        
        let result = try await provider.request(req).data
        print(result)
        return result
        
    }
    
    /// 获取灰度状态
    /// - Parameter appversion: 版本
    /// - Returns: 灰度信息
    func readPhasedRelease(appversion: AppStoreVersion) async throws -> AppStoreVersionPhasedRelease {
        let req = APIEndpoint.v1.appStoreVersions.id(appversion.id).appStoreVersionPhasedRelease.get()
        
        let result = try await provider.request(req).data
        return result
    }
}
