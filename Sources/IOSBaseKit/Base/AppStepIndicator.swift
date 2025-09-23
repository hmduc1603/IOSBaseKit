//
//  AppStepIndicator.swift
//  magiclight
//
//  Created by Dennis Hoang on 17/8/25.
//
import SwiftUI

struct AppStepIndicator: View {
    @Environment(\.theme) private var theme
    
    var color: Color? = nil
    var totalSteps: Int
    var currentStep: Int

    var body: some View {
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
