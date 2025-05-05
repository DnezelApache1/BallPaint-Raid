import Foundation
import SwiftUI

// MARK: - Player Model
struct Player: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var nickname: String
    var role: PlayerRole
    var avatar: String // SF Symbol name
    var stats: PlayerStats
    
    enum PlayerRole: String, CaseIterable, Identifiable, Codable {
        case sniper = "Sniper"
        case scout = "Scout"
        case support = "Support"
        case assault = "Assault"
        case medic = "Medic"
        case captain = "Captain"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .sniper: return "scope"
            case .scout: return "binoculars"
            case .support: return "shield"
            case .assault: return "bolt.fill"
            case .medic: return "cross.case.fill"
            case .captain: return "star.fill"
            }
        }
    }
    
    // Codable support for Color - encoding
    enum CodingKeys: String, CodingKey {
        case id, name, nickname, role, avatar, stats
    }
    
    // Equatable implementation
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.nickname == rhs.nickname &&
               lhs.role == rhs.role
    }
}

// MARK: - Team Model
struct Team: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var color: Color
    var players: [Player]
    var iconName: String // SF Symbol name
    var matchHistory: [UUID] // Match IDs
    
    // Codable support for Color
    enum CodingKeys: String, CodingKey {
        case id, name, colorHex, players, iconName, matchHistory
    }
    
    // Custom initializer for normal use
    init(id: UUID = UUID(), name: String, color: Color, players: [Player], iconName: String, matchHistory: [UUID]) {
        self.id = id
        self.name = name
        self.color = color
        self.players = players
        self.iconName = iconName
        self.matchHistory = matchHistory
    }
    
    // Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(colorToHex(color), forKey: .colorHex)
        try container.encode(players, forKey: .players)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(matchHistory, forKey: .matchHistory)
    }
    
    // Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let colorHex = try container.decode(String.self, forKey: .colorHex)
        color = Color(hex: colorHex) ?? .blue
        players = try container.decode([Player].self, forKey: .players)
        iconName = try container.decode(String.self, forKey: .iconName)
        matchHistory = try container.decode([UUID].self, forKey: .matchHistory)
    }
    
    // Helper to convert Color to hex string
    private func colorToHex(_ color: Color) -> String {
        // Get UIColor from Color
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        // Convert to hex
        let hex = String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r) * 255),
            lroundf(Float(g) * 255),
            lroundf(Float(b) * 255)
        )
        return hex
    }
    
    // Equatable implementation
    static func == (lhs: Team, rhs: Team) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.iconName == rhs.iconName &&
               lhs.players.count == rhs.players.count
    }
}

// MARK: - Match Model
struct Match: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var teams: [Team]
    var location: String
    var events: [MatchEvent]
    var status: MatchStatus
    var winner: UUID? // Team ID
    var score: [UUID: Int] // Команда -> Счет
    var duration: TimeInterval // Длительность в секундах
    
    enum MatchStatus: String, Codable, CaseIterable {
        case scheduled = "Scheduled"
        case inProgress = "In Progress"
        case completed = "Completed"
        case cancelled = "Cancelled"
        
        var color: Color {
            switch self {
            case .scheduled: return .yellow
            case .inProgress: return .green
            case .completed: return .blue
            case .cancelled: return .red
            }
        }
    }
    
    // Кодирование и декодирование для dictionary score
    enum CodingKeys: String, CodingKey {
        case id, date, teams, location, events, status, winner, scoreKeys, scoreValues, duration
    }
    
    // Кастомный инициализатор
    init(id: UUID = UUID(), date: Date, teams: [Team], location: String, events: [MatchEvent] = [], 
         status: MatchStatus, winner: UUID? = nil, score: [UUID: Int] = [:], duration: TimeInterval = 0) {
        self.id = id
        self.date = date
        self.teams = teams
        self.location = location
        self.events = events
        self.status = status
        self.winner = winner
        self.score = score
        self.duration = duration
    }
    
    // Кодирование
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(teams, forKey: .teams)
        try container.encode(location, forKey: .location)
        try container.encode(events, forKey: .events)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(winner, forKey: .winner)
        try container.encode(duration, forKey: .duration)
        
        // Кодирование словаря score
        let scoreKeys = Array(score.keys)
        let scoreValues = scoreKeys.map { score[$0] ?? 0 }
        try container.encode(scoreKeys, forKey: .scoreKeys)
        try container.encode(scoreValues, forKey: .scoreValues)
    }
    
    // Декодирование
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        teams = try container.decode([Team].self, forKey: .teams)
        location = try container.decode(String.self, forKey: .location)
        events = try container.decode([MatchEvent].self, forKey: .events)
        status = try container.decode(MatchStatus.self, forKey: .status)
        winner = try container.decodeIfPresent(UUID.self, forKey: .winner)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        
        // Декодирование словаря score
        let scoreKeys = try container.decode([UUID].self, forKey: .scoreKeys)
        let scoreValues = try container.decode([Int].self, forKey: .scoreValues)
        score = Dictionary(uniqueKeysWithValues: zip(scoreKeys, scoreValues))
    }
}

// MARK: - Match Event
struct MatchEvent: Identifiable, Codable {
    var id = UUID()
    var timestamp: Date
    var eventType: EventType
    var playerId: UUID
    var targetPlayerId: UUID?
    var position: CGPoint?
    
    enum EventType: String, Codable {
        case elimination
        case objectiveCapture
        case resupply
        case teamRevive
        case flagPickup
        case flagDrop
    }
    
    // Codable support for CGPoint
    enum CodingKeys: String, CodingKey {
        case id, timestamp, eventType, playerId, targetPlayerId, x, y
    }
    
    // Default initializer
    init(id: UUID = UUID(), timestamp: Date, eventType: EventType, playerId: UUID, targetPlayerId: UUID? = nil, position: CGPoint? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.eventType = eventType
        self.playerId = playerId
        self.targetPlayerId = targetPlayerId
        self.position = position
    }
    
    // Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(eventType, forKey: .eventType)
        try container.encode(playerId, forKey: .playerId)
        try container.encodeIfPresent(targetPlayerId, forKey: .targetPlayerId)
        
        if let point = position {
            try container.encode(point.x, forKey: .x)
            try container.encode(point.y, forKey: .y)
        }
    }
    
    // Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        eventType = try container.decode(EventType.self, forKey: .eventType)
        playerId = try container.decode(UUID.self, forKey: .playerId)
        targetPlayerId = try container.decodeIfPresent(UUID.self, forKey: .targetPlayerId)
        
        if container.contains(.x) && container.contains(.y) {
            let x = try container.decode(CGFloat.self, forKey: .x)
            let y = try container.decode(CGFloat.self, forKey: .y)
            position = CGPoint(x: x, y: y)
        } else {
            position = nil
        }
    }
}

// MARK: - Stats
struct PlayerStats: Codable, Equatable {
    var eliminations: Int = 0
    var deaths: Int = 0
    var assists: Int = 0
    var objectiveCaptures: Int = 0
    var matchesPlayed: Int = 0
    var matchesWon: Int = 0
    
    var kdRatio: Double {
        return deaths > 0 ? Double(eliminations) / Double(deaths) : Double(eliminations)
    }
    
    var winRate: Double {
        return matchesPlayed > 0 ? Double(matchesWon) / Double(matchesPlayed) * 100 : 0
    }
    
    // Equatable implementation
    static func == (lhs: PlayerStats, rhs: PlayerStats) -> Bool {
        return lhs.eliminations == rhs.eliminations &&
               lhs.deaths == rhs.deaths &&
               lhs.assists == rhs.assists &&
               lhs.objectiveCaptures == rhs.objectiveCaptures &&
               lhs.matchesPlayed == rhs.matchesPlayed &&
               lhs.matchesWon == rhs.matchesWon
    }
}

// MARK: - Sample Data
class SampleData {
    static func generatePlayers() -> [Player] {
        return [
            Player(name: "Alex Johnson", nickname: "Quickshot", role: .sniper, avatar: "person.circle.fill", stats: PlayerStats(eliminations: 42, deaths: 12, assists: 8, objectiveCaptures: 3, matchesPlayed: 10, matchesWon: 7)),
            Player(name: "Sam Rivera", nickname: "Shadow", role: .scout, avatar: "person.circle.fill", stats: PlayerStats(eliminations: 26, deaths: 18, assists: 15, objectiveCaptures: 12, matchesPlayed: 12, matchesWon: 8)),
            Player(name: "Jordan Smith", nickname: "Tank", role: .assault, avatar: "person.circle.fill", stats: PlayerStats(eliminations: 56, deaths: 23, assists: 4, objectiveCaptures: 2, matchesPlayed: 14, matchesWon: 9)),
            Player(name: "Taylor Wong", nickname: "Doc", role: .medic, avatar: "person.circle.fill", stats: PlayerStats(eliminations: 12, deaths: 15, assists: 36, objectiveCaptures: 5, matchesPlayed: 11, matchesWon: 7)),
            Player(name: "Morgan Chen", nickname: "Commander", role: .captain, avatar: "person.circle.fill", stats: PlayerStats(eliminations: 38, deaths: 16, assists: 24, objectiveCaptures: 9, matchesPlayed: 13, matchesWon: 10))
        ]
    }
    
    static func generateTeams() -> [Team] {
        let players = generatePlayers()
        return [
            Team(name: "Purple Reign", color: Theme.deepPurple, players: Array(players.prefix(3)), iconName: "bolt.circle.fill", matchHistory: []),
            Team(name: "Neon Strikers", color: Theme.lightPurple, players: Array(players.suffix(2)), iconName: "star.circle.fill", matchHistory: [])
        ]
    }
    
    static func generateMatches() -> [Match] {
        let teams = generateTeams()
        let team1 = teams[0]
        let team2 = teams[1]
        
        let calendar = Calendar.current
        
        // Матч 1 - завершен
        let match1Date = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        var match1 = Match(
            date: match1Date,
            teams: [team1, team2],
            location: "Evergreen Arena",
            status: .completed,
            winner: team1.id,
            duration: 3600 // 1 час
        )
        match1.score = [team1.id: 12, team2.id: 8]
        
        // Матч 2 - запланирован
        let match2Date = calendar.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        var match2 = Match(
            date: match2Date,
            teams: [team1, team2],
            location: "Urban Warfare Center",
            status: .scheduled,
            duration: 0
        )
        match2.score = [team1.id: 0, team2.id: 0]
        
        // Матч 3 - в процессе
        var match3 = Match(
            date: Date(),
            teams: [team1, team2],
            location: "Woodland Arena",
            status: .inProgress,
            duration: 1800 // 30 минут
        )
        match3.score = [team1.id: 5, team2.id: 7]
        
        return [match1, match2, match3]
    }
} 