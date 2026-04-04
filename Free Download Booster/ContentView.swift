//
//  ContentView.swift
//  Free Download Booster
//
//  Created by Abhyas Kumar Kanaujia on 03/04/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DownloadViewModel()

    var body: some View {
        VStack {
            // Primary input control
            DownloadInput(
                text: $viewModel.urlText,
                isValid: viewModel.isValidURL,
                onSubmit: viewModel.startDownload
            )
            .frame(maxWidth: 500)
            .padding(.top, 20)

            // Content area
            contentArea
        }
        .frame(minWidth: 600, minHeight: 400)
    }

    // MARK: - Content Area

    private var contentArea: some View {
        Group {
            if viewModel.downloads.isEmpty {
                emptyState
            } else {
                downloadList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("No Downloads")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Enter a URL to start downloading")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var downloadList: some View {
        List(viewModel.downloads) { download in
            HStack(alignment: .center, spacing: 12) {
                // File icon - fixed width
                Image(systemName: icon(for: download.status))
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 6) {
                    // File name - primary content
                    Text(download.fileName.isEmpty ? download.url : download.fileName)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .font(.system(.body))

                    // Status line - always present, always same height
                    Text(statusText(for: download, bytesPerSecond: download.bytesPerSecond))
                        .font(.caption)
                        .foregroundColor(statusColor(for: download.status))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)

                    // Progress line - always present, thin, subtle
                    ProgressView(value: download.progress)
                        .progressViewStyle(.linear)
                        .controlSize(.small)
                        .tint(progressTint(for: download.status))
                        .opacity(progressOpacity(for: download.status))
                }

                Spacer()

                // Trailing controls - fixed slot, actions by state
                HStack(spacing: 8) {
                    trailingControl(for: download)
                }
                .frame(width: 56)
            }
            .padding(.vertical, 8)
        }
    }

    private func statusText(for download: DownloadItem, bytesPerSecond: Int64) -> String {
        switch download.status {
        case .pending:
            return "Preparing..."
        case .downloading:
            let downloaded = ByteCountFormatter.string(
                fromByteCount: download.downloadedBytes,
                countStyle: .file
            )

            let total = download.totalBytes > 0
                ? ByteCountFormatter.string(
                    fromByteCount: download.totalBytes,
                    countStyle: .file
                )
                : "unknown size"

            let speed = bytesPerSecond > 0
                ? " • " + ByteCountFormatter.string(fromByteCount: bytesPerSecond, countStyle: .file) + "/s"
                : ""

            return "\(downloaded) of \(total)\(speed)"

        case .completed:
            return "Completed"
        case .paused:
            return "Paused"
        case .failed(let error):
            return "Failed: \(error)"
        }
    }

    private func progressTint(for status: DownloadStatus) -> Color {
        switch status {
        case .completed:
            return .secondary
        case .failed:
            return .red
        default:
            return .accentColor
        }
    }

    private func progressOpacity(for status: DownloadStatus) -> Double {
        switch status {
        case .completed:
            return 0.2
        case .failed:
            return 0.3
        default:
            return 1.0
        }
    }

    private func statusColor(for status: DownloadStatus) -> Color {
        switch status {
        case .completed:
            return .secondary.opacity(0.7)
        default:
            return .secondary
        }
    }

    @ViewBuilder
    private func trailingControl(for download: DownloadItem) -> some View {
        switch download.status {
        case .pending, .downloading:
            ProgressView()
                .controlSize(.small)
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green.opacity(0.8))
        case .paused:
            Image(systemName: "play.circle")
                .foregroundStyle(.blue)
        case .failed:
            Image(systemName: "arrow.clockwise.circle")
                .foregroundStyle(.orange)
        }
    }

    private func icon(for status: DownloadStatus) -> String {
        switch status {
        case .completed:
            return "doc.fill"
        case .downloading, .pending:
            return "doc"
        case .paused:
            return "doc.badge.plus"
        case .failed:
            return "exclamationmark.triangle"
        }
    }
}

// MARK: - Download Input Component

struct DownloadInput: View {
    @Binding var text: String
    var isValid: Bool
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            TextField("Enter download URL", text: $text)
                .textFieldStyle(.plain)
                .onSubmit(onSubmit)

            Button(action: onSubmit) {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundStyle(isValid ? .blue : .secondary)
            }
            .buttonStyle(.plain)
            .disabled(!isValid)
        }
        .padding(10)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ContentView()
}
