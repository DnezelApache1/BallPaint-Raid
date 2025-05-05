import Foundation
import SwiftUI

// Модель для хранения глобального состояния приложения
class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
} 