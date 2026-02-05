//
//  BottomSheet.swift
//  OneFocus
//
//  Reusable bottom sheet component
//

import SwiftUI

// MARK: - Bottom Sheet
struct BottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content
    let height: CGFloat?
    let showHandle: Bool
    
    @State private var offset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    
    init(
        isPresented: Binding<Bool>,
        height: CGFloat? = nil,
        showHandle: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.content = content()
        self.height = height
        self.showHandle = showHandle
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                // Background overlay
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismiss()
                    }
                    .transition(.opacity)
                
                // Sheet content
                VStack(spacing: 0) {
                    if showHandle {
                        handle
                    }
                    
                    content
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                }
                .background(AppConstants.Colors.cardBackground)
                .cornerRadius(AppConstants.CornerRadius.large, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: -3)
                .offset(y: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let translation = value.translation.height
                            offset = max(0, translation + lastOffset)
                        }
                        .onEnded { value in
                            let translation = value.translation.height
                            
                            if translation > 100 {
                                dismiss()
                            } else {
                                withAnimation(.spring()) {
                                    offset = 0
                                    lastOffset = 0
                                }
                            }
                        }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(), value: isPresented)
    }
    
    private var handle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(AppConstants.Colors.textTertiary.opacity(0.3))
            .frame(width: 40, height: 6)
            .padding(.vertical, AppConstants.Spacing.md)
    }
    
    private func dismiss() {
        withAnimation(.spring()) {
            isPresented = false
            offset = 0
            lastOffset = 0
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RectCorner: OptionSet {
    let rawValue: Int
    
    static let topLeft = RectCorner(rawValue: 1 << 0)
    static let topRight = RectCorner(rawValue: 1 << 1)
    static let bottomLeft = RectCorner(rawValue: 1 << 2)
    static let bottomRight = RectCorner(rawValue: 1 << 3)
    
    static let allCorners: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: RectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let tl = corners.contains(.topLeft) ? radius : 0
        let tr = corners.contains(.topRight) ? radius : 0
        let bl = corners.contains(.bottomLeft) ? radius : 0
        let br = corners.contains(.bottomRight) ? radius : 0
        
        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        if tr > 0 {
            path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
                       radius: tr,
                       startAngle: Angle(degrees: -90),
                       endAngle: Angle(degrees: 0),
                       clockwise: false)
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        if br > 0 {
            path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br),
                       radius: br,
                       startAngle: Angle(degrees: 0),
                       endAngle: Angle(degrees: 90),
                       clockwise: false)
        }
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        if bl > 0 {
            path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl),
                       radius: bl,
                       startAngle: Angle(degrees: 90),
                       endAngle: Angle(degrees: 180),
                       clockwise: false)
        }
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        if tl > 0 {
            path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl),
                       radius: tl,
                       startAngle: Angle(degrees: 180),
                       endAngle: Angle(degrees: 270),
                       clockwise: false)
        }
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Detent Bottom Sheet
struct DetentBottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let detents: [Detent]
    @State private var currentDetent: Detent
    let content: Content
    
    enum Detent: Equatable {
        case small
        case medium
        case large
        case custom(CGFloat)
        
        func height(screenHeight: CGFloat) -> CGFloat {
            switch self {
            case .small:
                return screenHeight * 0.25
            case .medium:
                return screenHeight * 0.5
            case .large:
                return screenHeight * 0.9
            case .custom(let height):
                return height
            }
        }
    }
    
    init(
        isPresented: Binding<Bool>,
        detents: [Detent] = [.medium, .large],
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.detents = detents
        self._currentDetent = State(initialValue: detents.first ?? .medium)
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if isPresented {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isPresented = false
                            }
                        }
                    
                    VStack(spacing: 0) {
                        handle
                        
                        content
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: currentDetent.height(screenHeight: geometry.size.height))
                    .background(AppConstants.Colors.cardBackground)
                    .cornerRadius(AppConstants.CornerRadius.large, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: -3)
                    .transition(.move(edge: .bottom))
                }
            }
            .animation(.spring(), value: isPresented)
        }
    }
    
    private var handle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(AppConstants.Colors.textTertiary.opacity(0.3))
            .frame(width: 40, height: 6)
            .padding(.vertical, AppConstants.Spacing.md)
            .onTapGesture {
                cycleDetent()
            }
    }
    
    private func cycleDetent() {
        guard let currentIndex = detents.firstIndex(of: currentDetent) else { return }
        let nextIndex = (currentIndex + 1) % detents.count
        
        withAnimation(.spring()) {
            currentDetent = detents[nextIndex]
        }
    }
}

// MARK: - Preview
struct BottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetPreviewContainer()
    }
}

struct BottomSheetPreviewContainer: View {
    @State private var showSheet = false
    
    var body: some View {
        ZStack {
            VStack {
                Button("Show Bottom Sheet") {
                    showSheet = true
                }
                .primaryButtonStyle()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppConstants.Colors.backgroundPrimary)
            
            BottomSheet(isPresented: $showSheet, height: 300) {
                VStack(spacing: AppConstants.Spacing.lg) {
                    Text("Bottom Sheet Content")
                        .font(.system(size: AppConstants.FontSize.title, weight: .bold))
                    
                    Text("This is a reusable bottom sheet component")
                        .font(.system(size: AppConstants.FontSize.body))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                    
                    Button("Close") {
                        showSheet = false
                    }
                    .primaryButtonStyle()
                }
                .padding(AppConstants.Spacing.lg)
            }
        }
        .environmentObject(UserSettings.sample)
    }
}
