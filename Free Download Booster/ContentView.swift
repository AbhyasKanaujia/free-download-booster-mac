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
            if viewModel.downloadService.downloads.isEmpty {
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
        List(viewModel.downloadService.downloads) { download in
            VStack(alignment: .leading, spacing: 4) {
                Text(download.fileName.isEmpty ? download.url : download.fileName)
                Text(download.url)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    ContentView()
}
