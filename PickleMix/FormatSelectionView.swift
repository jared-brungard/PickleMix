import SwiftUI

struct FormatSelectionView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // MARK: - Hero Header
                    ZStack {
                        LinearGradient(
                            colors: [Color.green, Color.teal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )

                        VStack(spacing: 10) {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)

                            Text("PickleMix")
                                .font(.system(size: 36, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)

                            Text("Select a game format to get started")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(.vertical, 36)
                    }

                    // MARK: - Format Cards
                    VStack(spacing: 14) {
                        FormatCard(
                            title: "Individuals",
                            subtitle: "Partners rotate each round",
                            systemImage: "person.2.fill",
                            color: .green,
                            destination: ConfigurationView(format: .individuals)
                        )

                        FormatCard(
                            title: "Fixed Teams",
                            subtitle: "Same partner all session",
                            systemImage: "person.2.circle.fill",
                            color: .blue,
                            destination: ConfigurationView(format: .fixedTeams)
                        )

                        FormatCard(
                            title: "Mixed Doubles",
                            subtitle: "Balanced men & women pairings",
                            systemImage: "figure.mixed.cardio",
                            color: .purple,
                            destination: ConfigurationView(format: .mixedDoubles)
                        )

                        FormatCard(
                            title: "My Groups",
                            subtitle: "Manage your saved player groups",
                            systemImage: "person.3.fill",
                            color: .orange,
                            destination: MyGroupsView()
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
    }
}

// MARK: - Format Card
struct FormatCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {

                // Icon bubble
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(color.gradient)
                        .frame(width: 60, height: 60)

                    Image(systemName: systemImage)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white)
                }
                .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 4)

                // Text
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(16)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
