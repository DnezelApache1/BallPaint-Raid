import SwiftUI

struct ArenaMapView: View {
    private let gridSize = 10
    @State private var occupiedCells: [GridPosition: GridOccupant] = [:]
    @State private var selectedTeamFilter: UUID? = nil
    @State private var mapScale: CGFloat = 1.0
    @State private var isPanelExpanded = false
    @State private var teams = SampleData.generateTeams()
    @State private var selectedToolIndex = 0
    
    private let tools = ["pin", "flag.fill", "exclamationmark.triangle.fill", "shield.fill"]
    private let toolColors: [Color] = [.red, .blue, .yellow, .green]
    
    var body: some View {
        ZStack {
            Theme.darkBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Map Area
                mapView
                    .padding(.bottom, isPanelExpanded ? 200 : 80) // Dynamic padding based on panel state
            }
            
            // Bottom Panel
            VStack {
                Spacer()
                
                bottomPanel
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Arena Map")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    // Reset map
                    occupiedCells.removeAll()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
            }
            
            // Team filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button(action: {
                        selectedTeamFilter = nil
                    }) {
                        Text("All Teams")
                            .font(Theme.captionFont)
                            .foregroundColor(selectedTeamFilter == nil ? .white : .white.opacity(0.7))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(selectedTeamFilter == nil ? Theme.primaryGradient : LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.3), Color.black.opacity(0.3)]), startPoint: .leading, endPoint: .trailing))
                            .clipShape(Capsule())
                    }
                    
                    ForEach(teams) { team in
                        Button(action: {
                            selectedTeamFilter = team.id
                        }) {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(team.color)
                                    .frame(width: 10, height: 10)
                                
                                Text(team.name)
                                    .font(Theme.captionFont)
                                    .foregroundColor(selectedTeamFilter == team.id ? .white : .white.opacity(0.7))
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(selectedTeamFilter == team.id ? team.color.opacity(0.3) : Color.black.opacity(0.3))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(team.color.opacity(selectedTeamFilter == team.id ? 0.8 : 0.0), lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color.black.opacity(0.2))
    }
    
    // MARK: - Map View
    private var mapView: some View {
        GeometryReader { geometry in
            let cellSize = min(geometry.size.width, geometry.size.height - 150) / CGFloat(gridSize) * mapScale
            
            ZStack {
                // Background
                Image("map_background") 
                    .resizable()
                    .scaledToFill()
                    .opacity(0.2)
                
                // Grid
                gridView(cellSize: cellSize, geometry: geometry)
                    .scaleEffect(mapScale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / mapScale
                                mapScale *= delta
                                mapScale = min(max(mapScale, 0.5), 2.0)
                            }
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(edges: [.horizontal])
    }
    
    private func gridView(cellSize: CGFloat, geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<gridSize, id: \.self) { column in
                        let position = GridPosition(row: row, column: column)
                        let occupant = occupiedCells[position]
                        
                        mapCell(position: position, occupant: occupant, cellSize: cellSize)
                    }
                }
            }
        }
        .frame(width: cellSize * CGFloat(gridSize), height: cellSize * CGFloat(gridSize))
        .position(x: geometry.size.width / 2, y: min(geometry.size.height / 2, geometry.size.height - (isPanelExpanded ? 220 : 100)))
    }
    
    private func mapCell(position: GridPosition, occupant: GridOccupant?, cellSize: CGFloat) -> some View {
        let isOccupied = occupant != nil
        let teamColor = isOccupied ? (occupant?.teamColor ?? .clear) : .clear
        let icon = isOccupied ? (occupant?.icon ?? "") : ""
        
        return MapGridCell(
            isOccupied: isOccupied,
            teamColor: teamColor,
            icon: icon,
            onTap: {
                cellTapped(position: position)
            }
        )
        .frame(width: cellSize, height: cellSize)
    }
    
    private func cellTapped(position: GridPosition) {
        if occupiedCells[position] != nil {
            // If cell is already occupied, remove it
            occupiedCells.removeValue(forKey: position)
        } else {
            // Otherwise add a new occupant
            if let team = teams.first(where: { $0.id == selectedTeamFilter }) ?? teams.first {
                let occupant = GridOccupant(
                    id: UUID(),
                    teamId: team.id,
                    teamColor: team.color,
                    icon: tools[selectedToolIndex],
                    type: .player
                )
                occupiedCells[position] = occupant
            }
        }
    }
    
    // MARK: - Bottom Panel
    private var bottomPanel: some View {
        VStack(spacing: 0) {
            // Handle
            Rectangle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 40, height: 4)
                .clipShape(Capsule())
                .padding(.vertical, 6)
                .onTapGesture {
                    withAnimation(.spring()) {
                        isPanelExpanded.toggle()
                    }
                }
            
            // Tools and Controls
            VStack(spacing: 12) {
                // Tools
                HStack(spacing: 12) {
                    ForEach(0..<tools.count, id: \.self) { index in
                        Button(action: {
                            selectedToolIndex = index
                        }) {
                            ZStack {
                                Circle()
                                    .fill(selectedToolIndex == index ? toolColors[index] : Color.black.opacity(0.3))
                                    .frame(width: 44, height: 44)
                                    .shadow(color: selectedToolIndex == index ? toolColors[index].opacity(0.6) : Color.clear, radius: 8, x: 0, y: 0)
                                
                                Image(systemName: tools[index])
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Zoom controls
                    HStack(spacing: 16) {
                        Button(action: {
                            mapScale = max(mapScale - 0.25, 0.5)
                        }) {
                            Image(systemName: "minus.magnifyingglass")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            mapScale = min(mapScale + 0.25, 2.0)
                        }) {
                            Image(systemName: "plus.magnifyingglass")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                }
                
                if isPanelExpanded {
                    // Legend
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Legend")
                            .font(Theme.headlineFont)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 16) {
                            ForEach(0..<tools.count, id: \.self) { index in
                                HStack(spacing: 6) {
                                    Image(systemName: tools[index])
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(toolColors[index])
                                    
                                    Text(toolName(for: index))
                                        .font(Theme.captionFont)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                            .padding(.vertical, 6)
                        
                        // Actions
                        HStack {
                            Button(action: {
                                // Save Map
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                        .font(.system(size: 14, weight: .semibold))
                                    
                                    Text("Save")
                                        .font(Theme.captionFont)
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Capsule())
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Share Map
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 14, weight: .semibold))
                                    
                                    Text("Share")
                                        .font(Theme.captionFont)
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.top, 6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, isPanelExpanded ? 24 : 12)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.black.opacity(0.5))
                    .edgesIgnoringSafeArea(.bottom)
            )
        }
        .frame(height: isPanelExpanded ? 200 : 80)
        .animation(.spring(), value: isPanelExpanded)
    }
    
    private func toolName(for index: Int) -> String {
        switch index {
        case 0:
            return "Player"
        case 1:
            return "Flag"
        case 2:
            return "Danger"
        case 3:
            return "Cover"
        default:
            return ""
        }
    }
}

// MARK: - Models
struct GridPosition: Hashable {
    let row: Int
    let column: Int
}

struct GridOccupant: Identifiable {
    var id: UUID
    var teamId: UUID
    var teamColor: Color
    var icon: String
    var type: OccupantType
    
    enum OccupantType {
        case player, flag, danger, cover
    }
}

#Preview {
    ZStack {
        Theme.darkBackground
            .ignoresSafeArea()
        
        ArenaMapView()
    }
} 