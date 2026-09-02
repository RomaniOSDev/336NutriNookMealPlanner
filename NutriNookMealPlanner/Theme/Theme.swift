import SwiftUI
import UIKit

enum Theme {
    static let plateFill = LinearGradient(
        colors: [Color("AppPrimary"), Color("AppBackground")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let warmFill = LinearGradient(
        colors: [Color("AppAccent"), Color("AppSurface")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let ringFill = LinearGradient(
        colors: [Color("AppPrimary"), Color("AppAccent"), Color("AppBackground")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func rounded(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .rounded).weight(weight)
    }
}

struct KitchenCanvas: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color("AppBackground")
                    .overlay {
                        Image("BgKitchen")
                            .resizable()
                            .scaledToFill()
                            .opacity(0.46)
                    }
                    .clipped()
                    .ignoresSafeArea()
            }
    }
}

enum KitchenKeyboard {
    static func dismiss() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct KitchenClearHost: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            var node: UIView? = uiView.superview
            var hops = 0
            while let current = node, hops < 10 {
                if current is UIWindow { break }
                current.backgroundColor = .clear
                if let table = current as? UITableView {
                    table.backgroundColor = .clear
                    table.isOpaque = false
                }
                if let scroll = current as? UIScrollView {
                    scroll.backgroundColor = .clear
                    scroll.isOpaque = false
                }
                node = current.superview
                hops += 1
            }
        }
    }
}

struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture().onEnded { KitchenKeyboard.dismiss() }
            )
    }
}

extension View {
    func kitchenCanvas() -> some View {
        modifier(KitchenCanvas())
    }

    func cheapPlateShadow() -> some View {
        shadow(color: Color("AppPrimary").opacity(0.38), radius: 5, x: 0, y: 5)
    }

    func kitchenClearChrome() -> some View {
        scrollContentBackground(.hidden)
            .background(Color.clear)
            .background(KitchenClearHost())
    }

    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTap())
    }
}

struct CookbookIndexTab: View {
    let title: String
    let isSelected: Bool
    var tilt: Double = 0
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.rounded(.caption, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 8)
                .padding(.top, 14)
                .padding(.bottom, 18)
                .background {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 14,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 18,
                        style: .continuous
                    )
                    .fill(isSelected ? Theme.plateFill : LinearGradient(colors: [Color("AppSurface"), Color("AppSurface")], startPoint: .top, endPoint: .bottom))
                }
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(Color("AppAccent").opacity(isSelected ? 0.95 : 0.35))
                        .frame(width: 28, height: 6)
                        .offset(y: -3)
                }
                .overlay {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 14,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 18,
                        style: .continuous
                    )
                    .stroke(isSelected ? Color("AppAccent") : Color("AppPrimary").opacity(0.28), lineWidth: isSelected ? 2 : 1)
                }
                .cheapPlateShadow()
                .offset(y: isSelected ? 4 : 14)
                .rotationEffect(.degrees(tilt))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .frame(minHeight: 44)
    }
}

struct StationPlateButton: View {
    let symbol: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color("AppPrimary").opacity(0.22))
                        .offset(y: 6)
                    Circle()
                        .fill(Theme.plateFill)
                    Circle()
                        .stroke(isSelected ? Color("AppAccent") : Color("AppSurface").opacity(0.55), lineWidth: isSelected ? 3 : 1)
                    Image(systemName: symbol)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                        .symbolRenderingMode(.monochrome)
                }
                .frame(width: 64, height: 64)
                .cheapPlateShadow()

                Text(title)
                    .font(Theme.rounded(.caption, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .scaleEffect(isSelected ? 1.06 : 1.0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .frame(minWidth: 44, minHeight: 44)
    }
}

struct KitchenChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.rounded(.subheadline, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(isSelected ? Theme.plateFill : LinearGradient(colors: [Color("AppSurface"), Color("AppSurface")], startPoint: .top, endPoint: .bottom))
                }
                .overlay {
                    Capsule()
                        .stroke(isSelected ? Color("AppAccent") : Color("AppPrimary").opacity(0.25), lineWidth: 1)
                }
                .cheapPlateShadow()
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}

struct KitchenEmptyState: View {
    let symbol: String
    let message: String

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color("AppPrimary").opacity(0.2))
                    .offset(y: 8)
                Circle()
                    .fill(Theme.warmFill)
                Image(systemName: symbol)
                    .font(.system(size: 36, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .frame(width: 96, height: 96)
            .cheapPlateShadow()

            Text(message)
                .font(Theme.rounded(.body, weight: .medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PlateActionButton: View {
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: symbol)
                Text(title)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .font(Theme.rounded(.headline, weight: .semibold))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background {
                Capsule()
                    .fill(Theme.plateFill)
            }
            .cheapPlateShadow()
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}

struct WashiTape: View {
    var body: some View {
        Capsule()
            .fill(Color("AppAccent").opacity(0.92))
            .frame(width: 58, height: 14)
            .rotationEffect(.degrees(-8))
            .cheapPlateShadow()
    }
}
