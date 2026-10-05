import SwiftUI
import PhotosUI

struct Student: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var gpa: Double
    var avatarData: Data?
}


struct ContentView: View {
    @State private var students: [Student] = [
        Student(name: "đạt 1", gpa: 1.3),
        Student(name: "đạt 2", gpa: 2.2),
        Student(name: "đạt 3", gpa: 3.0)
    ]
    @State private var searchText = ""
    @State private var showingAddEditSheet = false
    @State private var editingStudent: Student?

    
    var filteredStudents: [Student] {
        if searchText.isEmpty { return students }
        return students.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                    Text("Student Manager")
                        .font(.title2).bold()
                        .foregroundColor(.blue)
                    Text("A better class, a brighter tomorrow")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Search student by name...", text: $searchText)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                List {
                    ForEach(filteredStudents) { student in
                        HStack(spacing: 15) {
                            // Avatar hiển thị
                            if let data = student.avatarData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable().scaledToFill()
                                    .frame(width: 45, height: 45).clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .foregroundColor(.blue.opacity(0.8))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(student.name).font(.system(size: 16, weight: .semibold))
                                Text("GPA: \(String(format: "%.1f", student.gpa))")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray).font(.caption)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingStudent = student
                            showingAddEditSheet = true
                        }
                    }
                    .onDelete(perform: deleteStudent)
                }
                .listStyle(.plain)
                Button(action: {
                    editingStudent = nil
                    showingAddEditSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Student")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                Text("Total students: \(students.count)")
                    .font(.footnote).foregroundColor(.gray)
                    .padding(.bottom, 5)
            }
            .sheet(isPresented: $showingAddEditSheet) {
                AddEditStudentView(students: $students, studentToEdit: editingStudent)
            }
        }
    }
    func deleteStudent(at offsets: IndexSet) {
        let studentsToDelete = offsets.map { filteredStudents[$0] }
        students.removeAll { student in
            studentsToDelete.contains(where: { $0.id == student.id })
        }
    }
}
struct AddEditStudentView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var students: [Student]
    var studentToEdit: Student?

    @State private var name: String = ""
    @State private var gpa: String = ""
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarData: Data?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $avatarItem, matching: .images) {
                            if let avatarData, let uiImage = UIImage(data: avatarData) {
                                Image(uiImage: uiImage)
                                    .resizable().scaledToFill()
                                    .frame(width: 80, height: 80).clipShape(Circle())
                            } else {
                                VStack {
                                    Image(systemName: "person.crop.circle.badge.plus")
                                        .resizable().scaledToFit()
                                        .frame(width: 80, height: 80).foregroundColor(.blue)
                                    Text("Chọn ảnh").font(.caption).foregroundColor(.blue)
                                }
                            }
                        }
                        .onChange(of: avatarItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    avatarData = data
                                }
                            }
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }

                Section("Thông tin học sinh") {
                    TextField("Tên học sinh", text: $name)
                    TextField("Điểm GPA", text: $gpa)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(studentToEdit == nil ? "Thêm học sinh" : "Sửa thông tin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let student = studentToEdit {
                    name = student.name
                    gpa = String(student.gpa)
                    avatarData = student.avatarData
                }
            }
        }
    }

    func save() {
        let newGpa = Double(gpa.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        if let studentToEdit, let index = students.firstIndex(where: { $0.id == studentToEdit.id }) {
            students[index].name = name
            students[index].gpa = newGpa
            students[index].avatarData = avatarData
        } else {
            students.append(Student(name: name, gpa: newGpa, avatarData: avatarData))
        }
        dismiss()
    }
}

#Preview {
    ContentView()
}
