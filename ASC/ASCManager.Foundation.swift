//
//  ASCManager.Foundation.swift
//  ASC
//
//  Created by cocoa on 2024/3/13.
//

import Foundation
import AppStoreConnect_Swift_SDK

extension ASCManager {
    
    /// 获取app信息
    /// - Parameter projectId: App id
    /// - Returns: app信息
    func fetchApp(with projectId: String) async throws -> App {
        let request = APIEndpoint.v1.apps.id(projectId).get(parameters: APIEndpoint.V1.Apps.WithID.GetParameters(fieldsApps: [.appStoreVersions, .appInfos, .bundleID, .preReleaseVersions]))
        
        let result = try await provider.request(request).data
        return result
    }
    
    
    /// 更新构建到版本
    /// - Parameters:
    ///   - appID: appid
    ///   - versionID: 版本id
    ///   - buildID: 构建id
    /// - Returns: 版本信息
    func updateVersion(appID: String,
                       versionID: String,
                       buildID: String) async throws -> AppStoreVersion {
        
        let versionUpdateReq = AppStoreVersionUpdateRequest(data: AppStoreVersionUpdateRequest.Data(type: .appStoreVersions,
                                                                                                    id: versionID,
                                                                                                    relationships:  AppStoreVersionUpdateRequest.Data.Relationships(build: AppStoreVersionUpdateRequest.Data.Relationships.Build(data: AppStoreVersionUpdateRequest.Data.Relationships.Build.Data(type: .builds, id: buildID)))))
        let req = APIEndpoint.v1.appStoreVersions.id(versionID).patch(versionUpdateReq)
        
        let data = try await provider.request(req).data
        
        
        if data.relationships?.build?.data?.id != buildID {
            fatalError("\(appID) \(versionID) 更新build失败: \(buildID)")
        }
        return data
    }
        
    /// 查找对应版本号的版本信息
    /// - Parameters:
    ///   - app: app
    ///   - versionString: 版本号
    /// - Returns: 版本信息
    func fetchAppVerion(appID: String,
                        versionString: String) async throws -> AppStoreVersion {
        let req = APIEndpoint.v1.apps.id(appID).appStoreVersions.get(parameters: APIEndpoint.V1.Apps.WithID.AppStoreVersions.GetParameters(filterVersionString: [versionString], include: [.build]))
        
        
        let result = try await provider.request(req).data
        if let version = result.first {
            return version
        } else {
            throw NSError(domain: "App: \(appID), 不存在\(versionString) 版本", code: 999)
        }
        
    }
    
    /// 设置灰度发布
    /// - Parameter versionId: 版本id
    func setPhased(versionId: String) async throws {
        // 获取app 分阶段发布状态
        do {
            let phaseRelease = try await readPhasedRelease(versionID: versionId)
            // 默认改为分阶段发布
            if phaseRelease.attributes?.phasedReleaseState == .none || phaseRelease.attributes?.phasedReleaseState == nil {
                
                let phasedReleaseState: PhasedReleaseState? = phaseRelease.attributes?.phasedReleaseState
                let phased = try await self.createPhasedRelease(versionID: versionId)
                let phasedReleaseState1: PhasedReleaseState? = phased.attributes?.phasedReleaseState
                print("版本: \(versionId), 灰度状态: \(phasedReleaseState?.rawValue ?? "Nill") -> \(phasedReleaseState1?.rawValue ?? "Nill")")
            }
        } catch let error {
            print(error)
        }
    }
    
    /// 获取版本信息
    /// - Parameter version: 版本
    /// - Returns: 版本信息
    func fetchLocalize(versionID: String) async throws -> [AppStoreVersionLocalization] {
        
        let req = APIEndpoint.v1.appStoreVersions.id(versionID).appStoreVersionLocalizations.get()
        let result = try await provider.request(req).data
        return result
    }
    
    
    /// 更新whats new
    /// - Parameters:
    ///   - whatsnew: whats new
    ///   - versionId: 版本id
    func updateWhatsNew(_ whatsnew: String, versionId: String) async throws {
        // 获取对应版本的本地化语言
        let localInfos = try await self.fetchLocalize(versionID: versionId)
        
        for info in localInfos {
            let finalInfo = ASCWhatsNew.fetchWhasNew(locale: info.attributes?.locale ?? "",
                                                    whatsNewStr: whatsnew)?.whatsNew ?? whatsnew
            // 修改whatsnew
            print("localInfo: \(info.attributes?.locale ?? ""), whatsNew: \(finalInfo)")
            let localInfo = try await self.update(whatsNew: finalInfo,
                                               localize: info)
            // 校验是否修改完成
            if localInfo.attributes?.whatsNew == finalInfo {
                
            } else {
                fatalError("修改whatsnew 失败")
            }
        }
    }
    
}
private extension ASCManager {
    
    /// 获取灰度状态
    /// - Parameter appversion: 版本
    /// - Returns: 灰度信息
    func readPhasedRelease(versionID: String) async throws -> AppStoreVersionPhasedRelease {
        let req = APIEndpoint.v1.appStoreVersions.id(versionID).appStoreVersionPhasedRelease.get()
        
        let result = try await provider.request(req).data
        return result
    }
    
    /// <#Description#>
    /// - Parameter appVersion: <#appVersion description#>
    /// - Returns: <#description#>
    func createPhasedRelease(versionID: String) async throws -> AppStoreVersionPhasedRelease {
        let req = APIEndpoint.v1.appStoreVersionPhasedReleases.post(AppStoreVersionPhasedReleaseCreateRequest(data: AppStoreVersionPhasedReleaseCreateRequest.Data(type: .appStoreVersionPhasedReleases, relationships: AppStoreVersionPhasedReleaseCreateRequest.Data.Relationships(appStoreVersion: AppStoreVersionPhasedReleaseCreateRequest.Data.Relationships.AppStoreVersion(data: AppStoreVersionPhasedReleaseCreateRequest.Data.Relationships.AppStoreVersion.Data(type: .appStoreVersions,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                           id: versionID)
        )))))
        
        let result = try await provider.request(req).data
        print(result)
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
    
    
}
