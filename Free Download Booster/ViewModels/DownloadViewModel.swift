//
//  DownloadViewModel.swift
//  Free Download Booster
//
//  Created by Abhyas Kumar Kanaujia on 03/04/26.
//

import Foundation
import Combine

@MainActor
final class DownloadViewModel: ObservableObject {

    // MARK: - Published

    @Published var urlText: String = ""
    @Published private(set) var isValidURL: Bool = false

    let downloadService: DownloadService

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(downloadService: DownloadService = DownloadService()) {
        self.downloadService = downloadService
        bindValidation()
    }

    // MARK: - Binding

    private func bindValidation() {
        $urlText
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .removeDuplicates()
            .map(validateURL)
            .assign(to: &$isValidURL)
    }

    // MARK: - Validation

    private func validateURL(_ string: String) -> Bool {
        guard let url = URL(string: string),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme)
        else { return false }
        return true
    }

    // MARK: - Actions

    func startDownload() {
        let trimmed = urlText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard validateURL(trimmed) else {
            return
        }

        downloadService.startDownload(url: trimmed)
        urlText = ""
    }
}