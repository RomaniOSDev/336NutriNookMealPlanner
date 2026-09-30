import SwiftUI
import UIKit

enum Theme {
    static let dockClearance: CGFloat = 108

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
                NookBackdrop()
            }
    }
}

struct NookBackdrop: View {
    var body: some View {
        Color("AppBackground")
            .overlay {
                GeometryReader { geo in
                    ZStack {
                        Circle()
                            .fill(Color("AppPrimary").opacity(0.12))
                            .frame(width: geo.size.width * 0.72)
                            .offset(x: geo.size.width * 0.28, y: -geo.size.height * 0.12)
                        Circle()
                            .fill(Color("AppAccent").opacity(0.1))
                            .frame(width: geo.size.width * 0.5)
                            .offset(x: -geo.size.width * 0.22, y: geo.size.height * 0.38)
                    }
                }
            }
            .clipped()
            .ignoresSafeArea()
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

struct HideAppDock: ViewModifier {
    @EnvironmentObject private var store: Store

    func body(content: Content) -> some View {
        content
            .onAppear { store.dockHiddenCount += 1 }
            .onDisappear { store.dockHiddenCount = max(0, store.dockHiddenCount - 1) }
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

    func hidesAppDock() -> some View {
        modifier(HideAppDock())
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

struct SurfaceCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color("AppSurface").opacity(0.94))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color("AppPrimary").opacity(0.22), lineWidth: 1)
            }
            .cheapPlateShadow()
    }
}

struct DishKindBadge: View {
    let kind: DishKind

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: kind.symbol)
            Text(kind.title.uppercased())
        }
        .font(Theme.rounded(.caption, weight: .bold))
        .foregroundStyle(.primary)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background {
            Capsule().fill(Color("AppSurface").opacity(0.92))
        }
    }
}

struct PercentRing: View {
    let percent: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("AppPrimary").opacity(0.22), lineWidth: 6)
            Circle()
                .trim(from: 0, to: CGFloat(min(max(percent, 0), 100)) / 100)
                .stroke(Theme.ringFill, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(percent)%")
                .font(Theme.rounded(.caption, weight: .bold))
                .foregroundStyle(.primary)
        }
        .frame(width: 52, height: 52)
    }
}
