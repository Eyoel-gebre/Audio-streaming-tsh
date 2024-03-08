//
//  ContentView.swift
//  Audio-streaming
//
//  Created by Eyoel Gebre on 2/27/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    var audioEngine: AVAudioEngine
    var inputNode: AVAudioInputNode
    var playerNode: AVAudioPlayerNode
    var bufferDuration: AVAudioFrameCount
    
    init() {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine.inputNode
        playerNode = AVAudioPlayerNode()
        bufferDuration = AVAudioFrameCount(352)
    }
    
    func startStreaming() -> Void {
        // Configuration the session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .measurement)
            // TODO: Adjust to work with TSH model
            try audioSession.setPreferredSampleRate(44100)
            // 8ms buffers
            try audioSession.setPreferredIOBufferDuration(0.008)
            try audioSession.setActive(true)
        } catch {
            print("Audio Session error: \(error)")
        }
        
        // Set the playerNode to immedietly queue/play the recorded buffer
        inputNode.installTap(onBus: 0, bufferSize: bufferDuration, format: inputNode.inputFormat(forBus: 0)) { (buffer, when) in
            // Schedule the buffer for playback
            playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        }
        
        // Start the engine
        do {
            audioEngine.attach(playerNode)
            audioEngine.connect(playerNode, to: audioEngine.outputNode, format: inputNode.inputFormat(forBus: 0))
            
            try audioEngine.start()
            playerNode.play()
        } catch {
            print("Audio Engine start error: \(error)")
        }
        
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .onAppear {
                    self.startStreaming()
                }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
