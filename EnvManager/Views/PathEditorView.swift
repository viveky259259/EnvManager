import SwiftUI
import UniformTypeIdentifiers

struct PathEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let variable: EnvironmentVariable
    let onSave: (EnvironmentVariable) -> Void

    @State private var paths: [PathEntry] = []
    @State private var selectedPath: PathEntry.ID?
    @State private var showAddSheet = false
    @State private var newPath = ""

    struct PathEntry: Identifiable, Hashable {
        let id = UUID()
        var path: String
        var exists: Bool

        init(path: String) {
            self.path = path
            self.exists = FileManager.default.fileExists(atPath: path)
        }
    }

    private var existingCount: Int {
        paths.filter(\.exists).count
    }

    init(variable: EnvironmentVariable, onSave: @escaping (EnvironmentVariable) -> Void) {
        self.variable = variable
        self.onSave = onSave

        let components = variable.pathComponents.map { PathEntry(path: $0) }
        _paths = State(initialValue: components)
    }

    var body: some View {
        ZStack {
            FloeTheme.pageBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Edit \(variable.name)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(FloeTheme.inkPrimary)
                        Text("Reorder directories, remove dead entries, and browse for new folders before saving the updated path string.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(FloeTheme.inkSecondary)
                    }

                    Spacer(minLength: 0)

                    FloeInfoPill(
                        title: "\(paths.count) entries",
                        systemImage: "list.bullet.indent",
                        tint: FloeTheme.primary
                    )
                }

                HStack(spacing: 14) {
                    FloeMetricCard(
                        title: "Resolved Paths",
                        value: "\(existingCount)",
                        detail: "Folders currently present on disk",
                        systemImage: "checkmark.seal",
                        tint: FloeTheme.secondary
                    )
                    FloeMetricCard(
                        title: "Missing Paths",
                        value: "\(max(paths.count - existingCount, 0))",
                        detail: "Candidates for cleanup or replacement",
                        systemImage: "exclamationmark.circle",
                        tint: FloeTheme.accent
                    )
                }

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Directory order")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(FloeTheme.inkPrimary)
                        Spacer(minLength: 0)
                        Text("Drag to reorder")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(FloeTheme.inkSecondary)
                    }

                    List(selection: $selectedPath) {
                        ForEach(paths) { entry in
                            PathRowView(entry: entry)
                                .tag(entry.id)
                                .listRowBackground(Color.clear)
                        }
                        .onMove(perform: movePaths)
                    }
                    .frame(minHeight: 280)
                    .scrollContentBackground(.hidden)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(FloeTheme.background.opacity(0.92))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(FloeTheme.border.opacity(0.75), lineWidth: 1)
                    )

                    HStack(spacing: 12) {
                        Button {
                            showAddSheet = true
                        } label: {
                            Label("Add Path", systemImage: "plus")
                        }
                        .buttonStyle(FloeButtonStyle(variant: .filled, compact: true))

                        Button {
                            if let selected = selectedPath,
                               let index = paths.firstIndex(where: { $0.id == selected }) {
                                paths.remove(at: index)
                                selectedPath = nil
                            }
                        } label: {
                            Label("Remove", systemImage: "minus")
                        }
                        .buttonStyle(FloeButtonStyle(variant: .danger, compact: true))
                        .disabled(selectedPath == nil)

                        Spacer(minLength: 0)

                        Button("Browse...") {
                            browseForFolder()
                        }
                        .buttonStyle(FloeButtonStyle(variant: .soft, compact: true))
                    }
                }
                .floeCard()

                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(FloeButtonStyle(variant: .ghost))
                    .keyboardShortcut(.cancelAction)

                    Spacer(minLength: 0)

                    Button("Save Path") {
                        save()
                    }
                    .buttonStyle(FloeButtonStyle(variant: .filled))
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding(24)
        }
        .frame(width: 640, height: 640)
        .sheet(isPresented: $showAddSheet) {
            AddPathSheet(newPath: $newPath) {
                if !newPath.isEmpty {
                    paths.append(PathEntry(path: newPath))
                    newPath = ""
                }
            }
        }
    }

    private func movePaths(from source: IndexSet, to destination: Int) {
        paths.move(fromOffsets: source, toOffset: destination)
    }

    private func browseForFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            paths.append(PathEntry(path: url.path))
        }
    }

    private func save() {
        let pathValue = paths.map(\.path).joined(separator: ":")
        var updatedVariable = variable
        updatedVariable.value = pathValue
        onSave(updatedVariable)
        dismiss()
    }
}

struct PathRowView: View {
    let entry: PathEditorView.PathEntry

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill((entry.exists ? FloeTheme.secondary : FloeTheme.accent).opacity(0.16))
                    .frame(width: 34, height: 34)

                Image(systemName: entry.exists ? "folder.fill" : "folder.badge.questionmark")
                    .foregroundStyle(entry.exists ? FloeTheme.secondary : FloeTheme.accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.path)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(FloeTheme.inkPrimary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Text(entry.exists ? "Directory found" : "Directory not found")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(entry.exists ? FloeTheme.secondary : FloeTheme.accent)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
    }
}

struct AddPathSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var newPath: String
    let onAdd: () -> Void

    var body: some View {
        ZStack {
            FloeTheme.pageBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add Path")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(FloeTheme.inkPrimary)
                    Text("Type a directory path or browse for a folder to add it to the list.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(FloeTheme.inkSecondary)
                }

                TextField("Path", text: $newPath)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(FloeTheme.inkPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(FloeTheme.background.opacity(0.94))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(FloeTheme.border.opacity(0.75), lineWidth: 1)
                    )

                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(FloeButtonStyle(variant: .ghost))

                    Spacer(minLength: 0)

                    Button("Browse...") {
                        let panel = NSOpenPanel()
                        panel.canChooseFiles = false
                        panel.canChooseDirectories = true

                        if panel.runModal() == .OK, let url = panel.url {
                            newPath = url.path
                        }
                    }
                    .buttonStyle(FloeButtonStyle(variant: .soft))

                    Button("Add") {
                        onAdd()
                        dismiss()
                    }
                    .buttonStyle(FloeButtonStyle(variant: .filled))
                    .disabled(newPath.isEmpty)
                }
            }
            .padding(24)
        }
        .frame(width: 460, height: 260)
    }
}
