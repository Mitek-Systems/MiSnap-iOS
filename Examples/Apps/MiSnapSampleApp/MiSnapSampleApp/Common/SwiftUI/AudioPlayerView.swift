//
//  AudioPlayerView.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    // MARK: - Properties
    let audioData: Data
    let label: String
    
    @StateObject private var player = AudioPlayer()
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                    .frame(width: 60, height: 60)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: player.progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: player.progress)
                
                // Play/Stop button
                Button {
                    if player.isPlaying {
                        player.stop()
                    } else {
                        player.play(data: audioData)
                    }
                } label: {
                    Image(systemName: player.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .onDisappear {
            player.cleanup()
        }
    }
}
