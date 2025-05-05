import SwiftUI

// MARK: - Glow Button
struct GlowButton: View {
    var title: String
    var icon: String
    var action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            action()
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(Theme.headlineFont)
                    .foregroundColor(.white)
                    .padding(.leading, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Theme.primaryGradient
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .shadow(color: Theme.deepPurple.opacity(isPressed ? 0.7 : 0.5), 
                    radius: isPressed ? 15 : 10, 
                    x: 0, 
                    y: 0)
            .scaleEffect(isPressed ? 0.98 : 1)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Feature Card
struct FeatureCard: View {
    var title: String
    var icon: String
    var description: String
    var action: () -> Void
    
    @State private var isSelected = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                isSelected.toggle()
            }
            action()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Theme.primaryGradient)
                        )
                    
                    Text(title)
                        .font(Theme.headlineFont)
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Text(description)
                    .font(Theme.bodyFont)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(minHeight: 110)
            .background(Color.black.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(
                        isSelected ? Theme.lightPurple : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? Theme.lightPurple.opacity(0.6) : Color.clear, 
                    radius: isSelected ? 8 : 0, 
                    x: 0, 
                    y: 0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Player Card
struct PlayerCard: View {
    var player: Player
    var isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Theme.primaryGradient)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: player.avatar)
                        .font(.system(size: 24, weight: .semibold))
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
                
                VStack(alignment: .trailing) {
                    HStack(spacing: 4) {
                        Image(systemName: "target")
                            .font(.system(size: 12))
                            .foregroundColor(Color.red.opacity(0.8))
                        
                        Text("\(player.stats.eliminations)")
                            .font(Theme.bodyFont)
                            .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.heart")
                            .font(.system(size: 12))
                            .foregroundColor(Color.green.opacity(0.8))
                        
                        Text("\(player.stats.assists)")
                            .font(Theme.bodyFont)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(16)
            .background(Color.black.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(
                        isSelected ? Theme.lightPurple : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? Theme.lightPurple.opacity(0.6) : Color.clear, 
                    radius: isSelected ? 8 : 0, 
                    x: 0, 
                    y: 0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Stats Bar
struct StatsBar: View {
    var value: Double
    var maxValue: Double
    var color: Color
    var icon: String
    var title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                
                Text(title)
                    .font(Theme.captionFont)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(String(format: "%.1f", value))
                    .font(Theme.headlineFont)
                    .foregroundColor(.white)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.black.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color.opacity(0.7), color]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(CGFloat(value / maxValue), 1.0))
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    var title: String
    var icon: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: isSelected ? 22 : 20, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(title)
                    .font(isSelected ? Theme.captionFont.weight(.bold) : Theme.captionFont)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .background(
                isSelected ?
                Circle()
                    .fill(Theme.primaryGradient)
                    .frame(width: 32, height: 32)
                    .blur(radius: 20)
                    .opacity(0.8)
                    .offset(y: -10)
                : nil
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - AI Assistant Button
struct AIAssistantButton: View {
    var action: () -> Void
    @State private var isGlowing = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Theme.primaryGradient)
                    .frame(width: 60, height: 60)
                    .shadow(color: Theme.lightPurple.opacity(0.7), radius: isGlowing ? 15 : 10, x: 0, y: 0)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isGlowing = true
            }
        }
    }
}

// MARK: - Map Grid Cell
struct MapGridCell: View {
    var isOccupied: Bool
    var teamColor: Color?
    var icon: String?
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .border(Color.white.opacity(0.1), width: 1)
                
                if isOccupied, let teamColor = teamColor, let icon = icon {
                    Circle()
                        .fill(teamColor.opacity(0.3))
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(teamColor)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
} 