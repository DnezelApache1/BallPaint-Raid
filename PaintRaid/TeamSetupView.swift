import SwiftUI

struct TeamSetupView: View {
    @Binding var teams: [Team]
    @State private var showingAddTeam = false
    @State private var showingPlayerEdit = false
    @State private var selectedTeam: Team?
    @State private var selectedPlayer: Player?
    @State private var teamNameInput = ""
    @State private var teamColorSelection = 0
    @State private var selectedTeamIcon = "bolt.circle.fill"
    
    // Player form states
    @State private var playerNameInput = ""
    @State private var playerNicknameInput = ""
    @State private var selectedPlayerRole = Player.PlayerRole.assault
    @State private var selectedPlayerAvatar = "person.circle.fill"
    
    private let teamColors: [Color] = [
        Theme.deepPurple, Theme.midPurple, Theme.lightPurple, 
        .red, .blue, .green, .orange, .pink
    ]
    
    private let teamIcons = [
        "bolt.circle.fill", "star.circle.fill", "flame.circle.fill", 
        "crown.fill", "target", "shield.fill", "flag.fill"
    ]
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerView
                    
                    // Teams List
                    teamsListView
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 100) // Give space for the AI button
            }
            
            // Add team and player sheets
            if showingAddTeam {
                addTeamView
            }
            
            if showingPlayerEdit, let team = selectedTeam {
                editPlayerView(team: team)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Team Setup")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Create and manage your paintball squads")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.lavender)
                .padding(.bottom, 8)
            
            GlowButton(title: "Create New Team", icon: "plus") {
                withAnimation {
                    showingAddTeam = true
                }
            }
        }
    }
    
    // MARK: - Teams List View
    private var teamsListView: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(teams) { team in
                teamCard(team: team)
            }
        }
    }
    
    private func teamCard(team: Team) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Team Header
            HStack {
                Circle()
                    .fill(team.color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: team.iconName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                Text(team.name)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
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
            
            // Player List
            if !team.players.isEmpty {
                VStack(spacing: 10) {
                    ForEach(team.players) { player in
                        PlayerCard(
                            player: player,
                            isSelected: selectedPlayer?.id == player.id,
                            onTap: {
                                selectedPlayer = player
                                selectedTeam = team
                                showingPlayerEdit = true
                            }
                        )
                    }
                    
                    Button(action: {
                        selectedTeam = team
                        selectedPlayer = nil
                        showingPlayerEdit = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Add Player")
                                .font(Theme.bodyFont)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                                .fill(Color.black.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                }
            } else {
                Text("No players added yet")
                    .font(Theme.bodyFont)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                            .fill(Color.black.opacity(0.2))
                    )
                
                Button(action: {
                    selectedTeam = team
                    selectedPlayer = nil
                    showingPlayerEdit = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Add First Player")
                            .font(Theme.bodyFont)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                            .fill(team.color.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                                    .stroke(team.color.opacity(0.5), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .stroke(team.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Add Team View
    private var addTeamView: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showingAddTeam = false
                    }
                }
            
            VStack(spacing: 20) {
                Text("Create New Team")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Team Name")
                        .font(Theme.headlineFont)
                        .foregroundColor(Theme.lavender)
                    
                    TextField("Purple Reign", text: $teamNameInput)
                        .font(Theme.bodyFont)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .onSubmit {
                            // Focus next field or submit if last field
                        }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Team Color")
                        .font(Theme.headlineFont)
                        .foregroundColor(Theme.lavender)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 16) {
                        ForEach(0..<teamColors.count, id: \.self) { index in
                            Circle()
                                .fill(teamColors[index])
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: teamColorSelection == index ? 3 : 0)
                                )
                                .shadow(color: teamColors[index].opacity(0.6), radius: teamColorSelection == index ? 8 : 0, x: 0, y: 0)
                                .onTapGesture {
                                    teamColorSelection = index
                                }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Team Icon")
                        .font(Theme.headlineFont)
                        .foregroundColor(Theme.lavender)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(teamIcons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(teamColors[teamColorSelection])
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedTeamIcon == icon ? 3 : 0)
                                    )
                                    .onTapGesture {
                                        selectedTeamIcon = icon
                                    }
                            }
                        }
                    }
                }
                
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation {
                            showingAddTeam = false
                        }
                    }) {
                        Text("Cancel")
                            .font(Theme.bodyFont)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                    }
                    
                    Button(action: {
                        let newTeam = Team(
                            name: teamNameInput.isEmpty ? "New Team" : teamNameInput,
                            color: teamColors[teamColorSelection],
                            players: [],
                            iconName: selectedTeamIcon,
                            matchHistory: []
                        )
                        
                        print("Adding new team: \(newTeam.name)")
                        
                        // Создаем новый массив вместо изменения существующего
                        var updatedTeams = teams
                        updatedTeams.append(newTeam)
                        teams = updatedTeams
                        
                        // Reset form
                        teamNameInput = ""
                        teamColorSelection = 0
                        selectedTeamIcon = "bolt.circle.fill"
                        
                        withAnimation {
                            showingAddTeam = false
                        }
                    }) {
                        Text("Create Team")
                            .font(Theme.bodyFont)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(hex: "2B0B3F"))
            )
            .padding(.horizontal, 20)
        }
        .transition(.opacity)
    }
    
    // MARK: - Edit Player View
    private func editPlayerView(team: Team) -> some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showingPlayerEdit = false
                    }
                }
            
            VStack(spacing: 20) {
                Text(selectedPlayer == nil ? "Add New Player" : "Edit Player")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                if let _ = selectedPlayer {
                    // Edit existing player
                    Text("Player editing form would go here")
                        .foregroundColor(.white)
                } else {
                    // Add new player
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Player Name")
                                .font(Theme.headlineFont)
                                .foregroundColor(Theme.lavender)
                            
                            TextField("Full Name", text: $playerNameInput)
                                .font(Theme.bodyFont)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                                .submitLabel(.next)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nickname")
                                .font(Theme.headlineFont)
                                .foregroundColor(Theme.lavender)
                            
                            TextField("Callsign", text: $playerNicknameInput)
                                .font(Theme.bodyFont)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                                .submitLabel(.done)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Role")
                                .font(Theme.headlineFont)
                                .foregroundColor(Theme.lavender)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Player.PlayerRole.allCases) { role in
                                        VStack(spacing: 8) {
                                            Image(systemName: role.icon)
                                                .font(.system(size: 24, weight: .semibold))
                                                .foregroundColor(.white)
                                                .frame(width: 50, height: 50)
                                                .background(team.color)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: selectedPlayerRole == role ? 3 : 0)
                                                )
                                                .onTapGesture {
                                                    selectedPlayerRole = role
                                                }
                                            
                                            Text(role.rawValue)
                                                .font(Theme.captionFont)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation {
                            showingPlayerEdit = false
                        }
                    }) {
                        Text("Cancel")
                            .font(Theme.bodyFont)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                    }
                    
                    Button(action: {
                        if selectedPlayer == nil {
                            // Add new player logic would go here
                            if let teamIndex = teams.firstIndex(where: { $0.id == team.id }) {
                                let newPlayer = Player(
                                    name: playerNameInput.isEmpty ? "New Player" : playerNameInput,
                                    nickname: playerNicknameInput.isEmpty ? "Rookie" : playerNicknameInput,
                                    role: selectedPlayerRole,
                                    avatar: selectedPlayerAvatar,
                                    stats: PlayerStats()
                                )
                                
                                print("Adding new player: \(newPlayer.name) to team: \(team.name)")
                                
                                // Создаем новую копию массива команд
                                var updatedTeams = teams
                                // Добавляем игрока в команду
                                updatedTeams[teamIndex].players.append(newPlayer)
                                // Обновляем связанную переменную
                                teams = updatedTeams
                                
                                // Reset form
                                playerNameInput = ""
                                playerNicknameInput = ""
                                selectedPlayerRole = .assault
                            }
                        } else {
                            // Update player logic would go here
                        }
                        
                        withAnimation {
                            showingPlayerEdit = false
                        }
                    }) {
                        Text(selectedPlayer == nil ? "Add Player" : "Save Changes")
                            .font(Theme.bodyFont)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(hex: "2B0B3F"))
            )
            .padding(.horizontal, 20)
        }
        .transition(.opacity)
    }
}

#Preview {
    ZStack {
        Theme.darkBackground
            .ignoresSafeArea()
        
        TeamSetupView(teams: .constant(SampleData.generateTeams()))
    }
} 