import Foundation
import Testing
@testable import keller

@Suite("BrewJSON Decoding")
struct BrewJSONDecodingTests {
    private func loadFixture() throws -> Data {
        let url = Bundle.module.url(forResource: "installed", withExtension: "json", subdirectory: "Fixtures")!
        return try Data(contentsOf: url)
    }

    @Test("Decodes brew JSON response")
    func testDecodeResponse() throws {
        let data = try loadFixture()
        let response = try JSONDecoder().decode(BrewInfoResponse.self, from: data)

        #expect(response.formulae.count == 3)
        #expect(response.formulae[0].name == "abseil")
        #expect(response.formulae[1].name == "action-validator")
    }

    @Test("Decodes installed version and installedOnRequest")
    func testInstalledFields() throws {
        let data = try loadFixture()
        let response = try JSONDecoder().decode(BrewInfoResponse.self, from: data)

        let abseil = response.formulae[0]
        #expect(abseil.installed.count == 1)
        #expect(abseil.installed[0].version == "20260107.1")
        #expect(abseil.installed[0].installedOnRequest == false)

        let actionValidator = response.formulae[1]
        #expect(actionValidator.installed[0].installedOnRequest == true)
    }

    @Test("Converts BrewFormula to Formula correctly")
    func testToFormula() throws {
        let data = try loadFixture()
        let response = try JSONDecoder().decode(BrewInfoResponse.self, from: data)

        let formula = response.formulae[1].toFormula()
        #expect(formula.name == "action-validator")
        #expect(formula.desc == "Tool to validate GitHub Action and Workflow YAML files")
        #expect(formula.installedVersion == "0.9.0")
        #expect(formula.installedOnRequest == true)
        #expect(formula.deprecated == false)
        #expect(formula.disabled == false)
        #expect(formula.outdated == false)
    }

    @Test("Handles formula with dependencies")
    func testDependencies() throws {
        let data = try loadFixture()
        let response = try JSONDecoder().decode(BrewInfoResponse.self, from: data)

        let ada = response.formulae[2]
        #expect(ada.dependencies == ["fmt"])
        let formula = ada.toFormula()
        #expect(formula.dependencies == ["fmt"])
    }
}

@Suite("AnnotationStore")
struct AnnotationStoreTests {
    private func makeTempStore() throws -> (AnnotationStore, URL) {
        let tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("keller-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        let url = tmpDir.appendingPathComponent("annotations.json")
        let store = AnnotationStore(url: url)
        return (store, url)
    }

    private func cleanup(_ url: URL) {
        try? FileManager.default.removeItem(at: url.deletingLastPathComponent())
    }

    @Test("Loads empty when no file exists")
    func testLoadEmpty() async throws {
        let (store, url) = try makeTempStore()
        defer { cleanup(url) }

        let loaded = try await store.load()
        #expect(loaded.isEmpty)
    }

    @Test("Round-trips an annotation")
    func testRoundTrip() async throws {
        let (store, url) = try makeTempStore()
        defer { cleanup(url) }

        let annotation = Annotation(notes: "my notes", tags: ["cli", "network"], examples: ["curl -s https://example.com"])
        try await store.save(annotation, for: "curl")

        let loaded = try await store.load()
        #expect(loaded["curl"] == annotation)
    }

    @Test("Prunes empty annotations on save")
    func testPruneEmpty() async throws {
        let (store, url) = try makeTempStore()
        defer { cleanup(url) }

        try await store.save(Annotation(notes: "keep me"), for: "keep")
        try await store.save(Annotation(), for: "empty")

        let loaded = try await store.load()
        #expect(loaded["keep"] != nil)
        #expect(loaded["empty"] == nil)
    }

    @Test("Removes an annotation")
    func testRemove() async throws {
        let (store, url) = try makeTempStore()
        defer { cleanup(url) }

        try await store.save(Annotation(notes: "bye"), for: "remove-me")
        try await store.remove(for: "remove-me")

        let loaded = try await store.load()
        #expect(loaded["remove-me"] == nil)
    }

    @Test("Returns empty annotation for missing name")
    func testMissingAnnotation() async throws {
        let (store, url) = try makeTempStore()
        defer { cleanup(url) }

        let ann = try await store.annotation(for: "nonexistent")
        #expect(ann == Annotation())
    }
}

@Suite("CacheManager")
struct CacheManagerTests {
    private func makeManager() -> CacheManager {
        let tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("keller-cache-test-\(UUID().uuidString)")
        return CacheManager(directory: tmpDir)
    }

    private func cleanup(_ manager: CacheManager) {
        try? FileManager.default.removeItem(at: manager.directory)
    }

    @Test("Returns nil when no cache exists")
    func testNoCache() {
        let manager = makeManager()
        defer { cleanup(manager) }
        #expect(manager.loadIfFresh() == nil)
    }

    @Test("Round-trips formulae through cache")
    func testCacheRoundTrip() throws {
        let manager = makeManager()
        defer { cleanup(manager) }

        let formulae = [
            Formula(name: "git", desc: "DVCS", homepage: "https://git-scm.com",
                    installedVersion: "2.40.0", installedOnRequest: true,
                    dependencies: [], caveats: nil, deprecated: false,
                    disabled: false, outdated: false),
        ]
        try manager.write(formulae)

        let loaded = manager.loadIfFresh()
        #expect(loaded?.count == 1)
        #expect(loaded?.first?.name == "git")
    }

    @Test("Invalidates cache")
    func testInvalidate() throws {
        let manager = makeManager()
        defer { cleanup(manager) }

        let formulae = [
            Formula(name: "git", desc: nil, homepage: nil,
                    installedVersion: nil, installedOnRequest: true,
                    dependencies: [], caveats: nil, deprecated: false,
                    disabled: false, outdated: false),
        ]
        try manager.write(formulae)
        #expect(manager.loadIfFresh() != nil)

        try manager.invalidate()
        #expect(manager.loadIfFresh() == nil)
    }
}

@Suite("EditorLauncher")
struct EditorLauncherTests {
    @Test("Builds template with front-matter")
    func testBuildTemplate() {
        let annotation = Annotation(
            notes: "my notes",
            tags: ["cli", "network"],
            examples: ["curl -s https://example.com"]
        )
        let template = EditorLauncher.buildTemplate(name: "curl", annotation: annotation)

        #expect(template.contains("tags: [cli, network]"))
        #expect(template.contains("my notes"))
        #expect(template.contains("curl -s https://example.com"))
    }

    @Test("Parses template back to annotation")
    func testParseTemplate() {
        let content = """
        ---
        tags: [cli, network]
        examples:
          - "curl -s https://example.com"
        ---

        My notes about curl
        """
        let annotation = EditorLauncher.parseTemplate(content, fallback: Annotation())

        #expect(annotation.tags == ["cli", "network"])
        #expect(annotation.examples == ["curl -s https://example.com"])
        #expect(annotation.notes == "My notes about curl")
    }

    @Test("Handles empty annotation template")
    func testParseEmptyTemplate() {
        let content = """
        ---
        tags: []
        examples:
        ---

        """
        let annotation = EditorLauncher.parseTemplate(content, fallback: Annotation())

        #expect(annotation.tags.isEmpty)
        #expect(annotation.examples.isEmpty)
        #expect(annotation.notes.isEmpty)
    }
}
