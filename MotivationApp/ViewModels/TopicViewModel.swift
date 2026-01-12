//
//  TopicViewModel.swift
//  MotivationApp
//
//  Created on 2026-01-12.
//

import Foundation
import Combine

class TopicViewModel: ObservableObject {
    @Published var topics: [Topic] = []
    @Published var searchText: String = ""
    @Published var selectedTopic: Topic?
    
    private let dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()
    
    init(dataManager: DataManager = .shared) {
        self.dataManager = dataManager
        loadTopics()
    }
    
    func loadTopics() {
        topics = Topic.sampleTopics
    }
    
    var quickAccessTopics: [Topic] {
        return topics.filter { $0.type == .quick }
    }
    
    var categoryTopics: [Topic] {
        return topics.filter { $0.type == .category }
    }
    
    var filteredTopics: [Topic] {
        if searchText.isEmpty {
            return topics
        }
        return topics.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    func selectTopic(_ topic: Topic) {
        selectedTopic = topic
    }
}
