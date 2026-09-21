import SwiftUI

struct Computer: Identifiable {
    let id = UUID()
    var name: String
    var location: String
    var isAvailable: Bool
}

struct ContentView: View {
    @State private var computers: [Computer] = [
        Computer(name: "PC01", location: "Lab A", isAvailable: true),
        Computer(name: "PC02", location: "Lab A", isAvailable: true),
        Computer(name: "PC03", location: "Lab B", isAvailable: false),
        Computer(name: "PC04", location: "Lab B", isAvailable: true),
        Computer(name: "PC05", location: "Lab C", isAvailable: true)
    ]

    var body: some View {
        NavigationStack {
            HomeView(computers: $computers)
        }
    }
}

struct HomeView: View {
    @Binding var computers: [Computer]

    @State private var deleteTarget: Computer?
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Image(systemName: "desktopcomputer")
                    .font(.system(size: 42))
                    .foregroundStyle(.blue)

                Text("Computer Lab")
                    .font(.title2.bold())
                    .foregroundStyle(.blue)

                Text("Manage computers easily")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 10)
            .padding(.bottom, 8)

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(computers) { computer in
                        ComputerRow(
                            computer: computer,
                            onToggle: {
                                toggleStatus(computer)
                            },
                            onDelete: {
                                deleteTarget = computer
                                showDeleteAlert = true
                            }
                        )
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
            }

            NavigationLink {
                AddComputerView(computers: $computers)
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Computer")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Color.blue,
                    in: RoundedRectangle(cornerRadius: 10)
                )
            }
            .padding(.horizontal, 15)

            Text("Total computers: \(computers.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.vertical, 10)
        }
        .navigationTitle("Computer Lab")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    NavigationLink {
                        AddComputerView(computers: $computers)
                    } label: {
                        Label("Add Computer", systemImage: "plus")
                    }

                    NavigationLink {
                        CheckComputerView(computers: computers)
                    } label: {
                        Label("Check Computer", systemImage: "magnifyingglass")
                    }

                    NavigationLink {
                        StatisticsView(computers: computers)
                    } label: {
                        Label("Statistics", systemImage: "chart.bar")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert(
            "Delete Computer?",
            isPresented: $showDeleteAlert
        ) {
            Button("Cancel", role: .cancel) {
                deleteTarget = nil
            }

            Button("Delete", role: .destructive) {
                if let computer = deleteTarget {
                    computers.removeAll {
                        $0.id == computer.id
                    }
                }

                deleteTarget = nil
            }
        } message: {
            Text(
                "Are you sure you want to delete \(deleteTarget?.name ?? "")?"
            )
        }
    }

    private func toggleStatus(_ computer: Computer) {
        if let index = computers.firstIndex(
            where: { $0.id == computer.id }
        ) {
            computers[index].isAvailable.toggle()
        }
    }
}

struct ComputerRow: View {
    let computer: Computer
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "desktopcomputer")
                .font(.title3)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 3) {
                Text(computer.name)
                    .fontWeight(.medium)

                Text(computer.location)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onToggle) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(
                            computer.isAvailable
                            ? Color.green
                            : Color.red
                        )
                        .frame(width: 8, height: 8)

                    Text(
                        computer.isAvailable
                        ? "Available"
                        : "In Use"
                    )
                    .font(.caption)

                    Image(
                        systemName:
                            "arrow.triangle.2.circlepath"
                    )
                    .font(.caption2)
                }
                .foregroundStyle(
                    computer.isAvailable
                    ? Color.green
                    : Color.red
                )
                .padding(.horizontal, 7)
                .padding(.vertical, 6)
                .background(
                    (computer.isAvailable
                     ? Color.green
                     : Color.red)
                    .opacity(0.1),
                    in: Capsule()
                )
            }
            .buttonStyle(.plain)

            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .foregroundStyle(.red)
                    .frame(width: 32, height: 32)
                    .background(
                        Color.red.opacity(0.1),
                        in: Circle()
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            Color.gray.opacity(0.07),
            in: RoundedRectangle(cornerRadius: 12)
        )
    }
}

struct AddComputerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var computers: [Computer]

    @State private var computerName = ""
    @State private var location = "Lab A"
    @State private var isAvailable = true
    @State private var showError = false
    @State private var errorMessage = ""

    let locations = [
        "Lab A",
        "Lab B",
        "Lab C"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Image(systemName: "desktopcomputer")
                    .font(.system(size: 55))
                    .foregroundStyle(.blue)
                    .padding(25)
                    .background(
                        Color.blue.opacity(0.1),
                        in: Circle()
                    )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Computer Name")
                        .font(.headline)

                    TextField(
                        "e.g. PC06",
                        text: $computerName
                    )
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.characters)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.headline)

                    Picker(
                        "Location",
                        selection: $location
                    ) {
                        ForEach(
                            locations,
                            id: \.self
                        ) { item in
                            Text(item)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding()
                    .background(
                        RoundedRectangle(
                            cornerRadius: 8
                        )
                        .stroke(
                            Color.gray.opacity(0.3)
                        )
                    )
                }

                Toggle(
                    "Available",
                    isOn: $isAvailable
                )
                .tint(.green)

                Button {
                    addComputer()
                } label: {
                    Text("Add")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Color.blue,
                            in: RoundedRectangle(
                                cornerRadius: 10
                            )
                        )
                }

                Spacer()
            }
            .padding(20)
        }
        .navigationTitle("Add Computer")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Cannot Add Computer",
            isPresented: $showError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func addComputer() {
        let newName = computerName
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .uppercased()

        if newName.isEmpty {
            errorMessage = "Please enter a computer name."
            showError = true
            return
        }

        if computers.contains(
            where: {
                $0.name.uppercased() == newName
            }
        ) {
            errorMessage = "\(newName) already exists."
            showError = true
            return
        }

        let newComputer = Computer(
            name: newName,
            location: location,
            isAvailable: isAvailable
        )

        computers.append(newComputer)
        dismiss()
    }
}

struct CheckComputerView: View {
    let computers: [Computer]

    @State private var computerName = ""
    @State private var result: Computer?
    @State private var hasChecked = false

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 55))
                    .foregroundStyle(.green)
                    .padding(25)
                    .background(
                        Color.green.opacity(0.1),
                        in: Circle()
                    )

                TextField(
                    "Enter computer name",
                    text: $computerName
                )
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.characters)

                Button {
                    checkComputer()
                } label: {
                    Text("Check")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Color.blue,
                            in: RoundedRectangle(
                                cornerRadius: 10
                            )
                        )
                }

                if hasChecked {
                    if let computer = result {
                        HStack(spacing: 12) {
                            Image(
                                systemName:
                                    "checkmark.circle.fill"
                            )
                            .foregroundStyle(.green)

                            VStack(
                                alignment: .leading
                            ) {
                                Text(
                                    "\(computer.name) is in the lab!"
                                )
                                .fontWeight(.medium)

                                Text(
                                    "\(computer.location) • " +
                                    "\(computer.isAvailable ? "Available" : "In Use")"
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding()
                        .background(
                            Color.green.opacity(0.1),
                            in: RoundedRectangle(
                                cornerRadius: 10
                            )
                        )
                    } else {
                        HStack(spacing: 12) {
                            Image(
                                systemName:
                                    "xmark.circle.fill"
                            )
                            .foregroundStyle(.red)

                            Text(
                                "\(computerName.uppercased()) " +
                                "is not in the lab!"
                            )
                            .fontWeight(.medium)

                            Spacer()
                        }
                        .padding()
                        .background(
                            Color.red.opacity(0.1),
                            in: RoundedRectangle(
                                cornerRadius: 10
                            )
                        )
                    }
                }

                Spacer()
            }
            .padding(20)
        }
        .navigationTitle("Check Computer")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func checkComputer() {
        let name = computerName
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .uppercased()

        result = computers.first {
            $0.name.uppercased() == name
        }

        hasChecked = true
    }
}

struct StatisticsView: View {
    let computers: [Computer]

    private var availableCount: Int {
        computers.filter {
            $0.isAvailable
        }.count
    }

    private var inUseCount: Int {
        computers.filter {
            !$0.isAvailable
        }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 45))
                        .foregroundStyle(.orange)

                    Text("Total Computers")
                        .font(.headline)

                    Text("\(computers.count)")
                        .font(
                            .system(
                                size: 42,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(.blue)
                }
                .frame(maxWidth: .infinity)
                .padding(25)
                .background(
                    Color.blue.opacity(0.06),
                    in: RoundedRectangle(
                        cornerRadius: 15
                    )
                )

                StatisticCard(
                    title: "Available",
                    value: availableCount,
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                StatisticCard(
                    title: "In Use",
                    value: inUseCount,
                    icon: "xmark.circle.fill",
                    color: .red
                )

                VStack(
                    alignment: .leading,
                    spacing: 12
                ) {
                    Text("Computer List")
                        .font(.headline)

                    ForEach(computers) { computer in
                        HStack {
                            Image(
                                systemName:
                                    "desktopcomputer"
                            )

                            VStack(
                                alignment: .leading
                            ) {
                                Text(computer.name)

                                Text(computer.location)
                                    .font(.caption)
                                    .foregroundStyle(
                                        .secondary
                                    )
                            }

                            Spacer()

                            Circle()
                                .fill(
                                    computer.isAvailable
                                    ? Color.green
                                    : Color.red
                                )
                                .frame(
                                    width: 8,
                                    height: 8
                                )

                            Text(
                                computer.isAvailable
                                ? "Available"
                                : "In Use"
                            )
                            .font(.caption)
                            .foregroundStyle(
                                computer.isAvailable
                                ? .green
                                : .red
                            )
                        }

                        Divider()
                    }
                }
                .padding()
                .background(
                    Color.gray.opacity(0.07),
                    in: RoundedRectangle(
                        cornerRadius: 15
                    )
                )
            }
            .padding()
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatisticCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(title)
                .font(.headline)

            Spacer()

            Text("\(value)")
                .font(.title2.bold())
                .foregroundStyle(color)
        }
        .padding()
        .background(
            color.opacity(0.08),
            in: RoundedRectangle(
                cornerRadius: 12
            )
        )
    }
}

#Preview {
    ContentView()
}
