import SwiftUI

struct MatchesView: View {
    @Binding var teams: [Team]
    @State private var matches: [Match] = []
    @State private var showingAddMatch = false
    @State private var selectedFilter: MatchFilter = .all
    @State private var selectedMatch: Match?
    @State private var showMatchDetails = false
    
    enum MatchFilter: String, CaseIterable {
        case all = "All"
        case scheduled = "Scheduled"
        case inProgress = "In Progress"
        case completed = "Completed"
        case cancelled = "Cancelled"
        
        var statusFilter: Match.MatchStatus? {
            switch self {
            case .all: return nil
            case .scheduled: return .scheduled
            case .inProgress: return .inProgress
            case .completed: return .completed
            case .cancelled: return .cancelled
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerView
                
                // Filter Tabs
                filterTabsView
                
                // Matches List
                matchesListView
                
                // Empty State
                if filteredMatches.isEmpty {
                    emptyStateView
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 100)
        }
        .background(Theme.darkBackground.ignoresSafeArea())
        .sheet(isPresented: $showingAddMatch) {
            AddMatchView(teams: teams, onSave: { newMatch in
                matches.append(newMatch)
                saveMatches()
            })
        }
        .sheet(isPresented: $showMatchDetails) {
            if let match = selectedMatch {
                MatchDetailView(match: match, onUpdate: { updatedMatch in
                    if let index = matches.firstIndex(where: { $0.id == updatedMatch.id }) {
                        matches[index] = updatedMatch
                        saveMatches()
                    }
                })
            }
        }
        .onAppear {
            loadMatches()
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredMatches: [Match] {
        guard selectedFilter != .all else { return matches.sorted(by: { $0.date > $1.date }) }
        
        return matches
            .filter { selectedFilter.statusFilter == $0.status }
            .sorted(by: { $0.date > $1.date })
    }
    
    // MARK: - UI Components
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Matches")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Manage your games and track results")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.lavender)
        }
    }
    
    private var filterTabsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(MatchFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        withAnimation {
                            selectedFilter = filter
                        }
                    }) {
                        Text(filter.rawValue)
                            .font(Theme.bodyFont)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                selectedFilter == filter ?
                                    (filter.statusFilter?.color ?? Theme.deepPurple).opacity(0.8) :
                                    Color.black.opacity(0.3)
                            )
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(
                                        selectedFilter == filter ?
                                            (filter.statusFilter?.color ?? Theme.deepPurple) :
                                            Color.white.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var matchesListView: some View {
        VStack(spacing: 16) {
            ForEach(filteredMatches) { match in
                MatchCardView(match: match)
                    .onTapGesture {
                        selectedMatch = match
                        showMatchDetails = true
                    }
            }
            
            // Add Match Button
            GlowButton(title: "Add New Match", icon: "plus") {
                showingAddMatch = true
            }
            .padding(.top, 8)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "flag.checkered")
                .font(.system(size: 70))
                .foregroundColor(Theme.lightPurple.opacity(0.6))
            
            Text("No matches found")
                .font(Theme.headlineFont)
                .foregroundColor(.white)
            
            Text("Create your first match to start tracking results")
                .font(Theme.bodyFont)
                .foregroundColor(Theme.lavender)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            GlowButton(title: "Create Match", icon: "plus") {
                showingAddMatch = true
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(minHeight: 400)
    }
    
    // MARK: - Data Management
    
    private func loadMatches() {
        if let savedMatches = UserDefaults.standard.data(forKey: "savedMatches") {
            if let decodedMatches = try? JSONDecoder().decode([Match].self, from: savedMatches) {
                matches = decodedMatches
                print("Loaded \(matches.count) matches from UserDefaults")
                return
            }
        }
        
        // If no saved matches or failed to decode, use sample data
        matches = SampleData.generateMatches()
        print("Using sample data: \(matches.count) matches")
    }
    
    private func saveMatches() {
        if let encoded = try? JSONEncoder().encode(matches) {
            UserDefaults.standard.set(encoded, forKey: "savedMatches")
            print("Saved \(matches.count) matches to UserDefaults")
        } else {
            print("Failed to encode matches for saving")
        }
    }
}

// MARK: - Match Card View
struct MatchCardView: View {
    var match: Match
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0m"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Status & Date
            HStack {
                Text(match.status.rawValue)
                    .font(Theme.captionFont)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(match.status.color.opacity(0.3))
                    .clipShape(Capsule())
                
                Spacer()
                
                Text(dateFormatter.string(from: match.date))
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.lavender)
            }
            
            // Teams and Score
            HStack(alignment: .center, spacing: 16) {
                ForEach(match.teams) { team in
                    VStack(spacing: 8) {
                        // Team Icon & Name
                        HStack {
                            Circle()
                                .fill(team.color)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: team.iconName)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            
                            Text(team.name)
                                .font(Theme.bodyFont)
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        
                        // Score
                        Text("\(match.score[team.id] ?? 0)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(team.id == match.winner ? team.color : .white)
                    }
                    
                    if team.id != match.teams.last?.id {
                        Text("vs")
                            .font(Theme.headlineFont)
                            .foregroundColor(Theme.lavender)
                    }
                }
            }
            .padding(.vertical, 8)
            
            // Footer: Location & Duration
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(Theme.lavender)
                    
                    Text(match.location)
                        .font(Theme.captionFont)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if match.duration > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(Theme.lavender)
                        
                        Text(formatDuration(match.duration))
                            .font(Theme.captionFont)
                            .foregroundColor(.white)
                    }
                }
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

// MARK: - Add Match View

struct AddMatchView: View {
    var teams: [Team]
    var onSave: (Match) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTeams: [UUID] = []
    @State private var matchDate = Date()
    @State private var location = ""
    @State private var status: Match.MatchStatus = .scheduled
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Teams")) {
                    List {
                        ForEach(teams) { team in
                            Button(action: {
                                toggleTeamSelection(team.id)
                            }) {
                                HStack {
                                    Circle()
                                        .fill(team.color)
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Image(systemName: team.iconName)
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                    
                                    Text(team.name)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if selectedTeams.contains(team.id) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                    
                    if selectedTeams.count < 2 {
                        Text("Select at least 2 teams")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("Match Details")) {
                    DatePicker("Date & Time", selection: $matchDate)
                    
                    TextField("Location", text: $location)
                    
                    Picker("Status", selection: $status) {
                        ForEach(Match.MatchStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
            }
            .navigationBarTitle("New Match", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveMatch()
                }
                .disabled(selectedTeams.count < 2 || location.isEmpty)
            )
        }
    }
    
    private func toggleTeamSelection(_ teamId: UUID) {
        if selectedTeams.contains(teamId) {
            selectedTeams.removeAll { $0 == teamId }
        } else {
            // Limit to 2 teams maximum
            if selectedTeams.count < 2 {
                selectedTeams.append(teamId)
            }
        }
    }
    
    private func saveMatch() {
        guard selectedTeams.count >= 2 && !location.isEmpty else { return }
        
        // Get the selected teams from the main list
        let matchTeams = teams.filter { selectedTeams.contains($0.id) }
        
        // Create initial score dictionary
        var initialScore: [UUID: Int] = [:]
        for team in matchTeams {
            initialScore[team.id] = 0
        }
        
        // Create the new match
        let newMatch = Match(
            date: matchDate,
            teams: matchTeams,
            location: location,
            status: status,
            score: initialScore
        )
        
        // Notify parent view
        onSave(newMatch)
        
        // Dismiss the sheet
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Match Detail View
struct MatchDetailView: View {
    var match: Match
    var onUpdate: (Match) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var matchCopy: Match
    @State private var isEditing = false
    
    init(match: Match, onUpdate: @escaping (Match) -> Void) {
        self.match = match
        self.onUpdate = onUpdate
        self._matchCopy = State(initialValue: match)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        return formatter.string(from: duration) ?? "0 minutes"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header: Match Status & Date
                    HStack {
                        if isEditing {
                            Picker("Status", selection: $matchCopy.status) {
                                ForEach(Match.MatchStatus.allCases, id: \.self) { status in
                                    Text(status.rawValue).tag(status)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: 150)
                        } else {
                            Text(match.status.rawValue)
                                .font(Theme.headlineFont)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(match.status.color.opacity(0.3))
                                .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        if isEditing {
                            DatePicker("", selection: $matchCopy.date)
                                .labelsHidden()
                        } else {
                            Text(dateFormatter.string(from: match.date))
                                .font(Theme.bodyFont)
                                .foregroundColor(Theme.lavender)
                        }
                    }
                    
                    // Match Teams & Score
                    VStack(spacing: 20) {
                        ForEach(match.teams) { team in
                            HStack {
                                // Team Info
                                HStack {
                                    Circle()
                                        .fill(team.color)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: team.iconName)
                                                .font(.system(size: 16, weight: .bold))
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
                                }
                                
                                Spacer()
                                
                                // Score
                                if isEditing {
                                    Stepper(
                                        value: Binding(
                                            get: { matchCopy.score[team.id] ?? 0 },
                                            set: { matchCopy.score[team.id] = $0 }
                                        ),
                                        in: 0...100
                                    ) {
                                        Text("\(matchCopy.score[team.id] ?? 0)")
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .frame(minWidth: 40)
                                    }
                                } else {
                                    Text("\(match.score[team.id] ?? 0)")
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundColor(team.id == match.winner ? team.color : .white)
                                        .frame(minWidth: 50)
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                                    .stroke(team.id == match.winner ? team.color.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                    
                    // Match Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Match Details")
                            .font(Theme.headlineFont)
                            .foregroundColor(.white)
                        
                        // Location
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Theme.lavender)
                            
                            if isEditing {
                                TextField("Location", text: $matchCopy.location)
                                    .foregroundColor(.white)
                            } else {
                                Text(match.location)
                                    .font(Theme.bodyFont)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Duration
                        HStack {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Theme.lavender)
                            
                            if isEditing {
                                Picker("Duration", selection: $matchCopy.duration) {
                                    Text("30 minutes").tag(TimeInterval(1800))
                                    Text("1 hour").tag(TimeInterval(3600))
                                    Text("1.5 hours").tag(TimeInterval(5400))
                                    Text("2 hours").tag(TimeInterval(7200))
                                    Text("2.5 hours").tag(TimeInterval(9000))
                                    Text("3 hours").tag(TimeInterval(10800))
                                }
                                .pickerStyle(MenuPickerStyle())
                            } else {
                                Text(formatDuration(match.duration))
                                    .font(Theme.bodyFont)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Winner (only for completed matches)
                        if match.status == .completed {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Theme.lavender)
                                
                                if isEditing {
                                    Picker("Winner", selection: $matchCopy.winner) {
                                        Text("No Winner").tag(nil as UUID?)
                                        ForEach(match.teams) { team in
                                            Text(team.name).tag(team.id as UUID?)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                } else if let winner = match.winner, let winnerTeam = match.teams.first(where: { $0.id == winner }) {
                                    Text("\(winnerTeam.name) won the match")
                                        .font(Theme.bodyFont)
                                        .foregroundColor(.white)
                                } else {
                                    Text("No winner declared")
                                        .font(Theme.bodyFont)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    
                    // Action Buttons
                    if isEditing {
                        HStack {
                            Button(action: {
                                isEditing = false
                                matchCopy = match // Reset changes
                            }) {
                                Text("Cancel")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                            }
                            
                            Button(action: {
                                onUpdate(matchCopy)
                                isEditing = false
                            }) {
                                Text("Save Changes")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Theme.primaryGradient)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                            }
                        }
                    } else {
                        GlowButton(title: "Edit Match", icon: "pencil") {
                            isEditing = true
                        }
                    }
                }
                .padding()
            }
            .background(Theme.darkBackground.ignoresSafeArea())
            .navigationBarTitle("Match Details", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

#Preview {
    MatchesView(teams: .constant(SampleData.generateTeams()))
        .background(Theme.darkBackground)
} 