//
//  ResultView.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI

struct ResultView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var isCopiedAlertVisible = false
    @State private var showImageOverlay = false
    @State private var selectedImage: UIImage?
    
    private let responseText: String
    private let images: [UIImage]
    private let summaryText: String?
    private let audioData: [Data]?
    
    // MARK: - Initialization
    init(response: String, images: [UIImage]? = nil, summary: String? = nil, audioData: [Data]? = nil) {
        self.responseText = JSONFormatter.prettyPrint(response)
        self.images = images ?? []
        self.summaryText = summary
        self.audioData = audioData
    }
    
    // Convenience initializer for single image
    init(response: String, image: UIImage?, summary: String? = nil, audioData: [Data]? = nil) {
        self.responseText = JSONFormatter.prettyPrint(response)
        self.images = image.map { [$0] } ?? []
        self.summaryText = summary
        self.audioData = audioData
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            NavigationStack {
                mainContent
                    .navigationTitle("Result")
                    .toolbar { toolbarContent }
            }

            if isCopiedAlertVisible {
                copyConfirmationOverlay
                    .transition(.opacity)
                    .zIndex(2)
            }
            
            if showImageOverlay {
                imageOverlay
            }
        }
    }
}

// MARK: - View Components
private extension ResultView {
    var mainContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !images.isEmpty {
                Text("Images:")
                    .fontWeight(.bold)
                imagesScrollView
            }
            if let audioData, !audioData.isEmpty {
                Spacer()
                Text("Recordings:")
                    .fontWeight(.bold)
                audioPlaybackView(audioData: audioData)
            }
            if let summaryText, !summaryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Spacer()
                Text("Summary:")
                    .fontWeight(.bold)
                summaryView(summaryText)
            }
            if !responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Spacer()
                Text("Data:")
                    .fontWeight(.bold)
                textContentView
            }
        }
        .padding()
    }
    
    var imagesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(images.indices, id: \.self) { index in
                    thumbnailView(images[index])
                }
            }
        }
    }
    
    func thumbnailView(_ image: UIImage) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipped()
            
            expandIcon
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onTapGesture {
            selectedImage = image
            withAnimation(.easeInOut(duration: 0.2)) {
                showImageOverlay = true
            }
        }
    }
    
    var expandIcon: some View {
        Image(systemName: "arrow.down.left.and.arrow.up.right")
            .font(.system(size: 11, weight: .semibold))
            .padding(6)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .padding(6)
    }
    
    func audioPlaybackView(audioData: [Data]) -> some View {
        HStack(spacing: 12) {
            ForEach(audioData.indices, id: \.self) { index in
                AudioPlayerView(
                    audioData: audioData[index],
                    label: "Recording \(index + 1)"
                )
            }
        }
    }
    
    func summaryView(_ text: String) -> some View {
        ScrollView {
            Text(text)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
    
    var textContentView: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                Text(responseText)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 2)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
            
            Button {
                copyToClipboard()
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)
                    .background(
                        Circle()
                            .fill(Color(.secondarySystemBackground))
                    )
            }
            .padding(8)
        }
    }
    
    @ViewBuilder
    var imageOverlay: some View {
        if let selectedImage {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                fullScreenImageView(selectedImage)
            }
            .transition(.opacity.combined(with: .scale))
            .zIndex(1)
        }
    }
    
    func fullScreenImageView(_ image: UIImage) -> some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                Spacer()
                
                Text("Tap anywhere to dismiss")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    showImageOverlay = false
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Done") {
                dismiss()
            }
            .fontWeight(.bold)
        }
    }
    
    var copyConfirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()
            
            Text("Copied to clipboard")
                .font(.title3)
                .foregroundStyle(Color(.label))
                .frame(maxWidth: 280)
                .frame(height: 118)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color(.systemBackground))
                )
                .padding(.horizontal, 24)
        }
    }
}

// MARK: - Actions
private extension ResultView {
    func copyToClipboard() {
        UIPasteboard.general.string = responseText
        withAnimation(.easeInOut(duration: 0.15)) {
            isCopiedAlertVisible = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.15)) {
                isCopiedAlertVisible = false
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ResultView(
        response: """
        {
            "status": "success",
            "documentType": "ID Front",
            "extraction": {
                "name": "John Doe",
                "dob": "1990-01-01"
            }
        }
        """,
        images: [UIImage(systemName: "person.text.rectangle")].compactMap { $0 },
        summary: "Enrollment successful!\nPhrase 'Hello World' has been saved and you can now proceed with verification.\nCongrats.",
        audioData: [Data(), Data(), Data()]
    )
}
