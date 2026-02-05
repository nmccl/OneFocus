//
//  ProgressBars.swift
//  OneFocus
//
//  Reusable progress bar components
//

import SwiftUI

// MARK: - Linear Progress Bar
struct LinearProgressBar: View {
    let progress: Double
    let height: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    
    init(
        progress: Double,
        height: CGFloat = 8,
        backgroundColor: Color = AppConstants.Colors.backgroundTertiary,
        foregroundColor: Color = AppConstants.Colors.primaryAccent,
        cornerRadius: CGFloat = 4
    ) {
        self.progress = max(0, min(1, progress))
        self.height = height
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .frame(height: height)
                
                // Foreground
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(foregroundColor)
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Gradient Progress Bar
struct GradientProgressBar: View {
    let progress: Double
    let height: CGFloat
    let backgroundColor: Color
    let gradientColors: [Color]
    let cornerRadius: CGFloat
    
    init(
        progress: Double,
        height: CGFloat = 8,
        backgroundColor: Color = AppConstants.Colors.backgroundTertiary,
        gradientColors: [Color] = [AppConstants.Colors.primaryAccent, AppConstants.Colors.secondaryAccent],
        cornerRadius: CGFloat = 4
    ) {
        self.progress = max(0, min(1, progress))
        self.height = height
        self.backgroundColor = backgroundColor
        self.gradientColors = gradientColors
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Circular Progress Bar
struct CircularProgressBar: View {
    let progress: Double
    let lineWidth: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    
    init(
        progress: Double,
        lineWidth: CGFloat = 8,
        backgroundColor: Color = AppConstants.Colors.backgroundTertiary,
        foregroundColor: Color = AppConstants.Colors.primaryAccent
    ) {
        self.progress = max(0, min(1, progress))
        self.lineWidth = lineWidth
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    foregroundColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
    }
}

// MARK: - Segmented Progress Bar
struct SegmentedProgressBar: View {
    let progress: Double
    let segments: Int
    let height: CGFloat
    let spacing: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    
    init(
        progress: Double,
        segments: Int = 5,
        height: CGFloat = 8,
        spacing: CGFloat = 4,
        backgroundColor: Color = AppConstants.Colors.backgroundTertiary,
        foregroundColor: Color = AppConstants.Colors.primaryAccent,
        cornerRadius: CGFloat = 4
    ) {
        self.progress = max(0, min(1, progress))
        self.segments = segments
        self.height = height
        self.spacing = spacing
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: spacing) {
                ForEach(0..<segments, id: \.self) { index in
                    let segmentProgress = Double(index + 1) / Double(segments)
                    let isActive = progress >= segmentProgress
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(isActive ? foregroundColor : backgroundColor)
                        .frame(height: height)
                }
            }
        }
        .frame(height: height)
    }
}

// MARK: - Progress Ring with Text
struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let showPercentage: Bool
    
    init(
        progress: Double,
        lineWidth: CGFloat = 12,
        size: CGFloat = 120,
        showPercentage: Bool = true
    ) {
        self.progress = max(0, min(1, progress))
        self.lineWidth = lineWidth
        self.size = size
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(AppConstants.Colors.backgroundTertiary, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppConstants.Colors.primaryAccent,
                            AppConstants.Colors.secondaryAccent
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            if showPercentage {
                VStack(spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: size * 0.25, weight: .bold))
                        .foregroundColor(AppConstants.Colors.textPrimary)
                    
                    Text("Complete")
                        .font(.system(size: size * 0.1))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Striped Progress Bar
struct StripedProgressBar: View {
    let progress: Double
    let height: CGFloat
    
    init(progress: Double, height: CGFloat = 20) {
        self.progress = max(0, min(1, progress))
        self.height = height
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(AppConstants.Colors.backgroundTertiary)
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppConstants.Colors.primaryAccent,
                                AppConstants.Colors.secondaryAccent
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(.easeInOut(duration: 0.3), value: progress)
                    .overlay(
                        GeometryReader { geo in
                            Path { path in
                                let stripeWidth: CGFloat = 8
                                let stripeSpacing: CGFloat = 8
                                let totalWidth = geo.size.width
                                
                                var x: CGFloat = -stripeWidth
                                while x < totalWidth {
                                    path.move(to: CGPoint(x: x, y: 0))
                                    path.addLine(to: CGPoint(x: x + stripeWidth, y: height))
                                    x += stripeWidth + stripeSpacing
                                }
                            }
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: height / 2))
            }
        }
        .frame(height: height)
    }
}

// MARK: - Preview
struct ProgressBars_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: AppConstants.Spacing.xl) {
                VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                    Text("Linear Progress Bar")
                        .font(.headline)
                    LinearProgressBar(progress: 0.65)
                    LinearProgressBar(progress: 0.3, height: 12)
                }
                
                VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                    Text("Gradient Progress Bar")
                        .font(.headline)
                    GradientProgressBar(progress: 0.75)
                    GradientProgressBar(progress: 0.45, height: 16)
                }
                
                VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                    Text("Circular Progress Bar")
                        .font(.headline)
                    HStack(spacing: AppConstants.Spacing.lg) {
                        CircularProgressBar(progress: 0.25)
                            .frame(width: 60, height: 60)
                        
                        CircularProgressBar(progress: 0.65)
                            .frame(width: 80, height: 80)
                        
                        CircularProgressBar(progress: 0.9)
                            .frame(width: 60, height: 60)
                    }
                }
                
                VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                    Text("Segmented Progress Bar")
                        .font(.headline)
                    SegmentedProgressBar(progress: 0.6, segments: 5)
                    SegmentedProgressBar(progress: 0.8, segments: 10)
                }
                
                VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                    Text("Progress Ring")
                        .font(.headline)
                    HStack(spacing: AppConstants.Spacing.lg) {
                        ProgressRing(progress: 0.35, size: 100)
                        ProgressRing(progress: 0.75, size: 120)
                    }
                }
                
                VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                    Text("Striped Progress Bar")
                        .font(.headline)
                    StripedProgressBar(progress: 0.55)
                    StripedProgressBar(progress: 0.85, height: 24)
                }
            }
            .padding()
        }
        .background(AppConstants.Colors.backgroundPrimary)
    }
}
