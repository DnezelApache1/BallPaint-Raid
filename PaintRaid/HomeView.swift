import SwiftUI

struct HomeView: View {
    var teams: [Team]
    @EnvironmentObject private var appState: AppState
    @State private var activeMatches: [Match] = []
    @State private var showingMatchCreation = false
    @State private var selectedActionCard: Int? = nil
    @State private var safeAreaTop: CGFloat = 47 // Значение по умолчанию
    @State private var safeAreaBottom: CGFloat = 34 // Значение по умолчанию
    
    var body: some View {
        ZStack(alignment: .top) {
            // Фиксированный фон для стабилизации
            Theme.darkBackground
                .ignoresSafeArea()
            
            // Всегда отображаем основной контент - без анимации появления
            mainContent
                // Фиксированное позиционирование для стабильности
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // Отключаем анимацию для основного контента
                .animation(nil, value: true)
        }
        .onChange(of: selectedActionCard) { oldValue, newValue in
            if let actionCard = newValue {
                handleQuickAction(actionCard)
            }
        }
        .onAppear {
            // Получаем корректные значения safe area
            DispatchQueue.main.async {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    safeAreaTop = window.safeAreaInsets.top
                    safeAreaBottom = window.safeAreaInsets.bottom
                }
            }
        }
    }
    
    // Основной контент
    private var mainContent: some View {
        GeometryReader { geo in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header с корректным отступом сверху
                    headerView
                        .padding(.top, max(safeAreaTop, 20))
                    
                    // Quick Actions
                    quickActionsGrid
                    
                    // Current Match or Recent Stats
                    if !activeMatches.isEmpty {
                        activeMatchCard
                    } else {
                        recentStatsView
                    }
                    
                    // Teams Preview
                    teamsPreview
                    
                    // Отступ снизу учитывает высоту таб-бара (70) и safe area
                    Spacer(minLength: 70 + safeAreaBottom + 20)
                }
                .padding(.horizontal)
            }
            .scrollDismissesKeyboard(.immediately)
            // Используем полный размер доступного пространства
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped() // Предотвращает выход за границы
        }
    }
    
    // Обработка действий Quick Actions
    private func handleQuickAction(_ actionIndex: Int) {
        DispatchQueue.main.async {
            switch actionIndex {
            case 0: // Matches
                appState.selectedTab = 3 // Переход на вкладку Matches
                print("Navigating to Matches")
            case 1: // Create Team
                appState.selectedTab = 2 // Переход на вкладку Team Setup
                print("Navigating to Team Setup")
            case 2: // Track Stats
                appState.selectedTab = 4 // Переход на вкладку Stats (индекс изменен из-за новой вкладки Matches)
                print("Navigating to Stats")
            case 3: // Open Map
                appState.selectedTab = 1 // Переход на вкладку Map
                print("Navigating to Arena Map")
            default:
                break
            }
        }
        
        // Сбрасываем выбор
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedActionCard = nil
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PaintRaid")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Your Paintball Command Center")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.lavender)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }
    
    // MARK: - Quick Actions Grid
    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(Theme.headlineFont)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                // Matches (раньше было Join Match)
                FeatureCard(
                    title: "Match",
                    icon: "flag.checkered.2.crossed",
                    description: "Manage games and results",
                    action: {
                        selectedActionCard = 0
                    }
                )
                
                // Create Team
                FeatureCard(
                    title: "Create Team",
                    icon: "person.3.fill",
                    description: "Add players and positions",
                    action: {
                        selectedActionCard = 1
                    }
                )
                
                // Track Stats
                FeatureCard(
                    title: "Track Stats",
                    icon: "chart.bar.fill",
                    description: "View performance metrics",
                    action: {
                        selectedActionCard = 2
                    }
                )
                
                // Open Map
                FeatureCard(
                    title: "Open Map",
                    icon: "map.fill",
                    description: "View tactical arena map",
                    action: {
                        selectedActionCard = 3
                    }
                )
            }
        }
    }
    
    // MARK: - Active Match Card
    private var activeMatchCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Active Match")
                .font(Theme.headlineFont)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Team Purple Reign vs Neon Strikers")
                        .font(Theme.headlineFont)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("In Progress")
                        .font(Theme.captionFont)
                        .padding(8)
                        .background(Color.green.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .foregroundColor(.green)
                }
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Location")
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.lavender)
                        
                        Text("Evergreen Arena")
                            .font(Theme.bodyFont)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Duration")
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.lavender)
                        
                        Text("24:15")
                            .font(Theme.bodyFont)
                            .foregroundColor(.white)
                    }
                }
                
                GlowButton(title: "Continue Match", icon: "arrow.right") {
                    // Action to continue match
                }
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Recent Stats View
    private var recentStatsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Performance")
                .font(Theme.headlineFont)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                HStack {
                    StatCircle(value: "4.2", label: "K/D Ratio", color: Theme.deepPurple)
                    
                    Spacer()
                    
                    StatCircle(value: "76%", label: "Win Rate", color: Theme.midPurple)
                    
                    Spacer()
                    
                    StatCircle(value: "12", label: "Matches", color: Theme.lightPurple)
                }
                .frame(height: 90) // Фиксированная высота для кружков статистики
                
                StatsBar(
                    value: 4.2,
                    maxValue: 5.0,
                    color: Theme.deepPurple,
                    icon: "target",
                    title: "Kill/Death Ratio"
                )
                .frame(height: 45) // Фиксированная высота для индикатора
                
                StatsBar(
                    value: 76,
                    maxValue: 100,
                    color: Theme.midPurple,
                    icon: "trophy",
                    title: "Win Rate %"
                )
                .frame(height: 45) // Фиксированная высота для индикатора
            }
            .padding()
            .frame(height: 230) // Общая фиксированная высота контейнера
            .background(Color.black.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Teams Preview
    private var teamsPreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Teams")
                .font(Theme.headlineFont)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(teams) { team in
                    HStack {
                        Circle()
                            .fill(team.color)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: team.iconName)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(team.name)
                                .font(Theme.headlineFont)
                                .foregroundColor(.white)
                            
                            Text("\(team.players.count) Players")
                                .font(Theme.captionFont)
                                .foregroundColor(Theme.lavender)
                        }
                        .padding(.leading, 8)
                        
                        Spacer()
                        
                        Button(action: {
                            // View team details
                        }) {
                            Text("View")
                                .font(Theme.bodyFont)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(team.color.opacity(0.3))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(team.color, lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                    .frame(height: 75) // Фиксированная высота карточки команды
                    .background(Color.black.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                
                GlowButton(title: "Create New Team", icon: "plus") {
                    // Action to create new team
                    appState.selectedTab = 2 // Переход на вкладку Team Setup
                    print("Navigating to Team Setup")
                }
                .frame(height: 60) // Фиксированная высота кнопки
            }
        }
    }
}

// MARK: - Stat Circle Component
struct StatCircle: View {
    var value: String
    var label: String
    var color: Color
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 8)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(label)
                .font(Theme.captionFont)
                .foregroundColor(Theme.lavender)
                .padding(.top, 4)
        }
    }
}

#Preview {
    ZStack {
        Theme.darkBackground
            .ignoresSafeArea()
        
        HomeView(teams: SampleData.generateTeams())
            .environmentObject(AppState())
    }
} 
