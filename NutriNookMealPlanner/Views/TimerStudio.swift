import SwiftUI

struct TimerStudio: View {
    @EnvironmentObject private var store: Store
    @State private var showAddSheet = false

    var body: some View {
        Group {
            if store.timers.isEmpty {
                KitchenEmptyState(
                    symbol: "clock.fill",
                    message: "Start your culinary journey by adding your first timer"
                )
            } else {
                TimelineView(.periodic(from: .now, by: 0.25)) { timeline in
                    timerBoard(now: timeline.date)
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            addPlate
        }
        .sheet(isPresented: $showAddSheet) {
            AddTimerSheet()
                .environmentObject(store)
        }
    }

    private func timerBoard(now: Date) -> some View {
        ScrollView {
            VStack(spacing: 22) {
                if let timer = store.selectedTimer() {
                    analogRing(timer, now: now)
                    controls(for: timer, now: now)
                }

                if store.timers.count > 1 {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Other stations")
                            .font(Theme.rounded(.headline, weight: .bold))
                            .padding(.horizontal, 4)
                        ForEach(store.timers.filter { $0.id != store.selectedTimer()?.id }) { timer in
                            miniPlate(timer, now: now)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 96)
        }
    }

    private func analogRing(_ timer: CookTimer, now: Date) -> some View {
        let left = timer.displayedRemaining(at: now)
        let progress = timer.duration > 0 ? min(1, max(0, 1 - (left / timer.duration))) : 0

        return VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color("AppSurface"))
                    .cheapPlateShadow()

                Circle()
                    .stroke(Color("AppBackground").opacity(0.9), lineWidth: 18)

                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        Theme.ringFill,
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 6) {
                    Text(timer.dishName)
                        .font(Theme.rounded(.headline, weight: .bold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 28)
                    Text(timeString(left))
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                    Text(timer.isRunning ? "On the stove" : (left <= 0 ? "Ready" : "Paused"))
                        .font(Theme.rounded(.caption, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 268, height: 268)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }

    private func controls(for timer: CookTimer, now: Date) -> some View {
        HStack(spacing: 16) {
            Button {
                store.toggleTimer(timer.id, at: now)
            } label: {
                controlPlate(
                    symbol: timer.isRunning ? "pause.fill" : "play.fill",
                    title: timer.isRunning ? "Pause" : "Resume"
                )
            }
            .buttonStyle(.plain)
            .disabled(timer.displayedRemaining(at: now) <= 0)
            .opacity(timer.displayedRemaining(at: now) <= 0 ? 0.45 : 1)

            Button {
                store.deleteTimer(timer.id)
            } label: {
                controlPlate(symbol: "trash.fill", title: "Clear")
            }
            .buttonStyle(.plain)
        }
    }

    private func controlPlate(symbol: String, title: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(Theme.plateFill)
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .frame(width: 54, height: 54)
            .cheapPlateShadow()
            Text(title)
                .font(Theme.rounded(.caption, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .frame(minWidth: 88, minHeight: 44)
    }

    private func miniPlate(_ timer: CookTimer, now: Date) -> some View {
        let left = timer.displayedRemaining(at: now)
        let progress = timer.duration > 0 ? min(1, max(0, 1 - (left / timer.duration))) : 0

        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color("AppBackground"), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(Theme.plateFill, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(timer.dishName)
                    .font(Theme.rounded(.body, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(timeString(left))
                    .font(Theme.rounded(.caption, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                store.toggleTimer(timer.id, at: now)
            } label: {
                Image(systemName: timer.isRunning ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color("AppPrimary"))
            }
            .buttonStyle(.plain)
            .frame(width: 44, height: 44)
            .accessibilityLabel(timer.isRunning ? "Pause" : "Resume")

            Button {
                store.deleteTimer(timer.id)
            } label: {
                Image(systemName: "trash.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color("AppPrimary"))
            }
            .buttonStyle(.plain)
            .frame(width: 44, height: 44)
            .accessibilityLabel("Clear timer")
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("AppSurface"))
        }
        .cheapPlateShadow()
        .contentShape(Rectangle())
        .onTapGesture {
            store.selectedTimerID = timer.id
        }
    }

    private var addPlate: some View {
        Button {
            showAddSheet = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color("AppPrimary").opacity(0.25))
                    .offset(y: 5)
                Circle()
                    .fill(Theme.plateFill)
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .frame(width: 56, height: 56)
            .cheapPlateShadow()
        }
        .buttonStyle(.plain)
        .padding(.trailing, 22)
        .padding(.bottom, 18)
        .accessibilityLabel("Add cook timer")
    }

    private func timeString(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded()))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct AddTimerSheet: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var dishName = ""
    @State private var minutes = 20
    @State private var showValidation = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Dish name")
                    .font(Theme.rounded(.headline, weight: .bold))
                TextField("What is on the stove?", text: $dishName)
                    .font(Theme.rounded(.body))
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color("AppSurface"))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(showValidation ? Color("AppPrimary") : Color("AppPrimary").opacity(0.2), lineWidth: showValidation ? 2 : 1)
                    }

                if showValidation {
                    Text("Name the dish and keep the time above zero.")
                        .font(Theme.rounded(.caption, weight: .semibold))
                        .foregroundStyle(.primary)
                }

                Text("Minutes")
                    .font(Theme.rounded(.headline, weight: .bold))
                Stepper(value: $minutes, in: 1...180) {
                    Text("\(minutes) min")
                        .font(Theme.rounded(.title3, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color("AppSurface"))
                }

                Text("Presets")
                    .font(Theme.rounded(.headline, weight: .bold))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(TimerPreset.all) { preset in
                            KitchenChip(
                                title: "\(preset.name) \(preset.minutes)",
                                isSelected: dishName == preset.name && minutes == preset.minutes
                            ) {
                                dishName = preset.name
                                minutes = preset.minutes
                                showValidation = false
                            }
                        }
                    }
                }

                Spacer()

                PlateActionButton(title: "Start timer", symbol: "timer") {
                    if store.addManualTimer(dishName: dishName, minutes: minutes) {
                        dismiss()
                    } else {
                        showValidation = true
                    }
                }
            }
            .padding(20)
            .contentShape(Rectangle())
            .dismissKeyboardOnTap()
            .scrollDismissesKeyboard(.immediately)
            .kitchenCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New cook timer")
                        .font(Theme.rounded(.headline, weight: .bold))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(Theme.rounded(.body, weight: .semibold))
                }
            }
        }
    }
}
