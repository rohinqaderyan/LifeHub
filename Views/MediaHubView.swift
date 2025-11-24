//
//  MediaHubView.swift
//  LifeHub
//
//  Media hub with music player, photo gallery, and video player
//

import SwiftUI
import AVKit

struct MediaHubView: View {
    @EnvironmentObject var mediaManager: MediaManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom segmented control
                Picker("Media Type", selection: $selectedTab) {
                    Text("Music").tag(0)
                    Text("Photos").tag(1)
                    Text("Videos").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selection
                TabView(selection: $selectedTab) {
                    MusicPlayerView()
                        .tag(0)
                    
                    PhotoGalleryView()
                        .tag(1)
                    
                    VideoPlayerView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(themeManager.currentTheme.gradient.opacity(0.05).ignoresSafeArea())
            .navigationTitle("Media Hub")
        }
    }
}

// MARK: - Music Player View
struct MusicPlayerView: View {
    @EnvironmentObject var mediaManager: MediaManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingCreatePlaylist = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Now playing card
                if let currentTrack = mediaManager.currentTrack {
                    nowPlayingCard(track: currentTrack)
                }
                
                // Playlists section
                playlistsSection
            }
            .padding()
        }
    }
    
    // MARK: - Now Playing Card
    private func nowPlayingCard(track: MediaTrack) -> some View {
        VStack(spacing: 20) {
            // Album art
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.currentTheme.gradient)
                .frame(height: 300)
                .overlay(
                    Image(systemName: "music.note")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.8))
                )
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // Track info
            VStack(spacing: 8) {
                Text(track.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(track.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(themeManager.currentTheme.accentColor)
                            .frame(width: geometry.size.width * CGFloat(mediaManager.currentTime / track.duration), height: 4)
                    }
                }
                .frame(height: 4)
                
                HStack {
                    Text(formatTime(mediaManager.currentTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatTime(track.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Controls
            HStack(spacing: 40) {
                Button(action: { mediaManager.skipBackward() }) {
                    Image(systemName: "backward.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                
                Button(action: togglePlayPause) {
                    Image(systemName: mediaManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(themeManager.currentTheme.gradient)
                }
                
                Button(action: { mediaManager.skipForward() }) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                }
            }
            .padding(.top)
        }
        .padding()
        .glassmorphic()
    }
    
    // MARK: - Playlists Section
    private var playlistsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Playlists")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showingCreatePlaylist = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(themeManager.currentTheme.gradient)
                }
            }
            
            ForEach(mediaManager.playlists) { playlist in
                PlaylistCard(playlist: playlist)
            }
        }
        .sheet(isPresented: $showingCreatePlaylist) {
            CreatePlaylistView()
        }
    }
    
    private func togglePlayPause() {
        if mediaManager.isPlaying {
            mediaManager.pauseTrack()
        } else {
            mediaManager.resumeTrack()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Playlist Card
struct PlaylistCard: View {
    @EnvironmentObject var mediaManager: MediaManager
    @EnvironmentObject var themeManager: ThemeManager
    let playlist: Playlist
    
    var body: some View {
        HStack(spacing: 16) {
            // Cover image
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.currentTheme.gradient)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "music.note.list")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.8))
                )
            
            // Playlist info
            VStack(alignment: .leading, spacing: 4) {
                Text(playlist.name)
                    .font(.headline)
                
                Text("\(playlist.tracks.count) songs")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Play button
            Button(action: { playPlaylist() }) {
                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(themeManager.currentTheme.gradient)
            }
        }
        .padding()
        .glassmorphic()
    }
    
    private func playPlaylist() {
        if let firstTrack = playlist.tracks.first {
            mediaManager.playTrack(firstTrack)
        }
    }
}

// MARK: - Photo Gallery View
struct PhotoGalleryView: View {
    @EnvironmentObject var mediaManager: MediaManager
    @State private var selectedPhoto: PhotoItem?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(mediaManager.photos) { photo in
                    PhotoThumbnail(photo: photo)
                        .onTapGesture {
                            selectedPhoto = photo
                        }
                }
            }
            .padding()
        }
        .fullScreenCover(item: $selectedPhoto) { photo in
            PhotoDetailView(photo: photo)
        }
    }
}

// MARK: - Photo Thumbnail
struct PhotoThumbnail: View {
    let photo: PhotoItem
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.3))
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundColor(.gray)
            )
    }
}

// MARK: - Photo Detail View
struct PhotoDetailView: View {
    @Environment(\.dismiss) var dismiss
    let photo: PhotoItem
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var selectedFilter: PhotoFilter = .none
    
    enum PhotoFilter: String, CaseIterable {
        case none = "Original"
        case sepia = "Sepia"
        case mono = "Mono"
        case noir = "Noir"
        case vibrant = "Vibrant"
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Photo
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(3/4, contentMode: .fit)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 100))
                            .foregroundColor(.gray)
                    )
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                                if scale < 1 {
                                    withAnimation {
                                        scale = 1
                                        lastScale = 1
                                    }
                                }
                            }
                    )
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(PhotoFilter.allCases, id: \.self) { filter in
                            FilterButton(
                                title: filter.rawValue,
                                isSelected: selectedFilter == filter,
                                action: { selectedFilter = filter }
                            )
                        }
                    }
                    .padding()
                }
            }
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.white : Color.white.opacity(0.2))
                .cornerRadius(20)
        }
    }
}

// MARK: - Video Player View
struct VideoPlayerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showVideoPlayer = false
    
    let sampleVideos = [
        ("Nature Documentary", "film"),
        ("Music Video", "music.note.tv"),
        ("Tutorial", "play.rectangle")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(sampleVideos, id: \.0) { video in
                    VideoCard(title: video.0, icon: video.1)
                        .onTapGesture {
                            showVideoPlayer = true
                        }
                }
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showVideoPlayer) {
            VideoPlayerFullScreen()
        }
    }
}

// MARK: - Video Card
struct VideoCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Video thumbnail
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.currentTheme.gradient.opacity(0.3))
                .frame(height: 200)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.8))
                )
            
            // Title
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(themeManager.currentTheme.gradient)
            }
        }
        .padding()
        .glassmorphic()
    }
}

// MARK: - Video Player Full Screen
struct VideoPlayerFullScreen: View {
    @Environment(\.dismiss) var dismiss
    @State private var player = AVPlayer()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Video player placeholder
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        VStack(spacing: 20) {
                            Image(systemName: "play.circle")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                            Text("Video Player")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    )
                
                // Controls
                HStack(spacing: 40) {
                    Button(action: {}) {
                        Image(systemName: "backward.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "forward.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
            
            // Close button
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

// MARK: - Create Playlist View
struct CreatePlaylistView: View {
    @EnvironmentObject var mediaManager: MediaManager
    @Environment(\.dismiss) var dismiss
    @State private var playlistName = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Playlist Details") {
                    TextField("Playlist Name", text: $playlistName)
                }
            }
            .navigationTitle("New Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        mediaManager.createPlaylist(name: playlistName)
                        dismiss()
                    }
                    .disabled(playlistName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    MediaHubView()
        .environmentObject(MediaManager())
        .environmentObject(ThemeManager())
}
