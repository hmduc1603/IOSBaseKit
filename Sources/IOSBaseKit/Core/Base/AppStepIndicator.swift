//
//  AppStepIndicator.swift
//  magiclight
//
//  Created by Dennis Hoang on 17/8/25.
//
import SwiftUI

public struct AppStepIndicator: View {
    @Environment(\.theme) private var theme

    public var color: Color? = nil
    public var totalSteps: Int
    public var currentStep: Int
    
    public init(color: Color? = nil, totalSteps: Int, currentStep: Int) {
        self.color = color
        self.totalSteps = totalSteps
        self.currentStep = currentStep
    }

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(1 ... totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? color ?? theme.btnColor : theme.cardColor)
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }
}
