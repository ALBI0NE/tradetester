import Foundation
import Network

class FocusTimer: ObservableObject {
    @Published var timeRemaining: TimeInterval
    @Published var isActive = false
    private var timer: Timer?
    private let networkManager: NetworkManager

    init(duration: TimeInterval = 25 * 60, networkManager: NetworkManager = .shared) {
        self.timeRemaining = duration
        self.networkManager = networkManager
    }

    func start() {
        isActive = true
        networkManager.toggleBlocking()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stop()
            }
        }
    }

    func stop() {
        isActive = false
        timer?.invalidate()
        timer = nil
        timeRemaining = 25 * 60
        networkManager.toggleBlocking()
    }

    deinit {
        timer?.invalidate()
    }
}
