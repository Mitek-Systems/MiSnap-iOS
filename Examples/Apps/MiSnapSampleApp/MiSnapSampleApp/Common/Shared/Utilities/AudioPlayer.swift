//
//  AudioPlayer.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import AVFoundation
import Combine
// MARK: - Audio Player
@MainActor
class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var progress: Double = 0.0
    
    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?
    
    // Track active players to manage audio session properly
    private static var activePlayers = Set<ObjectIdentifier>()
    
    func play(data: Data) {
        do {
            // Configure audio session (only if not already active)
            if AudioPlayer.activePlayers.isEmpty {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            }
            
            // Register this player as active
            AudioPlayer.activePlayers.insert(ObjectIdentifier(self))
            
            // Create and configure player
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            isPlaying = true
            startProgressTimer()
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
            stop()
        }
    }
    
    func stop() {
        // Stop timer first
        stopProgressTimer()
        
        // Stop and cleanup audio player
        if let player = audioPlayer {
            player.stop()
            player.delegate = nil
            audioPlayer = nil
        }
        
        // Update state
        isPlaying = false
        progress = 0.0
        
        // Unregister this player
        AudioPlayer.activePlayers.remove(ObjectIdentifier(self))
        
        // Only deactivate audio session if no other players are active
        if AudioPlayer.activePlayers.isEmpty {
            deactivateAudioSession()
        }
    }
    
    // Cleanup method for view dismissal - forces session deactivation
    func cleanup() {
        // Stop timer first
        stopProgressTimer()
        
        // Stop and cleanup audio player
        if let player = audioPlayer {
            player.stop()
            player.delegate = nil
            audioPlayer = nil
        }
        
        // Update state
        isPlaying = false
        progress = 0.0
        
        // Unregister this player and clear all active players to force session deactivation
        AudioPlayer.activePlayers.remove(ObjectIdentifier(self))
        
        // Always deactivate session on cleanup
        deactivateAudioSession()
    }
    
    private func deactivateAudioSession() {
        do {
            // First set the category back to allow recording
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            // Then deactivate with notification
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
    
    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self,
                      let player = self.audioPlayer,
                      player.duration > 0 else { return }
                
                self.progress = player.currentTime / player.duration
            }
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    // MARK: - AVAudioPlayerDelegate
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.stop()
        }
    }
    
    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            self.stop()
        }
    }
    
    nonisolated func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        Task { @MainActor in
            self.stop()
        }
    }
}
