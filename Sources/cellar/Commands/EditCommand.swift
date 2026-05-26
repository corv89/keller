import ArgumentParser
import Foundation

struct EditCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "edit",
        abstract: "Open $EDITOR on one formula's annotation."
    )

    @Argument(help: "Name of the Homebrew formula to annotate.")
    var name: String

    func run() throws {
        let annotations = AnnotationStore.loadSync()
        let current = annotations[name] ?? Annotation()

        let edited = try EditorLauncher.edit(current, name: name)

        if edited.isEmpty {
            print("Annotation for '\(name)' is empty (not saved).")
        } else {
            // Write directly to annotations file
            var all = annotations
            all[name] = edited
            let url = AnnotationStore.defaultURL
            let dir = url.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(all.filter { !$0.value.isEmpty })
            let tmp = dir.appendingPathComponent(".annotations.tmp.\(UUID().uuidString)")
            try data.write(to: tmp, options: .atomic)
            _ = try FileManager.default.replaceItemAt(url, withItemAt: tmp)
            print("Saved annotation for '\(name)'.")
        }
    }
}
