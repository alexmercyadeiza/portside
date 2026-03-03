import SwiftUI

struct ProcessRowView: View {
    let process: PortProcess
    let onKill: () -> Void
    let onOpen: () -> Void

    @State private var isHovered = false
    @State private var killHovered = false
    @State private var openHovered = false
    @State private var swipeOffset: CGFloat = 0
    @State private var swipeOpacity: Double = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 7, height: 7)
                    .shadow(color: .green.opacity(0.4), radius: 3, y: 0)

                Text(process.projectName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary.opacity(0.85))
                    .lineLimit(1)

                Spacer()

                HStack(spacing: 6) {
                    Button(action: performKill) {
                        Text("Kill")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.red.opacity(killHovered ? 0.95 : 0.7))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(killHovered ? 0.15 : 0.08))
                            )
                    }
                    .buttonStyle(.plain)
                    .onHover { killHovered = $0 }

                    Button(action: onOpen) {
                        Text("Open")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary.opacity(openHovered ? 0.95 : 0.7))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.primary.opacity(openHovered ? 0.1 : 0.06))
                            )
                    }
                    .buttonStyle(.plain)
                    .onHover { openHovered = $0 }
                }
                .opacity(isHovered ? 1 : 0.45)
            }

            HStack(spacing: 0) {
                if let branch = process.gitBranch {
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.triangle.branch")
                            .font(.system(size: 9))
                        Text(branch)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: 140, alignment: .leading)

                    Text("  ")
                }

                Text(":\(process.port)")
                    .fontDesign(.monospaced)

                Spacer()

                Text(process.uptimeString)
            }
            .font(.system(size: 11))
            .foregroundStyle(.secondary.opacity(0.65))
            .padding(.leading, 15)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.primary.opacity(isHovered ? 0.06 : 0))
                .padding(.horizontal, 6)
        )
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .offset(x: swipeOffset)
        .opacity(swipeOpacity)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .animation(.easeInOut(duration: 0.12), value: killHovered)
        .animation(.easeInOut(duration: 0.12), value: openHovered)
    }

    private func performKill() {
        withAnimation(.easeIn(duration: 0.3)) {
            swipeOffset = -400
            swipeOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onKill()
        }
    }
}
