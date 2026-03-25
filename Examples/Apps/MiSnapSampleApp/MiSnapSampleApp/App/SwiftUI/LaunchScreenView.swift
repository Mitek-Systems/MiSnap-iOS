//
//  LaunchScreenView.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI
import MiSnap

struct LaunchScreenView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }
    
    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
    }
    
    var body: some View {
        ZStack {
            Color("MitekNavyColor")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()

                Image("MitekLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 120)
                
                Spacer()
                
                Text("MiSnap \(MiSnap.version())\nApp v\(appVersion) (\(appBuild))")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
