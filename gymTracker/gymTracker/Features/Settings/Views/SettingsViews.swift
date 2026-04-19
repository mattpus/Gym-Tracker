import SwiftUI

/// Settings view
struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel
    let coordinator: SettingsCoordinator
    
    var body: some View {
        List {
            Section("Appearance") {
                Button {
                    coordinator.showAppearanceSettings()
                } label: {
                    Label("Appearance", systemImage: "paintbrush")
                }
            }
            
            Section("Notifications") {
                Button {
                    coordinator.showNotificationSettings()
                } label: {
                    Label("Notifications", systemImage: "bell")
                }
            }
            
            Section("Data") {
                Button {
                    coordinator.showDataSettings()
                } label: {
                    Label("Data Management", systemImage: "externaldrive")
                }
            }
            
            Section("About") {
                Button {
                    coordinator.showAbout()
                } label: {
                    Label("About", systemImage: "info.circle")
                }
                
                LabeledContent("Version", value: "\(viewModel.appVersion) (\(viewModel.buildNumber))")
            }
        }
        .navigationTitle("Settings")
    }
}

struct AppearanceSettingsView: View {
    @AppStorage("colorScheme") private var colorScheme = 0
    
    var body: some View {
        List {
            Section("Theme") {
                Picker("Appearance", selection: $colorScheme) {
                    Text("System").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .pickerStyle(.inline)
            }
        }
        .navigationTitle("Appearance")
    }
}

struct NotificationSettingsView: View {
    @AppStorage("restTimerNotifications") private var restTimerNotifications = true
    @AppStorage("workoutReminders") private var workoutReminders = false
    
    var body: some View {
        List {
            Section {
                Toggle("Rest Timer Alerts", isOn: $restTimerNotifications)
                Toggle("Workout Reminders", isOn: $workoutReminders)
            }
        }
        .navigationTitle("Notifications")
    }
}

struct DataSettingsView: View {
    @Bindable var viewModel: DataSettingsViewModel
    @State private var showingExportSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var exportDocument: CSVDocument?
    
    var body: some View {
        List {
            Section {
                Button("Export Data") {
                    viewModel.prepareExport()
                    if let csv = viewModel.exportCSV {
                        exportDocument = CSVDocument(text: csv)
                        showingExportSheet = true
                    }
                }
                
                Button("Delete All Data", role: .destructive) {
                    showingDeleteConfirmation = true
                }
            }

            if let lastErrorMessage = viewModel.lastErrorMessage {
                Section {
                    Text(lastErrorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Data Management")
        .confirmationDialog("Delete All Data?", isPresented: $showingDeleteConfirmation) {
            Button("Delete All", role: .destructive) {
                viewModel.deleteAllData { _ in }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all your workout data. This cannot be undone.")
        }
        .fileExporter(
            isPresented: $showingExportSheet,
            document: exportDocument,
            contentType: .gymTrackerCSV,
            defaultFilename: "gymtracker-workout-history"
        ) { _ in }
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("Gym Tracker")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Track your workouts, monitor your progress, and achieve your fitness goals.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            
            Section("Links") {
                Link(destination: URL(string: "https://example.com/privacy")!) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
                
                Link(destination: URL(string: "https://example.com/terms")!) {
                    Label("Terms of Service", systemImage: "doc.text")
                }
            }
        }
        .navigationTitle("About")
    }
}
