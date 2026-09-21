import SwiftUI
import PhotosUI

struct Student: Identifiable {
var id: String
var name: String
var gpa: Double
var avatar: Data?
}

struct ContentView: View {
@State private var students: [Student] = [
Student(id: "S001", name: "An", gpa: 8.5, avatar: nil),
Student(id: "S002", name: "Binh", gpa: 9.0, avatar: nil),
Student(id: "S003", name: "Chi", gpa: 7.8, avatar: nil),
Student(id: "S004", name: "Duy", gpa: 9.2, avatar: nil),
Student(id: "S005", name: "Lan", gpa: 8.0, avatar: nil)
]
@State private var searchText = ""
@State private var showingAdd = false
@State private var editingStudent: Student?
@State private var showingFind = false
@State private var findID = ""
@State private var alertTitle = ""
@State private var alertMessage = ""
@State private var showingAlert = false
@State private var sortByGPA = false

var filteredStudents: [Student] {
    var result = students

    if !searchText.isEmpty {
        result = result.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.id.localizedCaseInsensitiveContains(searchText)
        }
    }

    if sortByGPA {
        result.sort { $0.gpa > $1.gpa }
    }

    return result
}

var body: some View {
    NavigationStack {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(.blue)

                Text("Student Manager")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("A better class, a brighter tomorrow")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)

            TextField("Search student by name or ID...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            List {
                Section {
                    ForEach(filteredStudents) { student in
                        HStack(spacing: 12) {
                            AvatarView(data: student.avatar, size: 48)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(student.name)
                                    .font(.headline)

                                Text("\(student.id) • GPA: \(String(format: "%.1f", student.gpa))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(String(format: "%.1f", student.gpa))
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    student.gpa >= 8.0 ? .green : .orange
                                )
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingStudent = student
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                deleteStudent(student)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    Text("Student List")
                }
            }
            .listStyle(.insetGrouped)

            Text("Total students: \(students.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                showingAdd = true
            } label: {
                Label("Add Student", systemImage: "plus")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .navigationTitle("Class Management")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingFind = true
                    } label: {
                        Label("Find by ID", systemImage: "magnifyingglass")
                    }

                    Button {
                        showHighestGPA()
                    } label: {
                        Label("Highest GPA", systemImage: "star.fill")
                    }

                    Button {
                        showHighGPAStudents()
                    } label: {
                        Label("GPA ≥ 8.0", systemImage: "checkmark.circle")
                    }

                    Button {
                        sortByGPA.toggle()
                    } label: {
                        Label(
                            sortByGPA ? "Original Order" : "Sort by GPA",
                            systemImage: sortByGPA
                                ? "arrow.uturn.backward"
                                : "arrow.down"
                        )
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            StudentFormView(title: "Add Student") { id, name, gpa, avatar in
                addStudent(
                    id: id,
                    name: name,
                    gpa: gpa,
                    avatar: avatar
                )
            }
        }
        .sheet(item: $editingStudent) { student in
            StudentFormView(
                title: "Edit Student",
                student: student
            ) { id, name, gpa, avatar in
                updateStudent(
                    student,
                    id: id,
                    name: name,
                    gpa: gpa,
                    avatar: avatar
                )
            }
        }
        .sheet(isPresented: $showingFind) {
            FindStudentView { id in
                findStudent(id: id)
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
}

func addStudent(
    id: String,
    name: String,
    gpa: Double,
    avatar: Data?
) {
    if students.contains(where: {
        $0.id.caseInsensitiveCompare(id) == .orderedSame
    }) {
        alertTitle = "Error"
        alertMessage = "Student ID already exists."
        showingAlert = true
        return
    }

    students.append(
        Student(
            id: id,
            name: name,
            gpa: gpa,
            avatar: avatar
        )
    )
}

func deleteStudent(_ student: Student) {
    students.removeAll {
        $0.id == student.id
    }
}

func updateStudent(
    _ oldStudent: Student,
    id: String,
    name: String,
    gpa: Double,
    avatar: Data?
) {
    guard let index = students.firstIndex(where: {
        $0.id == oldStudent.id
    }) else {
        return
    }

    if id != oldStudent.id &&
        students.contains(where: {
            $0.id.caseInsensitiveCompare(id) == .orderedSame
        }) {
        alertTitle = "Error"
        alertMessage = "Student ID already exists."
        showingAlert = true
        return
    }

    students[index] = Student(
        id: id,
        name: name,
        gpa: gpa,
        avatar: avatar
    )
}

func findStudent(id: String) {
    guard let student = students.first(where: {
        $0.id.caseInsensitiveCompare(id) == .orderedSame
    }) else {
        alertTitle = "Not Found"
        alertMessage = "No student with ID \(id)."
        showingAlert = true
        return
    }

    alertTitle = "Student Found"
    alertMessage = """
    ID: \(student.id)
    Name: \(student.name)
    GPA: \(String(format: "%.1f", student.gpa))
    """
    showingAlert = true
}

func showHighestGPA() {
    guard let student = students.max(by: {
        $0.gpa < $1.gpa
    }) else {
        return
    }

    alertTitle = "Highest GPA"
    alertMessage = """
    \(student.name)
    ID: \(student.id)
    GPA: \(String(format: "%.1f", student.gpa))
    """
    showingAlert = true
}

func showHighGPAStudents() {
    let highStudents = students.filter {
        $0.gpa >= 8.0
    }

    if highStudents.isEmpty {
        alertTitle = "GPA ≥ 8.0"
        alertMessage = "No students have GPA ≥ 8.0."
    } else {
        alertTitle = "Students with GPA ≥ 8.0"

        alertMessage = highStudents
            .map {
                "\($0.id) - \($0.name) - \(String(format: "%.1f", $0.gpa))"
            }
            .joined(separator: "\n")
    }

    showingAlert = true
}

}

struct AvatarView: View {
let data: Data?
let size: CGFloat


var body: some View {
    Group {
        if let data,
           let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.blue)
                .padding(2)
        }
    }
    .frame(width: size, height: size)
    .clipShape(Circle())
    .overlay {
        Circle()
            .stroke(.blue.opacity(0.2), lineWidth: 1)
    }
}


}

struct StudentFormView: View {
let title: String
var student: Student?
let onSave: (String, String, Double, Data?) -> Void


@Environment(\.dismiss) private var dismiss

@State private var id = ""
@State private var name = ""
@State private var gpa = ""
@State private var avatarData: Data?
@State private var selectedPhoto: PhotosPickerItem?
@State private var showingError = false
@State private var errorMessage = ""

var body: some View {
    NavigationStack {
        Form {
            Section {
                VStack(spacing: 12) {
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        ZStack(alignment: .bottomTrailing) {
                            AvatarView(
                                data: avatarData,
                                size: 110
                            )

                            Image(systemName: "camera.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                                .padding(9)
                                .background(.blue)
                                .clipShape(Circle())
                        }
                    }
                    .buttonStyle(.plain)

                    Text("Tap avatar to choose a photo")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if avatarData != nil {
                        Button("Remove Avatar") {
                            avatarData = nil
                            selectedPhoto = nil
                        }
                        .foregroundStyle(.red)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            Section("Student Information") {
                TextField("Student ID", text: $id)
                    .textInputAutocapitalization(.characters)

                TextField("Name", text: $name)

                TextField("GPA", text: $gpa)
                    .keyboardType(.decimalPad)
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveStudent()
                }
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            if let student {
                id = student.id
                name = student.name
                gpa = String(student.gpa)
                avatarData = student.avatar
            }
        }
        .onChange(of: selectedPhoto) { _, newPhoto in
            guard let newPhoto else {
                return
            }

            Task {
                if let data = try? await newPhoto.loadTransferable(
                    type: Data.self
                ) {
                    await MainActor.run {
                        avatarData = data
                    }
                }
            }
        }
        .alert("Cannot Save", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}

func saveStudent() {
    let cleanID = id.trimmingCharacters(in: .whitespacesAndNewlines)
    let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !cleanID.isEmpty else {
        errorMessage = "Please enter Student ID."
        showingError = true
        return
    }

    guard !cleanName.isEmpty else {
        errorMessage = "Please enter student name."
        showingError = true
        return
    }

    let normalizedGPA = gpa
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: ",", with: ".")

    guard let value = Double(normalizedGPA) else {
        errorMessage = "GPA must be a number, for example 8.5."
        showingError = true
        return
    }

    guard value >= 0 && value <= 10 else {
        errorMessage = "GPA must be between 0 and 10."
        showingError = true
        return
    }

    onSave(
        cleanID,
        cleanName,
        value,
        avatarData
    )

    dismiss()
}

}

struct FindStudentView: View {
let onFind: (String) -> Void
@Environment(\.dismiss) private var dismiss
@State private var id = ""

var body: some View {
    NavigationStack {
        Form {
            Section("Find Student") {
                TextField("Enter student ID", text: $id)
                    .textInputAutocapitalization(.characters)
            }
        }
        .navigationTitle("Find by ID")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Find") {
                    let cleanID = id.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )

                    guard !cleanID.isEmpty else {
                        return
                    }

                    onFind(cleanID)
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
    }
}

}
