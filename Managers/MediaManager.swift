//
//  MediaManager.swift
//  LifeHub
//
//  Manages media playback, playlists, and photo gallery
//

import SwiftUI
import AVKit
import Photos

// Media models
struct MediaTrack: Identifiable {
    let id = UUID()
    var title: String
    var artist: String
    var duration: TimeInterval
    var artworkName: String
}

struct Playlist: Identifiable {
    var id = UUID()
    var name: String
    var tracks: [MediaTrack]
    var coverImageName: String
}

struct PhotoItem: Identifiable {
    let id = UUID()
    var imageName: String
    var date: Date
    var location: String?
}

enum RepeatMode: String, CaseIterable {
    case off = "Off"
    case one = "Repeat One"
    case all = "Repeat All"
    
    var icon: String {
        switch self {
        case .off: return "repeat"
        case .one: return "repeat.1"
        case .all: return "repeat"
        }
    }
}

class MediaManager: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var currentTrack: MediaTrack?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var photos: [PhotoItem] = []
    @Published var playQueue: [MediaTrack] = []
    @Published var originalQueue: [MediaTrack] = []
    @Published var currentTrackIndex: Int = 0
    @Published var isShuffled = false
    @Published var repeatMode: RepeatMode = .off
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample playlists
        let sampleTracks = [
            MediaTrack(title: "Morning Vibes", artist: "Chill Beats", duration: 180, artworkName: "music1"),
            MediaTrack(title: "Focus Flow", artist: "Study Music", duration: 240, artworkName: "music2"),
            MediaTrack(title: "Evening Calm", artist: "Relaxation", duration: 200, artworkName: "music3")
        ]
        
        playlists = [
            Playlist(name: "Favorites", tracks: sampleTracks, coverImageName: "playlist1"),
            Playlist(name: "Workout", tracks: sampleTracks, coverImageName: "playlist2"),
            Playlist(name: "Chill", tracks: sampleTracks, coverImageName: "playlist3")
        ]
        
        // Sample photos
        photos = [
            PhotoItem(imageName: "photo1", date: Date(), location: "San Francisco"),
            PhotoItem(imageName: "photo2", date: Date().addingTimeInterval(-86400), location: "New York"),
            PhotoItem(imageName: "photo3", date: Date().addingTimeInterval(-172800), location: "Los Angeles")
        ]
    }
    
    func playTrack(_ track: MediaTrack) {
        currentTrack = track
        isPlaying = true
        currentTime = 0
        
        // Find track index in current queue
        if let index = playQueue.firstIndex(where: { $0.id == track.id }) {
            currentTrackIndex = index
        }
    }
    
    func playPlaylist(_ playlist: Playlist, startingAt index: Int = 0) {
        originalQueue = playlist.tracks
        playQueue = playlist.tracks
        currentTrackIndex = index
        
        if isShuffled {
            shuffleQueue()
        }
        
        if !playQueue.isEmpty {
            playTrack(playQueue[currentTrackIndex])
        }
    }
    
    func pauseTrack() {
        isPlaying = false
    }
    
    func resumeTrack() {
        isPlaying = true
    }
    
    func skipForward() {
        guard !playQueue.isEmpty else { return }
        
        switch repeatMode {
        case .one:
            // Replay current track
            currentTime = 0
        case .all:
            currentTrackIndex = (currentTrackIndex + 1) % playQueue.count
            playTrack(playQueue[currentTrackIndex])
        case .off:
            if currentTrackIndex < playQueue.count - 1 {
                currentTrackIndex += 1
                playTrack(playQueue[currentTrackIndex])
            } else {
                pauseTrack()
            }
        }
    }
    
    func skipBackward() {
        guard !playQueue.isEmpty else { return }
        
        if currentTime > 3 {
            // If more than 3 seconds into track, restart it
            currentTime = 0
        } else {
            // Go to previous track
            if currentTrackIndex > 0 {
                currentTrackIndex -= 1
            } else if repeatMode == .all {
                currentTrackIndex = playQueue.count - 1
            }
            playTrack(playQueue[currentTrackIndex])
        }
    }
    
    func toggleShuffle() {
        isShuffled.toggle()
        
        if isShuffled {
            shuffleQueue()
        } else {
            // Restore original order
            playQueue = originalQueue
            if let currentTrack = currentTrack,
               let index = playQueue.firstIndex(where: { $0.id == currentTrack.id }) {
                currentTrackIndex = index
            }
        }
    }
    
    func cycleRepeatMode() {
        let modes: [RepeatMode] = [.off, .all, .one]
        if let currentIndex = modes.firstIndex(of: repeatMode) {
            repeatMode = modes[(currentIndex + 1) % modes.count]
        }
    }
    
    private func shuffleQueue() {
        guard let currentTrack = currentTrack else {
            playQueue.shuffle()
            return
        }
        
        // Keep current track at current position, shuffle rest
        var tracksToShuffle = playQueue.filter { $0.id != currentTrack.id }
        tracksToShuffle.shuffle()
        
        playQueue = [currentTrack] + tracksToShuffle
        currentTrackIndex = 0
    }
    
    func createPlaylist(name: String) {
        let newPlaylist = Playlist(name: name, tracks: [], coverImageName: "playlist_default")
        playlists.append(newPlaylist)
    }
    
    func addTrackToPlaylist(track: MediaTrack, playlist: Playlist) {
        if let index = playlists.firstIndex(where: { $0.id == playlist.id }) {
            playlists[index].tracks.append(track)
        }
    }
    
    func addToQueue(_ track: MediaTrack) {
        playQueue.append(track)
        if !isShuffled {
            originalQueue.append(track)
        }
    }
    
    func removeFromQueue(at index: Int) {
        guard index < playQueue.count else { return }
        
        let removedTrack = playQueue[index]
        playQueue.remove(at: index)
        
        if !isShuffled {
            originalQueue.removeAll { $0.id == removedTrack.id }
        }
        
        // Adjust current index if needed
        if index < currentTrackIndex {
            currentTrackIndex -= 1
        } else if index == currentTrackIndex {
            // Current track was removed, play next
            if !playQueue.isEmpty {
                currentTrackIndex = min(currentTrackIndex, playQueue.count - 1)
                playTrack(playQueue[currentTrackIndex])
            } else {
                currentTrack = nil
                pauseTrack()
            }
        }
    }
    
    func clearQueue() {
        playQueue.removeAll()
        originalQueue.removeAll()
        currentTrack = nil
        currentTrackIndex = 0
        pauseTrack()
    }
}
