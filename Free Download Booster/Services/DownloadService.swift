//
//  DownloadService.swift
//  Free Download Booster
//
//  Created by Abhyas Kumar Kanaujia on 03/04/26.
//

import Foundation
import Combine

struct DownloadItem: Identifiable, Equatable {
    let id: UUID
    let url: String
    let fileName: String
    let progress: Double
    let status: DownloadStatus

    init(id: UUID = UUID(), url: String, fileName: String = "", progress: Double = 0, status: DownloadStatus = .pending) {
        self.id = id
        self.url = url
        self.fileName = fileName
        self.progress = progress
        self.status = status
    }
}

enum DownloadStatus: Equatable {
    case pending
    case downloading
    case completed
    case paused
    case failed(String)
}

class DownloadService: ObservableObject {
    @Published var downloads: [DownloadItem] = []

    func startDownload(url: String) {
        // TODO: Implement actual download logic
        let item = DownloadItem(url: url, fileName: URL(string: url)?.lastPathComponent ?? "")
        downloads.append(item)
        print("Starting download: \(url)")
    }
}
