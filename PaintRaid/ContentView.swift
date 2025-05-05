import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var showAIAssistant = false
    @State private var teams: [Team] = []
    @State private var hasAppeared = false
    
    // Load teams on app launch
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Background
                    Theme.darkBackground
                        .ignoresSafeArea()
                    
                    // Main Content
                    VStack(spacing: 0) {
                        // Content based on selected tab - Using ZStack to avoid sliding animation
                        ZStack {
                            HomeView(teams: teams)
                                .opacity(appState.selectedTab == 0 ? 1 : 0)
                                .allowsHitTesting(appState.selectedTab == 0)
                            
                            ArenaMapView()
                                .opacity(appState.selectedTab == 1 ? 1 : 0)
                                .allowsHitTesting(appState.selectedTab == 1)
                            
                            TeamSetupView(teams: $teams)
                                .opacity(appState.selectedTab == 2 ? 1 : 0)
                                .allowsHitTesting(appState.selectedTab == 2)
                            
                            MatchesView(teams: $teams)
                                .opacity(appState.selectedTab == 3 ? 1 : 0)
                                .allowsHitTesting(appState.selectedTab == 3)
                            
                            StatsView(teams: teams)
                                .opacity(appState.selectedTab == 4 ? 1 : 0)
                                .allowsHitTesting(appState.selectedTab == 4)
                            
                            AIAssistantView(isVisible: $showAIAssistant)
                                .opacity(appState.selectedTab == 5 ? 1 : 0)
                                .allowsHitTesting(appState.selectedTab == 5)
                        }
                        .animation(hasAppeared ? .easeInOut : .none, value: appState.selectedTab)
                        
                        // Tab Bar - фиксированная позиция внизу
                        HStack {
                            TabButton(
                                title: "Home",
                                icon: "house.fill",
                                isSelected: appState.selectedTab == 0
                            ) {
                                withAnimation(hasAppeared ? .easeInOut : .none) {
                                    appState.selectedTab = 0
                                }
                            }
                            
                            TabButton(
                                title: "Map",
                                icon: "map.fill",
                                isSelected: appState.selectedTab == 1
                            ) {
                                withAnimation(hasAppeared ? .easeInOut : .none) {
                                    appState.selectedTab = 1
                                }
                            }
                            
                            TabButton(
                                title: "Teams",
                                icon: "person.3.fill",
                                isSelected: appState.selectedTab == 2
                            ) {
                                withAnimation(hasAppeared ? .easeInOut : .none) {
                                    appState.selectedTab = 2
                                }
                            }
                            
                            TabButton(
                                title: "Matches",
                                icon: "flag.checkered.2.crossed",
                                isSelected: appState.selectedTab == 3
                            ) {
                                withAnimation(hasAppeared ? .easeInOut : .none) {
                                    appState.selectedTab = 3
                                }
                            }
                            
                            TabButton(
                                title: "Stats",
                                icon: "chart.bar.fill",
                                isSelected: appState.selectedTab == 4
                            ) {
                                withAnimation(hasAppeared ? .easeInOut : .none) {
                                    appState.selectedTab = 4
                                }
                            }
                            
                            TabButton(
                                title: "AI",
                                icon: "brain.head.profile",
                                isSelected: appState.selectedTab == 5
                            ) {
                                withAnimation(hasAppeared ? .easeInOut : .none) {
                                    appState.selectedTab = 5
                                    showAIAssistant = true
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(
                            Rectangle()
                                .fill(Color.black.opacity(0.5))
                                .ignoresSafeArea()
                        )
                    }
                }
                .environmentObject(appState)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onAppear {
                loadTeams()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    hasAppeared = true
                }
            }
            .onChange(of: teams) { oldValue, newValue in
                saveTeams()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Data Persistence
    private func loadTeams() {
        if let savedTeams = UserDefaults.standard.data(forKey: "savedTeams") {
            if let decodedTeams = try? JSONDecoder().decode([Team].self, from: savedTeams) {
                teams = decodedTeams
                print("Loaded \(teams.count) teams from UserDefaults")
                return
            }
        }
        
        // If no saved teams or failed to decode, use sample data
        teams = SampleData.generateTeams()
        print("Using sample data: \(teams.count) teams")
    }
    
    private func saveTeams() {
        if let encoded = try? JSONEncoder().encode(teams) {
            UserDefaults.standard.set(encoded, forKey: "savedTeams")
            print("Saved \(teams.count) teams to UserDefaults")
        }
    }
}

#Preview {
    ContentView()
} 