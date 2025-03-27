import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;

class Student {
  final String id;
  String name;
  Map<String, double> subjects; // Môn học và điểm

  Student({
    required this.id,
    required this.name,
    required this.subjects,
  });

  // Chuyển đổi thành Map để lưu vào JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subjects': subjects,
  };

  // Tạo Student từ Map (khi đọc từ JSON)
  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'],
    name: json['name'],
    subjects: Map<String, double>.from(json['subjects']),
  );
}

class StudentManager {
  final String jsonFilePath;
  List<Student> students = [];

  StudentManager(this.jsonFilePath);

  // Tải dữ liệu từ file JSON
  Future<void> loadStudents() async {
    try {
      final file = io.File(jsonFilePath);
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);
        students = jsonList.map((json) => Student.fromJson(json)).toList();
      }
    } catch (e) {
      print('Lỗi khi đọc file: $e');
    }
  }

  // Lưu dữ liệu vào file JSON
  Future<void> saveStudents() async {
    try {
      final file = io.File(jsonFilePath);
      final jsonList = students.map((student) => student.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      print('Lỗi khi ghi file: $e');
    }
  }

  // Hiển thị tất cả sinh viên
  void displayAllStudents() {
    if (students.isEmpty) {
      print('Không có sinh viên nào trong danh sách.');
      return;
    }

    print('\nDANH SÁCH SINH VIÊN:');
    for (var student in students) {
      print('\nID: ${student.id}');
      print('Tên: ${student.name}');
      print('Môn học và điểm:');
      student.subjects.forEach((subject, score) {
        print('  - $subject: $score');
      });
    }
    print('\nTổng số sinh viên: ${students.length}');
  }

  // Thêm sinh viên mới
  Future<void> addStudent() async {
    print('\nTHÊM SINH VIÊN MỚI');

    stdout.write('Nhập ID sinh viên: ');
    final id = io.stdin.readLineSync()?.trim() ?? '';

    // Kiểm tra ID đã tồn tại chưa
    if (students.any((student) => student.id == id)) {
      print('ID đã tồn tại. Vui lòng nhập ID khác.');
      return;
    }

    stdout.write('Nhập tên sinh viên: ');
    final name = io.stdin.readLineSync()?.trim() ?? '';

    final subjects = <String, double>{};
    var addMore = true;
    while (addMore) {
      stdout.write('Nhập tên môn học: ');
      final subject = io.stdin.readLineSync()?.trim() ?? '';

      stdout.write('Nhập điểm cho môn $subject: ');
      final score =
          double.tryParse(io.stdin.readLineSync()?.trim() ?? '') ?? 0.0;

      subjects[subject] = score;

      stdout.write('Thêm môn học khác? (y/n): ');
      final choice = io.stdin.readLineSync()?.trim()?.toLowerCase();
      addMore = choice == 'y';
    }

    final newStudent = Student(id: id, name: name, subjects: subjects);
    students.add(newStudent);
    await saveStudents();
    print('Đã thêm sinh viên thành công!');
  }

  // Sửa thông tin sinh viên
  Future<void> editStudent() async {
    print('\nSỬA THÔNG TIN SINH VIÊN');
    stdout.write('Nhập ID sinh viên cần sửa: ');
    final id = io.stdin.readLineSync()?.trim() ?? '';

    final student = students.firstWhere(
          (s) => s.id == id,
      orElse: () => Student(id: '', name: '', subjects: {}),
    );

    if (student.id.isEmpty) {
      print('Không tìm thấy sinh viên với ID $id');
      return;
    }

    print('\nThông tin hiện tại:');
    print('ID: ${student.id}');
    print('Tên: ${student.name}');
    print('Môn học và điểm:');
    student.subjects.forEach((subject, score) {
      print('  - $subject: $score');
    });

    print('\nChọn thông tin cần sửa:');
    print('1. Tên');
    print('2. Môn học và điểm');
    stdout.write('Lựa chọn của bạn (1-2): ');
    final choice = io.stdin.readLineSync()?.trim();

    switch (choice) {
      case '1':
        stdout.write('Nhập tên mới: ');
        final newName = io.stdin.readLineSync()?.trim() ?? '';
        student.name = newName;
        break;
      case '2':
        print('\n1. Thêm môn học mới');
        print('2. Sửa điểm môn học');
        print('3. Xóa môn học');
        stdout.write('Lựa chọn của bạn (1-3): ');
        final subjectChoice = io.stdin.readLineSync()?.trim();

        switch (subjectChoice) {
          case '1':
            stdout.write('Nhập tên môn học mới: ');
            final subject = io.stdin.readLineSync()?.trim() ?? '';
            stdout.write('Nhập điểm cho môn $subject: ');
            final score =
                double.tryParse(io.stdin.readLineSync()?.trim() ?? '') ?? 0.0;
            student.subjects[subject] = score;
            break;
          case '2':
            stdout.write('Nhập tên môn học cần sửa điểm: ');
            final subject = io.stdin.readLineSync()?.trim() ?? '';
            if (student.subjects.containsKey(subject)) {
              stdout.write('Nhập điểm mới cho môn $subject: ');
              final newScore =
                  double.tryParse(io.stdin.readLineSync()?.trim() ?? '') ?? 0.0;
              student.subjects[subject] = newScore;
            } else {
              print('Không tìm thấy môn học $subject');
            }
            break;
          case '3':
            stdout.write('Nhập tên môn học cần xóa: ');
            final subject = io.stdin.readLineSync()?.trim() ?? '';
            if (student.subjects.containsKey(subject)) {
              student.subjects.remove(subject);
              print('Đã xóa môn học $subject');
            } else {
              print('Không tìm thấy môn học $subject');
            }
            break;
          default:
            print('Lựa chọn không hợp lệ');
        }
        break;
      default:
        print('Lựa chọn không hợp lệ');
        return;
    }

    await saveStudents();
    print('Đã cập nhật thông tin sinh viên thành công!');
  }

  // Tìm kiếm sinh viên
  void searchStudent() {
    print('\nTÌM KIẾM SINH VIÊN');
    print('1. Tìm theo ID');
    print('2. Tìm theo tên');
    stdout.write('Lựa chọn của bạn (1-2): ');
    final choice = io.stdin.readLineSync()?.trim();

    switch (choice) {
      case '1':
        stdout.write('Nhập ID cần tìm: ');
        final id = io.stdin.readLineSync()?.trim() ?? '';
        final found = students.where((student) => student.id == id).toList();
        displaySearchResults(found);
        break;
      case '2':
        stdout.write('Nhập tên cần tìm: ');
        final name = io.stdin.readLineSync()?.trim() ?? '';
        final found = students
            .where((student) =>
            student.name.toLowerCase().contains(name.toLowerCase()))
            .toList();
        displaySearchResults(found);
        break;
      default:
        print('Lựa chọn không hợp lệ');
    }
  }

  // Hiển thị kết quả tìm kiếm
  void displaySearchResults(List<Student> foundStudents) {
    if (foundStudents.isEmpty) {
      print('Không tìm thấy sinh viên phù hợp');
      return;
    }

    print('\nKẾT QUẢ TÌM KIẾM:');
    for (var student in foundStudents) {
      print('\nID: ${student.id}');
      print('Tên: ${student.name}');
      print('Môn học và điểm:');
      student.subjects.forEach((subject, score) {
        print('  - $subject: $score');
      });
    }
  }
}

// Hàm main để chạy chương trình
void main() async {
  final manager = StudentManager('Student.json');
  await manager.loadStudents();

  var running = true;
  while (running) {
    print('\nCHƯƠNG TRÌNH QUẢN LÝ SINH VIÊN');
    print('1. Hiển thị tất cả sinh viên');
    print('2. Thêm sinh viên mới');
    print('3. Sửa thông tin sinh viên');
    print('4. Tìm kiếm sinh viên');
    print('5. Thoát');
    stdout.write('Lựa chọn của bạn (1-5): ');

    final choice = io.stdin.readLineSync()?.trim();
    switch (choice) {
      case '1':
        manager.displayAllStudents();
        break;
      case '2':
        await manager.addStudent();
        break;
      case '3':
        await manager.editStudent();
        break;
      case '4':
        manager.searchStudent();
        break;
      case '5':
        running = false;
        print('Đã thoát chương trình.');
        break;
      default:
        print('Lựa chọn không hợp lệ. Vui lòng chọn lại.');
    }
  }
}