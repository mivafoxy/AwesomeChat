//
//  ChatTyping.swift
//  
//
//  Created by Илья Малахов on 26.03.2025.
//

import SwiftUI
import MRDSKit

public struct ChatTyping: View {
    
    // MARK: - Text and font properties
    
    private let typoText: String
    private let dotCount = 3
    private let baseFontSize: CGFloat = 12
    
    // MARK: - Animation properties
    
    private let waveDuration: Double = 1.2
    private let returnDuration: Double = 0.6
    private let pauseDuration: Double = 0.4
    private var period: Double { waveDuration + returnDuration + pauseDuration }
    
    public init(typoText: String) {
        self.typoText = typoText
    }
    
    public var body: some View {
        HStack(spacing: .zero) {
            Text("🧑🏻‍💻")
                .font(fontStyle: .caption1)
                .foregroundColor(color: MRTextColor.colorTextCaption)
            Text(typoText)
                .font(fontStyle: .caption1)
                .foregroundColor(color: MRTextColor.colorTextCaption)
            animatedDots
        }
    }
    
    private var animatedDots: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 120.0)) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate
            let cycle = computeCycleInfo(time: now)
            
            HStack(spacing: .zero) {
                ForEach(0..<dotCount, id: \.self) { i in
                    let (scale, opacity) = computeScaleAndOpacity(for: i, in: cycle)
                    
                    Text(".")
                        .font(.system(size: baseFontSize))
                        .foregroundColor(color: MRTextColor.colorTextCaption)
                        .scaleEffect(scale)
                        .opacity(opacity)
                }
            }
        }
    }
    
    // MARK: - Math + State
    
    private struct CycleInfo {
        let waveCenter: Double
        let returnProgress: Double
        let isPausePhase: Bool
    }
    
    private func computeCycleInfo(time: TimeInterval) -> CycleInfo {
        let cycleProgress = time.truncatingRemainder(dividingBy: period)
        
        if cycleProgress < waveDuration {
            // Фаза "хлыста"
            let progress = cycleProgress / waveDuration
            let waveCenter = progress * Double(dotCount - 1)
            return CycleInfo(waveCenter: waveCenter, returnProgress: 0, isPausePhase: false)
            
        } else if cycleProgress < waveDuration + returnDuration {
            // Фаза "возврата"
            let waveCenter = Double(dotCount - 1)
            let returnProgress = (cycleProgress - waveDuration) / returnDuration
            return CycleInfo(waveCenter: waveCenter, returnProgress: min(max(returnProgress, 0), 1), isPausePhase: false)
            
        } else {
            // Пауза
            let waveCenter = Double(dotCount - 1)
            return CycleInfo(waveCenter: waveCenter, returnProgress: 1, isPausePhase: true)
        }
    }
    
    private func computeScaleAndOpacity(for index: Int, in cycle: CycleInfo) -> (CGFloat, Double) {
        let i = Double(index)
        let rawDistance = i - cycle.waveCenter
        let distanceSquared = rawDistance * rawDistance
        let multiplier = distanceSquared * 4
        let expComponent = exp(-multiplier)
        
        var scale = 1.0 + 0.5 * expComponent
        var opacity = 0.6 + 0.4 * expComponent
        
        if index == dotCount - 1 {
            if cycle.returnProgress > 0 {
                let eased = 1.0 - cycle.returnProgress
                scale = 1.0 + 0.5 * eased
                opacity = 0.6 + 0.4 * eased
            }
            
            if cycle.isPausePhase {
                scale = 1.0
                opacity = 0.6
            }
        }
        
        return (scale, opacity)
    }
}
