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

class MediaManager: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var currentTrack: MediaTrack?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var photos: [PhotoItem] = []
    
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
    }
    
    func pauseTrack() {
        isPlaying = false
    }
    
    func resumeTrack() {
        isPlaying = true
    }
    
    func skipForward() {
        // Implementation for skipping to next track
    }
    
    func skipBackward() {
        // Implementation for going to previous track
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
}
