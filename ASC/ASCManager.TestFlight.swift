//
//  ASCManager.TestFlight.swift
//  ASC
//
//  Created by Cocoa on 2025/5/22.
//

import Foundation
import AppStoreConnect_Swift_SDK

extension ASCManager  {
    
    func fetchGroups(appID: String) async throws -> [BetaGroup] {
        let endPoint = APIEndpoint.v1.betaGroups.get(parameters: APIEndpoint.V1.BetaGroups.GetParameters(filterApp: [appID]))
        let groups = try await provider.request(endPoint).data
        return groups
    }
    
    
    func fetchBuild(
        appID: String,
        buildNumber: String
    ) async throws -> Build {
        let req = APIEndpoint.v1.builds.get(parameters: APIEndpoint.V1.Builds.GetParameters(filterVersion: [buildNumber],
                                                                                            filterApp: [appID]))
        if let result = try await provider.request(req).data.first {
            return result
        } else {
            throw NSError(domain: "\(buildNumber) 不存在", code: -991, userInfo: nil)
        }
    }
    
    func addBuild(_ buildId: String, to groupId: String) async throws {
        let endPoint = APIEndpoint.v1.betaGroups.id(groupId).relationships.builds.post(BetaGroupBuildsLinkagesRequest(data: [BetaGroupBuildsLinkagesRequest.Datum(type: .builds, id: buildId)]))
        try await provider.request(endPoint)
    }
    
    func submissionBeta(build: String) async throws -> BetaAppReviewSubmissionResponse {
        let endpoint = APIEndpoint.v1.betaAppReviewSubmissions.post(
            BetaAppReviewSubmissionCreateRequest(
                data: BetaAppReviewSubmissionCreateRequest.Data(
                    type: .betaAppReviewSubmissions,
                    relationships: BetaAppReviewSubmissionCreateRequest.Data.Relationships(
                        build: BetaAppReviewSubmissionCreateRequest.Data.Relationships.Build(
                            data: BetaAppReviewSubmissionCreateRequest.Data.Relationships.Build.Data(
                                type: .builds,
                                id: build
                            )
                        )
                    )
                )
            )
        )
        
        let result = try await provider.request(endpoint)
        return result
    }
}
