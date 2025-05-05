import SwiftUI
import Foundation
import Combine
import UIKit

struct AIAssistantView: View {
    @Binding var isVisible: Bool
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isProcessing = false
    @State private var showTypingIndicator = false
    @FocusState private var isInputFocused: Bool
    @State private var scrollToBottom = false
    @State private var keyboardHeight: CGFloat = 0
    
    private let quickResponses = [
        "What are the best paintball tactics?",
        "How to improve my accuracy?",
        "Best positions for defense?",
        "Team formation strategies",
        "Equipment recommendations"
    ]
    
    private let initialMessage = ChatMessage(
        id: UUID().uuidString,
        content: "Hello! I'm your PaintRaid AI Assistant. How can I help you with your paintball strategy or stats today?",
        isFromUser: false,
        timestamp: Date()
    )
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Chat area
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(messages) { message in
                                    messageView(message)
                                        .id(message.id)
                                }
                                
                                if showTypingIndicator {
                                    typingIndicatorView
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .onChange(of: messages.count) { _, _ in
                                withAnimation {
                                    proxy.scrollTo(messages.last?.id, anchor: .bottom)
                                }
                            }
                            .onChange(of: scrollToBottom) { _, _ in
                                withAnimation {
                                    proxy.scrollTo(messages.last?.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    .background(Color.black.opacity(0.2))
                    
                    Spacer(minLength: keyboardHeight + (isInputFocused ? 120 : 0))
                }
                .background(Theme.darkBackground)
                
                // Quick responses and input - floating above keyboard
                VStack(spacing: 0) {
                    if !isInputFocused {
                        quickResponsesView
                    }
                    inputAreaView
                }
                .background(Theme.darkBackground)
                .offset(y: -keyboardHeight)
            }
        }
        .background(Theme.darkBackground)
        .onAppear {
            if messages.isEmpty {
                messages.append(initialMessage)
            }
            setupKeyboardNotifications()
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation(.easeIn(duration: 0.25)) {
                keyboardHeight = 0
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(Theme.lightPurple)
                .padding(10)
                .background(
                    Circle()
                        .fill(Theme.deepPurple.opacity(0.5))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Assistant")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(isProcessing ? "Thinking..." : "Online")
                    .font(Theme.captionFont)
                    .foregroundColor(isProcessing ? Theme.lavender : .green)
            }
            
            Spacer()
            
            Button {
                hideKeyboard()
                withAnimation {
                    isVisible = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Theme.darkBackground)
    }
    
    // MARK: - Message View
    private func messageView(_ message: ChatMessage) -> some View {
        HStack(alignment: .bottom) {
            if message.isFromUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(Theme.bodyFont)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        message.isFromUser ? 
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Theme.midPurple) :
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.black.opacity(0.3))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                
                Text(formatMessageTime(message.timestamp))
                    .font(Theme.captionFont)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }
            
            if !message.isFromUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.vertical, 2)
    }
    
    // MARK: - Typing Indicator
    private var typingIndicatorView: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Theme.lightPurple)
                        .frame(width: 8, height: 8)
                        .opacity(0.5)
                        .animation(Animation.easeInOut(duration: 0.5)
                                    .repeatForever()
                                    .delay(Double(i) * 0.2),
                                   value: isProcessing)
                }
            }
            .padding(12)
            .background(Color.black.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            Spacer()
        }
    }
    
    // MARK: - Quick Responses
    private var quickResponsesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(quickResponses, id: \.self) { response in
                    Button(action: {
                        messageText = response
                        isInputFocused = true
                        scrollToBottom.toggle()
                    }) {
                        Text(response)
                            .font(Theme.bodyFont)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Theme.deepPurple.opacity(0.5))
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color.black.opacity(0.2))
    }
    
    // MARK: - Input Area
    private var inputAreaView: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray.opacity(0.3))
            
            HStack(spacing: 12) {
                TextField("Ask about paintball tactics...", text: $messageText)
                    .focused($isInputFocused)
                    .font(Theme.bodyFont)
                    .padding(12)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(20)
                    .foregroundColor(.white)
                    .submitLabel(.send)
                    .onSubmit {
                        sendMessage()
                        hideKeyboard()
                    }
                
                Button(action: {
                    sendMessage()
                    hideKeyboard()
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(messageText.isEmpty ? .gray : Theme.lightPurple)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Helper Functions
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(
            id: UUID().uuidString,
            content: messageText,
            isFromUser: true,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        let userQuery = messageText
        messageText = ""
        scrollToBottom.toggle()
        
        withAnimation {
            isProcessing = true
            showTypingIndicator = true
        }
        
        // Send to OpenAI API
        OpenAIService.shared.sendMessage(userQuery) { result in
            DispatchQueue.main.async {
                withAnimation {
                    isProcessing = false
                    showTypingIndicator = false
                }
                
                switch result {
                case .success(let response):
                    let aiMessage = ChatMessage(
                        id: UUID().uuidString,
                        content: response,
                        isFromUser: false,
                        timestamp: Date()
                    )
                    messages.append(aiMessage)
                    scrollToBottom.toggle()
                    
                case .failure(let error):
                    let errorMessage = ChatMessage(
                        id: UUID().uuidString,
                        content: "Sorry, I encountered an error: \(error.localizedDescription). Please try again.",
                        isFromUser: false,
                        timestamp: Date()
                    )
                    messages.append(errorMessage)
                    scrollToBottom.toggle()
                }
            }
        }
    }
    
    private func formatMessageTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Models
struct ChatMessage: Identifiable {
    var id: String
    var content: String
    var isFromUser: Bool
    var timestamp: Date
}

// MARK: - OpenAI Service
class OpenAIService {
    static let shared = OpenAIService()
    
    private let apiKey = "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"
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    func sendMessage(_ message: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are an AI assistant for a paintball game app called PaintRaid. Provide helpful, detailed responses about paintball tactics, strategies, equipment, and game statistics. Keep your responses conversational and engaging."],
                ["role": "user", "content": message]
            ],
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0, userInfo: nil)))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(.success(content))
                } else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    completion(.failure(NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Preview
struct AIAssistantView_Previews: PreviewProvider {
    static var previews: some View {
        AIAssistantView(isVisible: .constant(true))
    }
} 