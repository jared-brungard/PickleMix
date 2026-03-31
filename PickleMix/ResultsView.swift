import SwiftUI

struct ResultsView: View {
    let manager: TournamentManager

    var body: some View {
        let results = manager.results

        Group {
            if results.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "trophy")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No completed matches yet.")
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    Section {
                        ForEach(Array(results.enumerated()), id: \.element.id) { rank, result in
                            HStack {
                                Text("\(rank + 1).")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .frame(width: 28, alignment: .leading)

                                Text(result.name)
                                    .fontWeight(.semibold)

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(result.wins)W – \(result.losses)L")
                                        .font(.subheadline)
                                    Text(result.pointDiff >= 0 ? "+\(result.pointDiff)" : "\(result.pointDiff)")
                                        .font(.caption)
                                        .foregroundColor(result.pointDiff >= 0 ? .green : .red)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    } header: {
                        HStack {
                            Text("Player")
                            Spacer()
                            Text("W – L  |  Diff")
                                .font(.caption)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
    }
}
