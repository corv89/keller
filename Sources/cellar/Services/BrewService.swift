import Foundation

enum BrewError: Error, LocalizedError {
    case notInstalled
    case commandFailed(stderr: String)
    case decodeFailed(Error)

    var errorDescription: String? {
        switch self {
        case .notInstalled:
            "Homebrew is not installed. Install it from https://brew.sh"
        case .commandFailed(let stderr):
            "brew command failed: \(stderr)"
        case .decodeFailed(let error):
            "Failed to decode brew output: \(error.localizedDescription)"
        }
    }
}

struct BrewService: Sendable {
    func brewPath() throws -> String {
        if let env = ProcessInfo.processInfo.environment["HOMEBREW_PREFIX"] {
            let candidate = URL(fileURLWithPath: env).appendingPathComponent("bin/brew").path
            if FileManager.default.fileExists(atPath: candidate) {
                return candidate
            }
        }

        let candidates = [
            "/opt/homebrew/bin/brew",
            "/usr/local/bin/brew",
        ]
        for path in candidates {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        throw BrewError.notInstalled
    }

    func fetchInstalledFormulae() async throws -> [Formula] {
        let brew = try brewPath()
        let process = Process()
        let stdout = Pipe()
        let stderrPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: brew)
        process.arguments = ["info", "--json=v2", "--installed"]
        process.standardOutput = stdout
        process.standardError = stderrPipe

        try process.run()

        let stdoutData: Data? = await Task.detached {
            try? stdout.fileHandleForReading.readToEnd()
        }.value

        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let errData = try? stderrPipe.fileHandleForReading.readToEnd()
            let errMsg = errData.flatMap { String(data: $0, encoding: .utf8) } ?? "unknown error"
            throw BrewError.commandFailed(stderr: errMsg)
        }

        guard let data = stdoutData else {
            throw BrewError.commandFailed(stderr: "no output from brew")
        }

        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(BrewInfoResponse.self, from: data)
            return response.formulae.map { $0.toFormula() }
        } catch {
            throw BrewError.decodeFailed(error)
        }
    }
}
