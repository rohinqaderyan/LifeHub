//
//  ViewModifiers.swift
//  LifeHub
//
//  Reusable SwiftUI view modifiers for animations, transitions, and effects
//

import SwiftUI

// MARK: - Animation Modifiers

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

extension View {
    func shake(trigger: Int) -> some View {
        self.modifier(ShakeEffect(animatableData: CGFloat(trigger)))
    }
}

// MARK: - Bounce Animation

struct BounceAnimation: ViewModifier {
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 5)) {
                    scale = 1.2
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.interpolatingSpring(stiffness: 300, damping: 5)) {
                        scale = 1.0
                    }
                }
            }
    }
}

extension View {
    func bounceOnAppear() -> some View {
        self.modifier(BounceAnimation())
    }
}

// MARK: - Card Style Modifier

struct CardStyle: ViewModifier {
    var backgroundColor: Color = Color(.systemBackground)
    var cornerRadius: CGFloat = 16
    var shadowRadius: CGFloat = 8
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: 4)
    }
}

extension View {
    func cardStyle(
        backgroundColor: Color = Color(.systemBackground),
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 8
    ) -> some View {
        self.modifier(CardStyle(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius
        ))
    }
}

// MARK: - Shimmer Effect

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    var duration: Double = 1.5
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false)) {
                    phase = 500
                }
            }
    }
}

extension View {
    func shimmer(duration: Double = 1.5) -> some View {
        self.modifier(ShimmerEffect(duration: duration))
    }
}

// MARK: - Pulse Animation

struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false
    var minScale: CGFloat = 0.95
    var maxScale: CGFloat = 1.05
    var duration: Double = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? maxScale : minScale)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
    }
}

extension View {
    func pulse(minScale: CGFloat = 0.95, maxScale: CGFloat = 1.05, duration: Double = 1.0) -> some View {
        self.modifier(PulseAnimation(minScale: minScale, maxScale: maxScale, duration: duration))
    }
}

// MARK: - Rotate Animation

struct RotateAnimation: ViewModifier {
    @State private var isRotating = false
    var duration: Double = 2.0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
            .onAppear {
                withAnimation(
                    Animation.linear(duration: duration)
                        .repeatForever(autoreverses: false)
                ) {
                    isRotating = true
                }
            }
    }
}

extension View {
    func rotate(duration: Double = 2.0) -> some View {
        self.modifier(RotateAnimation(duration: duration))
    }
}

// MARK: - Gradient Border

struct GradientBorder: ViewModifier {
    var gradient: LinearGradient
    var lineWidth: CGFloat = 2
    var cornerRadius: CGFloat = 8
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(gradient, lineWidth: lineWidth)
            )
    }
}

extension View {
    func gradientBorder(
        gradient: LinearGradient,
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 8
    ) -> some View {
        self.modifier(GradientBorder(
            gradient: gradient,
            lineWidth: lineWidth,
            cornerRadius: cornerRadius
        ))
    }
}

// MARK: - Conditional Modifier

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Loading Modifier

struct LoadingModifier: ViewModifier {
    var isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .blur(radius: isLoading ? 3 : 0)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                    .scaleEffect(1.5)
            }
        }
    }
}

extension View {
    func loading(_ isLoading: Bool) -> some View {
        self.modifier(LoadingModifier(isLoading: isLoading))
    }
}

// MARK: - Corner Radius Specific Corners

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Haptic Feedback

extension View {
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
}

// MARK: - Animated Gradient Background

struct AnimatedGradientBackground: ViewModifier {
    @State private var animateGradient = false
    var colors: [Color]
    
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: colors,
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint: animateGradient ? .bottomTrailing : .topTrailing
                )
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
            )
    }
}

extension View {
    func animatedGradientBackground(colors: [Color]) -> some View {
        self.modifier(AnimatedGradientBackground(colors: colors))
    }
}

// MARK: - Slide In Animation

enum SlideDirection {
    case left, right, top, bottom
}

struct SlideInAnimation: ViewModifier {
    var direction: SlideDirection
    var duration: Double = 0.5
    @State private var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(x: direction == .left || direction == .right ? offset : 0,
                   y: direction == .top || direction == .bottom ? offset : 0)
            .onAppear {
                let initialOffset: CGFloat = {
                    switch direction {
                    case .left: return -UIScreen.main.bounds.width
                    case .right: return UIScreen.main.bounds.width
                    case .top: return -UIScreen.main.bounds.height
                    case .bottom: return UIScreen.main.bounds.height
                    }
                }()
                
                offset = initialOffset
                
                withAnimation(.spring(response: duration, dampingFraction: 0.7)) {
                    offset = 0
                }
            }
    }
}

extension View {
    func slideIn(from direction: SlideDirection, duration: Double = 0.5) -> some View {
        self.modifier(SlideInAnimation(direction: direction, duration: duration))
    }
}

// MARK: - Typewriter Effect

struct TypewriterEffect: ViewModifier {
    let text: String
    @State private var displayedText = ""
    var speed: Double = 0.05
    
    func body(content: Content) -> some View {
        Text(displayedText)
            .onAppear {
                displayedText = ""
                var currentIndex = 0
                Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { timer in
                    if currentIndex < text.count {
                        let index = text.index(text.startIndex, offsetBy: currentIndex)
                        displayedText.append(text[index])
                        currentIndex += 1
                    } else {
                        timer.invalidate()
                    }
                }
            }
    }
}

// MARK: - Skeleton Loading

struct SkeletonLoading: ViewModifier {
    @State private var opacity: Double = 0.3
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(8)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    opacity = 0.6
                }
            }
    }
}

extension View {
    func skeleton() -> some View {
        self.modifier(SkeletonLoading())
    }
}

// MARK: - Badge Modifier

struct BadgeModifier: ViewModifier {
    var count: Int
    var color: Color = .red
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content
            
            if count > 0 {
                Text("\(count)")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(color)
                    .clipShape(Circle())
                    .offset(x: 8, y: -8)
            }
        }
    }
}

extension View {
    func badge(_ count: Int, color: Color = .red) -> some View {
        self.modifier(BadgeModifier(count: count, color: color))
    }
}
