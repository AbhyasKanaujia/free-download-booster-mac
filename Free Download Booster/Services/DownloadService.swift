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
    var fileName: String
    var progress: Double
    var status: DownloadStatus
    var bytesPerSecond: Int64
    var totalBytes: Int64
    var downloadedBytes: Int64

    init(id: UUID = UUID(), url: String, fileName: String = "", progress: Double = 0, status: DownloadStatus = .pending, bytesPerSecond: Int64 = 0, totalBytes: Int64 = 0, downloadedBytes: Int64 = 0) {
        self.id = id
        self.url = url
        self.fileName = fileName
        self.progress = progress
        self.status = status
        self.bytesPerSecond = bytesPerSecond
        self.totalBytes = totalBytes
        self.downloadedBytes = downloadedBytes
    }
}

enum DownloadStatus: Equatable {
    case pending
    case downloading
    case completed
    case paused
    case failed(String)
}

class DownloadService: NSObject, ObservableObject {
    @Published var downloads: [DownloadItem] = []

    private var session: URLSession!
    private var taskURLMap: [Int: UUID] = [:]

    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    func startDownload(url: String) {
        guard let url = URL(string: url) else {
            print("[DownloadService] ❌ Invalid URL: \(url)")
            return
        }

        let fileName = url.lastPathComponent.isEmpty ? "download" : url.lastPathComponent
        let item = DownloadItem(url: url.absoluteString, fileName: fileName)

        print("[DownloadService] 🚀 Starting download: \(url)")
        print("[DownloadService] 📁 Filename: \(fileName)")

        DispatchQueue.main.async {
            self.downloads.append(item)
            print("[DownloadService] 📝 Added download to list, count: \(self.downloads.count)")
        }

        let task = session.downloadTask(with: url)
        taskURLMap[task.taskIdentifier] = item.id
        print("[DownloadService] 📡 Task created: \(task.taskIdentifier), mapped to ID: \(item.id)")
        task.resume()
        print("[DownloadService] ▶️ Task resumed")
    }
}

// MARK: - URLSessionDownloadDelegate

extension DownloadService: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let id = taskURLMap[downloadTask.taskIdentifier] else {
            print("[DownloadService] ❌ didFinishDownloadingTo: No ID found for task \(downloadTask.taskIdentifier)")
            return
        }

        print("[DownloadService] ✅ Download finished to temp location: \(location.path)")
        print("[DownloadService] 📄 Suggested filename: \(downloadTask.response?.suggestedFilename ?? "nil")")

        // Get downloads folder
        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        let destinationURL = downloadsURL.appendingPathComponent(downloadTask.response?.suggestedFilename ?? "download")

        print("[DownloadService] 📁 Destination: \(destinationURL.path)")

        // Check if temp file exists
        let tempExists = FileManager.default.fileExists(atPath: location.path)
        print("[DownloadService] 🔍 Temp file exists: \(tempExists)")

        do {
            // Remove existing file if present
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                print("[DownloadService] 🗑️ Removing existing destination file")
                try FileManager.default.removeItem(at: destinationURL)
            }

            print("[DownloadService] 📦 Moving file from temp to destination...")
            try FileManager.default.moveItem(at: location, to: destinationURL)
            print("[DownloadService] ✅ File move successful")

            DispatchQueue.main.async {
                if let index = self.downloads.firstIndex(where: { $0.id == id }) {
                    self.downloads[index].status = .completed
                    self.downloads[index].progress = 1.0
                    print("[DownloadService] 🎉 Download marked as completed")
                }
            }
        } catch {
            print("[DownloadService] ❌ File move failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                if let index = self.downloads.firstIndex(where: { $0.id == id }) {
                    self.downloads[index].status = .failed(error.localizedDescription)
                    print("[DownloadService] 💥 Download marked as failed: \(error)")
                }
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let id = taskURLMap[downloadTask.taskIdentifier] else { return }

        let progress = totalBytesExpectedToWrite > 0
            ? Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            : 0

        DispatchQueue.main.async {
            if let index = self.downloads.firstIndex(where: { $0.id == id }) {
                self.downloads[index].status = .downloading
                self.downloads[index].progress = progress
                self.downloads[index].bytesPerSecond = bytesWritten
                self.downloads[index].totalBytes = totalBytesExpectedToWrite
                self.downloads[index].downloadedBytes = totalBytesWritten
            }
        }

        // Log at 0%, 50%, and 100%
        if progress == 0 || progress >= 0.5 || progress >= 1.0 {
            print("[DownloadService] 📊 Progress: \(Int(progress * 100))% (\(totalBytesWritten) / \(totalBytesExpectedToWrite) bytes)")
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtResumeFileURL location: URL) {
        guard let id = taskURLMap[downloadTask.taskIdentifier] else { return }

        DispatchQueue.main.async {
            if let index = self.downloads.firstIndex(where: { $0.id == id }) {
                self.downloads[index].status = .downloading
            }
        }
        print("[DownloadService] ⏯️ Download resumed at: \(location.lastPathComponent)")
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let taskID = task.taskIdentifier
        guard let id = taskURLMap[taskID] else {
            print("[DownloadService] ❌ didCompleteWithError: No ID found for task \(taskID)")
            return
        }

        if let error = error {
            print("[DownloadService] 💥 Task \(taskID) completed with error: \(error.localizedDescription)")
            print("[DownloadService] Error details: \(error)")

            DispatchQueue.main.async {
                if let index = self.downloads.firstIndex(where: { $0.id == id }) {
                    self.downloads[index].status = .failed(error.localizedDescription)
                }
            }
        } else {
            print("[DownloadService] ✅ Task \(taskID) completed successfully (no error)")
        }

        taskURLMap.removeValue(forKey: taskID)
        print("[DownloadService] 🗑️ Removed task \(taskID) from mapping")
    }
}
