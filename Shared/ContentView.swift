//
//  ContentView.swift
//  Shared
//
//  Created by Timm Preetz (LunaONE GmbH) on 09.01.21.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State var message: String = ""

    var body: some View {
        Text(message)
            .padding(5)
            .frame(minWidth: 500, minHeight: 300, alignment: .topLeading)

        Image(systemName: "plus")
            .padding(100)
            .background(Color.white)
            .onDrop(of: [.fileURL, .item], isTargeted: nil, perform: {
                providers, _ in

                #if os(iOS)
                    providers.first!.loadFileRepresentation(forTypeIdentifier: UTType.item.identifier) {
                        url, _ in
                        message = describeDroppedURL(url!)
                    }
                #else
                    _ = providers.first!.loadObject(ofClass: NSPasteboard.PasteboardType.self) {
                        pasteboardItem, _ in
                        message = describeDroppedURL(URL(string: pasteboardItem!.rawValue)!)
                    }
                #endif

                return true
            })
    }
}

func describeDroppedURL(_ url: URL) -> String {
    do {
        var messageRows: [String] = []

        if try url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == false {
            messageRows.append("Dropped file named `\(url.lastPathComponent)`")

            messageRows.append("  which starts with `\(try String(contentsOf: url).components(separatedBy: "\n")[0]))`")
        } else {
            messageRows.append("Dropped folder named `\(url.lastPathComponent)`")

            for childUrl in try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: []) {
                messageRows.append("  Containing file named `\(childUrl.lastPathComponent)`")

                messageRows.append("    which starts with `\((try String(contentsOf: childUrl)).components(separatedBy: "\n")[0])`")
            }
        }

        return messageRows.joined(separator: "\n")
    } catch {
        return "Error: \(error)"
    }
}
