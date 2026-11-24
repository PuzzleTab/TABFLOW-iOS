//
//  TABFLOWApp.swift
//  Puzzletab (iOS and iPadOS)
//
//  The containing app. Puzzletab is a Safari extension: this app only carries the extension onto the device and
//  explains how to turn it on. It is not a browser, shows no web content and makes no network requests.
//  The dashboard and the quick view are the extension's own pages inside Safari (the "TABFLOW Extension" target,
//  whose files are built from the Puzzletab source on every Xcode build).
//

import SwiftUI

@main
struct TABFLOWApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// Which Puzzletab extension this app carries, read from the build stamp the WXT build phase writes into the extension
/// (`TABFLOW Extension.appex/tabflow-build.json`; apple/scripts/build-safari-extension.sh). A copy built from Xcode's
/// Safari Extension App template has no stamp: its popup is Apple's sample page, so the app says so.
func embeddedExtensionDescription() -> String {
    let missing = "This app does not contain the Puzzletab extension (no Puzzletab build stamp). If Safari shows Apple's sample popup instead of Puzzletab, delete this app and build apple/TABFLOW-iOS from the Puzzletab source."
    guard let plugins = Bundle.main.builtInPlugInsURL else { return missing }
    let stamp = plugins
        .appendingPathComponent("TABFLOW Extension.appex", isDirectory: true)
        .appendingPathComponent("tabflow-build.json", isDirectory: false)
    guard let data = try? Data(contentsOf: stamp),
          let object = try? JSONSerialization.jsonObject(with: data),
          let build = object as? [String: Any] else { return missing }
    let version = build["version"] as? String ?? "?"
    let commit = build["commit"] as? String ?? "?"
    let builtAt = build["builtAt"] as? String ?? "?"
    return "Extension: Puzzletab \(version) (\(commit)), built \(builtAt)"
}

struct ContentView: View {
    private let extensionDescription = embeddedExtensionDescription()

    private var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "Puzzletab \(short) (build \(build))"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Puzzletab")
                    .font(.largeTitle.bold())
                Text("Puzzletab is a Safari extension. It organizes your open Safari tabs into groups inside Puzzletab. This app only installs it.")
                    .font(.body)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Turn Puzzletab on")
                        .font(.headline)
                    Step(number: 1, text: "Open the Settings app.")
                    Step(number: 2, text: "Go to Apps, then Safari, then Extensions.")
                    Step(number: 3, text: "Tap Puzzletab and turn on Allow Extension.")
                    Step(number: 4, text: "In Safari, open the page menu in the address bar and tap Puzzletab.")
                }

                Text("Your tabs and settings stay on this device. Puzzletab makes no network requests.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(version)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(extensionDescription)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
            .padding(24)
            .frame(maxWidth: 560, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct Step: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(number).")
                .font(.body.monospacedDigit())
                .foregroundStyle(.secondary)
            Text(text)
                .font(.body)
        }
    }
}
