//
//  AppVideoPlayerView.swift
//  magiclight
//
//  Created by Dennis Hoang on 17/8/25.
//

import _AVKit_SwiftUI
import SwiftUI

struct AppVideoPlayerView: View {
    @Environment(\.theme) private var theme
    @State private var player: AVPlayer?

    var url: URL
    var isLoop: Bool = false
    var proxy: GeometryProxy
    var enableOverlayControls: Bool = false
    var enableScaleToFit: Bool = false
    var cornerRadius: CGFloat = 12

    private func initPlayer(url: URL) {
        player = AVPlayer(url: url)
        player?.volume = 1.0
        player?.isMuted = false

        if isLoop {
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                   object: player?.currentItem,
                                                   queue: .main)
            { _ in
                player?.seek(to: .zero)
                player?.play()
            }
        }
    }

    var body: some View {
        VStack {
            if let player = player {
                if enableScaleToFit {
                    VideoPlayer(player: player)
                        .ignoresSafeArea()
                        .scaledToFit()
                        .cornerRadius(cornerRadius)
                        .onAppear {
                            player.play()
                        }
                        .allowsHitTesting(enableOverlayControls)
                } else {
                    VideoPlayer(player: player)
                        .ignoresSafeArea()
                        .frame(width: proxy.size.height * 16 / 9, height: proxy.size.height)
                        .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                        .cornerRadius(cornerRadius)
                        .onAppear {
                            player.play()
                        }
                        .allowsHitTesting(enableOverlayControls)
                }
            }
        }
        .onChange(of: url) { _, newUrl in
            initPlayer(url: newUrl)
        }
        .onAppear {
            initPlayer(url: self.url)
        }
        .onDisappear {
            player?.pause()
            if let currentItem = player?.currentItem {
                NotificationCenter.default.removeObserver(self,
                                                          name: .AVPlayerItemDidPlayToEndTime,
                                                          object: currentItem)
            }
            player = nil
        }
    }
}
