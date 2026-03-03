import SwiftUI

struct ContentView: View {
    var viewModel: PortListViewModel

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                processCount: viewModel.processes.count,
                isRefreshing: viewModel.isRefreshing,
                onRefresh: { viewModel.refresh() }
            )

            Divider()
                .opacity(0.4)
                .padding(.horizontal, 14)

            if viewModel.processes.isEmpty {
                emptyState
                    .transition(.opacity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.processes.enumerated()), id: \.element.id) { index, process in
                            ProcessRowView(
                                process: process,
                                onKill: { viewModel.kill(process) },
                                onOpen: { viewModel.open(process) }
                            )
                            .transition(.opacity.combined(with: .offset(y: -4)))

                            if index < viewModel.processes.count - 1 {
                                Divider()
                                    .opacity(0.3)
                                    .padding(.horizontal, 22)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .scrollIndicators(.never)
                .frame(maxHeight: 400)
            }
        }
        .frame(width: 340)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "network.slash")
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(.secondary.opacity(0.35))

            Text("No active ports")
                .font(.system(size: 12.5, weight: .medium))
                .foregroundStyle(.secondary.opacity(0.6))

            Text("Start a dev server to see it here")
                .font(.system(size: 11))
                .foregroundStyle(.secondary.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }
}
