import SwiftUI

struct FormatSelectionView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // Logo Area
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 4)

                    Text("Select Tournament Style")
                        .font(.title2)
                        .bold()

                    // Three cards for selecting what game mode
                    FormatCard(
                        title: "Individuals",
                        imageName: "indi",
                        color: .green,
                        destination: ConfigurationView(format: .individuals)
                    )

                    FormatCard(
                        title: "Fixed Teams",
                        imageName: "fixed",
                        color: .blue,
                        destination: ConfigurationView(format: .fixedTeams)
                    )

                    FormatCard(
                        title: "Mixed Doubles",
                        imageName: "mixed",
                        color: .purple,
                        destination: ConfigurationView(format: .mixedDoubles)
                    )

                    NavigationLink(destination: MyGroupsView()) {
                        HStack(spacing: 10) {
                            Image(systemName: "person.3.fill")
                            Text("My Groups")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(15)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }
}

// creates format of the cards
struct FormatCard<Destination: View>: View {
    let title: String
    let imageName: String
    let color: Color
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 80)
                    .padding(8)
                    .background(color.opacity(0.15))
                    .cornerRadius(12)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)

                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(15)
        }
        .buttonStyle(.plain)
    }
}
