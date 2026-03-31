import SwiftUI

enum RoundSelection {
    case everyoneOnce
    case custom
}

struct ConfigurationView: View {
    let format: TournamentFormat // Assuming you have this enum defined elsewhere
    
    @State private var countString: String = ""
    @State private var roundSelection: RoundSelection = .everyoneOnce

    // 1. Removed the default "4" so it is empty by default
    @State private var customRoundsString: String = ""
    @State private var keepScores: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text(format == .fixedTeams ? "How many teams?" : "How many players?")
                    .font(.title2)
                    .bold()
                
                if format != .fixedTeams {
                    HStack(spacing: 15) {
                        ForEach([4, 8, 12, 16], id: \.self) { num in
                            NavigationLink(destination: PlayerEntryView(format: format, count: num, customRounds: selectedRounds, keepScores: keepScores)) {
                                Text("\(num)")
                                    .fontWeight(.bold)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            // Prevent bypassing the rounds requirement using the quick-select buttons
                            .disabled(format == .mixedDoubles && (Int(customRoundsString) ?? 0) <= 0)
                        }
                    }
                }
                
                VStack(spacing: 10) {
                    Text(format == .fixedTeams ? "Enter custom number of teams:" : "Or enter custom amount:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter custom amount", text: $countString)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 50)
                }
                
                // 2. Updated to show Round Setup for BOTH Individuals and Mixed Doubles
                if format == .individuals || format == .mixedDoubles {
                    Divider().padding(.horizontal, 40)
                    
                    VStack(spacing: 15) {
                        Text("Round Setup")
                            .font(.headline)
                        
                        // Only show the Segmented Picker for Individuals
                        if format == .individuals {
                            Picker("Rounds", selection: $roundSelection) {
                                Text("Play With Everyone Once").tag(RoundSelection.everyoneOnce)
                                Text("Custom Amount").tag(RoundSelection.custom)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 30)
                        }
                        
                        // Show the custom rounds text field for Mixed Doubles OR if Custom is selected for Individuals
                        if format == .mixedDoubles || (format == .individuals && roundSelection == .custom) {
                            TextField("How many rounds?", text: $customRoundsString)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 80)
                        }
                    }
                }
                
                Divider().padding(.horizontal, 40)

                Toggle("Keep Scores", isOn: $keepScores)
                    .padding(.horizontal, 50)
                    .tint(.green)

                NavigationLink(destination: PlayerEntryView(format: format, count: Int(countString) ?? 4, customRounds: selectedRounds, keepScores: keepScores)) {
                    Text("Enter Names for Custom Setup")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!isValid)
                .padding(.horizontal, 50)
                .padding(.top, 10)
            }
            .padding(.vertical)
        }
        .navigationTitle("Setup")
    }
    
    // 3. Update the calculated variable to include Mixed Doubles
    var selectedRounds: Int? {
        if format == .mixedDoubles {
            return Int(customRoundsString)
        }
        if format == .individuals && roundSelection == .custom {
            return Int(customRoundsString)
        }
        return nil
    }
    
    // 4. Update the validation logic
    var isValid: Bool {
        // making sure # of players works for how round robins will be made
        guard let value = Int(countString), value > 0 else { return false }
        if format == .mixedDoubles && value % 4 != 0 { return false }
        if format == .fixedTeams && value < 2 { return false }
        if format == .individuals && value < 4 { return false }
        
        // Validate custom rounds string for Individuals
        if format == .individuals && roundSelection == .custom {
            guard let rounds = Int(customRoundsString), rounds > 0 else { return false }
        }
        
        // Validate custom rounds string for Mixed Doubles
        if format == .mixedDoubles {
            guard let rounds = Int(customRoundsString), rounds > 0 else { return false }
        }
        
        return true
    }
}
