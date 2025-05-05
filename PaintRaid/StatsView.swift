import SwiftUI

struct StatsView: View {
    var teams: [Team]
    @State private var selectedSegment = 0
    @State private var selectedTimeFrame = 2 // All time
    @State private var selectedTeamId: UUID?
    @State private var isChartExpanded = false
    
    private let segments = ["Players", "Teams"]
    private let timeFrames = ["Week", "Month", "All Time"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerView
                
                // Segmented Control
                segmentedControlView
                
                // Filter Bar
                filterBarView
                
                // Content based on selected segment
                if selectedSegment == 0 {
                    playerStatsView
                } else {
                    teamStatsView
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 100) // Give space for the AI button
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Statistics")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Track your performance and progress")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.lavender)
        }
    }
    
    // MARK: - Segmented Control
    private var segmentedControlView: some View {
        HStack(spacing: 0) {
            ForEach(0..<segments.count, id: \.self) { index in
                Button(action: {
                    withAnimation {
                        selectedSegment = index
                    }
                }) {
                    Text(segments[index])
                        .font(Theme.bodyFont)
                        .foregroundColor(selectedSegment == index ? .white : .white.opacity(0.6))
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedSegment == index ?
                            Theme.primaryGradient
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                                .shadow(color: Theme.deepPurple.opacity(0.5), radius: 8, x: 0, y: 0)
                            : nil
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .fill(Color.black.opacity(0.2))
        )
    }
    
    // MARK: - Filter Bar
    private var filterBarView: some View {
        VStack(spacing: 16) {
            // Time frame selector
            HStack {
                Text("Time Frame:")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.lavender)
                
                Spacer()
                
                HStack(spacing: 0) {
                    ForEach(0..<timeFrames.count, id: \.self) { index in
                        Button(action: {
                            withAnimation {
                                selectedTimeFrame = index
                            }
                        }) {
                            Text(timeFrames[index])
                                .font(Theme.captionFont)
                                .foregroundColor(selectedTimeFrame == index ? .white : .white.opacity(0.6))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    selectedTimeFrame == index ?
                                    Capsule()
                                        .fill(Theme.deepPurple)
                                    : nil
                                )
                        }
                    }
                }
                .padding(3)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.2))
                )
            }
            
            // Team selector
            if selectedSegment == 0 && teams.count > 1 {
                HStack {
                    Text("Team:")
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.lavender)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation {
                                selectedTeamId = nil
                            }
                        }) {
                            Text("All Teams")
                                .font(Theme.captionFont)
                                .foregroundColor(selectedTeamId == nil ? .white : .white.opacity(0.6))
                                .padding(.vertical,
                                         6)
                                .padding(.horizontal, 12)
                                .background(
                                    selectedTeamId == nil ?
                                    Capsule()
                                        .fill(Theme.deepPurple)
                                    : nil
                                )
                        }
                        
                        ForEach(teams) { team in
                            Button(action: {
                                withAnimation {
                                    selectedTeamId = team.id
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(team.color)
                                        .frame(width: 8, height: 8)
                                    
                                    Text(team.name)
                                        .font(Theme.captionFont)
                                        .foregroundColor(selectedTeamId == team.id ? .white : .white.opacity(0.6))
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    selectedTeamId == team.id ?
                                    Capsule()
                                        .fill(team.color.opacity(0.3))
                                    : nil
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Player Stats View
    private var playerStatsView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Top performers
            topPerformersView
            
            // Performance Chart
            performanceChartView
            
            // Player List
            playerListView
        }
    }
    
    // MARK: - Top Performers View
    private var topPerformersView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Performers")
                .font(Theme.headlineFont)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    topPerformerCard(
                        title: "Most Eliminations",
                        name: "Jordan Smith",
                        value: "56",
                        icon: "target",
                        color: .red
                    )
                    
                    topPerformerCard(
                        title: "Best K/D Ratio",
                        name: "Alex Johnson",
                        value: "3.5",
                        icon: "arrow.up.arrow.down",
                        color: Theme.deepPurple
                    )
                    
                    topPerformerCard(
                        title: "Most Assists",
                        name: "Taylor Wong",
                        value: "36",
                        icon: "arrow.up.heart",
                        color: .green
                    )
                    
                    topPerformerCard(
                        title: "Most Captures",
                        name: "Sam Rivera",
                        value: "12",
                        icon: "flag.fill",
                        color: .blue
                    )
                }
            }
        }
    }
    
    private func topPerformerCard(title: String, name: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(Theme.bodyFont)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(name)
                .font(Theme.captionFont)
                .foregroundColor(Theme.lavender)
        }
        .padding()
        .frame(width: 200, height: 140)
        .background(Color.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Performance Chart View
    private var performanceChartView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Performance Chart")
                    .font(Theme.headlineFont)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isChartExpanded.toggle()
                    }
                }) {
                    Image(systemName: isChartExpanded ? "minus" : "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
            }
            
            // Chart would go here
            barChartView
                .frame(height: isChartExpanded ? 300 : 200)
                .background(Color.black.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        }
    }
    
    // A simple bar chart representation
    private var barChartView: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(0..<10) { i in
                let height = CGFloat([0.4, 0.6, 0.5, 0.8, 0.9, 0.7, 1.0, 0.8, 0.6, 0.9][i])
                
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Theme.deepPurple, Theme.lightPurple]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: 180 * height)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    
                    Text("M\(i+1)")
                        .font(Theme.captionFont)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding()
    }
    
    // MARK: - Player List View
    private var playerListView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Player Rankings")
                .font(Theme.headlineFont)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                let filteredPlayers = getFilteredPlayers()
                ForEach(Array(filteredPlayers.enumerated()), id: \.element.id) { index, player in
                    playerRankCard(player: player, rank: index + 1)
                }
            }
        }
    }
    
    private func getFilteredPlayers() -> [Player] {
        var allPlayers: [Player] = []
        
        if let teamId = selectedTeamId {
            if let team = teams.first(where: { $0.id == teamId }) {
                allPlayers = team.players
            }
        } else {
            teams.forEach { team in
                allPlayers.append(contentsOf: team.players)
            }
        }
        
        // Sort by eliminations for now
        return allPlayers.sorted { $0.stats.eliminations > $1.stats.eliminations }
    }
    
    private func playerRankCard(player: Player, rank: Int) -> some View {
        HStack {
            Text("#\(rank)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(rank <= 3 ? [.yellow, .gray, .orange][rank-1] : .white.opacity(0.7))
                .frame(width: 40)
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Theme.primaryGradient)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: player.avatar)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.nickname)
                        .font(Theme.headlineFont)
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: player.role.icon)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Theme.lavender)
                        
                        Text(player.role.rawValue)
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.lavender)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(player.stats.eliminations) elim")
                        .font(Theme.bodyFont)
                        .foregroundColor(.white)
                    
                    Text("K/D: \(String(format: "%.1f", player.stats.kdRatio))")
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.lavender)
                }
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        }
    }
    
    // MARK: - Team Stats View
    private var teamStatsView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Team performance
            VStack(alignment: .leading, spacing: 16) {
                Text("Team Performance")
                    .font(Theme.headlineFont)
                    .foregroundColor(.white)
                
                ForEach(teams) { team in
                    teamPerformanceCard(team: team)
                }
            }
            
            // Win/Loss ratio chart
            VStack(alignment: .leading, spacing: 16) {
                Text("Win/Loss Ratio")
                    .font(Theme.headlineFont)
                    .foregroundColor(.white)
                
                // A simple placeholder for a chart
                HStack(spacing: 0) {
                    ForEach(teams) { team in
                        let winRate = Double.random(in: 0.5...0.9) // Placeholder value
                        
                        VStack {
                            pieChartView(winRate: winRate, color: team.color)
                                .frame(width: 120, height: 120)
                                .padding()
                            
                            Text(team.name)
                                .font(Theme.captionFont)
                                .foregroundColor(.white)
                                .padding(.bottom, 8)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .background(Color.black.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            }
            
            // Match history
            VStack(alignment: .leading, spacing: 16) {
                Text("Recent Matches")
                    .font(Theme.headlineFont)
                    .foregroundColor(.white)
                
                // Placeholder for match history
                ForEach(0..<3) { i in
                    matchHistoryCard(index: i)
                }
            }
        }
    }
    
    private func teamPerformanceCard(team: Team) -> some View {
        VStack(spacing: 16) {
            HStack {
                Circle()
                    .fill(team.color)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Image(systemName: team.iconName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                Text(team.name)
                    .font(Theme.headlineFont)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(team.players.count) Players")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.lavender)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Capsule())
            }
            
            // Performance metrics
            HStack(spacing: 20) {
                performanceMetric(value: "\(team.players.reduce(0) { $0 + $1.stats.eliminations })", label: "Eliminations", icon: "target", color: .red)
                
                performanceMetric(value: "\(team.players.reduce(0) { $0 + $1.stats.objectiveCaptures })", label: "Captures", icon: "flag.fill", color: .blue)
                
                performanceMetric(value: "78%", label: "Win Rate", icon: "trophy", color: .yellow)
            }
            
            // Best player
            if let bestPlayer = team.players.max(by: { $0.stats.eliminations < $1.stats.eliminations }) {
                HStack {
                    Text("MVP:")
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.lavender)
                    
                    Text(bestPlayer.nickname)
                        .font(Theme.bodyFont)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(bestPlayer.stats.eliminations) Elim")
                        .font(Theme.bodyFont)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(team.color.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .stroke(team.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func performanceMetric(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
                
                Text(label)
                    .font(Theme.captionFont)
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func pieChartView(winRate: Double, color: Color) -> some View {
        ZStack {
            Circle()
                .stroke(Color.black.opacity(0.3), lineWidth: 15)
            
            Circle()
                .trim(from: 0, to: CGFloat(winRate))
                .stroke(color, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 4) {
                Text("\(Int(winRate * 100))%")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Win Rate")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.lavender)
            }
        }
    }
    
    private func matchHistoryCard(index: Int) -> some View {
        let outcomes = ["Victory", "Defeat", "Victory"]
        let dates = ["Yesterday", "3 days ago", "Last week"]
        let teams = ["Purple Reign vs Neon Strikers", "Purple Reign vs Fire Squad", "Neon Strikers vs Phantom Force"]
        let scores = ["5-3", "2-5", "7-1"]
        
        return HStack {
            Circle()
                .fill(outcomes[index] == "Victory" ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(teams[index])
                    .font(Theme.bodyFont)
                    .foregroundColor(.white)
                
                Text(dates[index])
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.lavender)
            }
            
            Spacer()
            
            Text(scores[index])
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(outcomes[index])
                .font(Theme.captionFont)
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .background(outcomes[index] == "Victory" ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                .foregroundColor(outcomes[index] == "Victory" ? .green : .red)
                .clipShape(Capsule())
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }
}

#Preview {
    ZStack {
        Theme.darkBackground
            .ignoresSafeArea()
        
        StatsView(teams: SampleData.generateTeams())
    }
} 