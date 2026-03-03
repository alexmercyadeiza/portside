import SwiftUI

struct HeaderView: View {
    let processCount: Int
    let isRefreshing: Bool
    let onRefresh: () -> Void

    @State private var refreshHovered = false
    @State private var quitHovered = false

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Portside")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary.opacity(0.85))

                Text("\(processCount) active port\(processCount == 1 ? "" : "s")")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary.opacity(0.7))
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: onRefresh) {
                    ZStack {
                        if isRefreshing {
                            ProgressView()
                                .controlSize(.small)
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 11.5, weight: .medium))
                                .foregroundStyle(.secondary.opacity(refreshHovered ? 0.9 : 0.5))
                        }
                    }
                    .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                .onHover { refreshHovered = $0 }

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Text("Quit")
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundStyle(.secondary.opacity(quitHovered ? 0.9 : 0.5))
                }
                .buttonStyle(.plain)
                .onHover { quitHovered = $0 }
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .animation(.easeInOut(duration: 0.15), value: refreshHovered)
        .animation(.easeInOut(duration: 0.15), value: quitHovered)
    }
}
