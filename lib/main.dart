import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
part 'main.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //this app ready to load all datas.
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(StudentModelAdapter().typeId)) {
    Hive.registerAdapter(StudentModelAdapter());
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: ScreenHome(),
    );
  }
}

class ScreenHome extends StatelessWidget {
  const ScreenHome({super.key});

  @override
  Widget build(BuildContext context) {
    getAllStudent();
    return Scaffold(
      backgroundColor: Colors.white,
      //appBar: AppBar(),
      body: SafeArea(
          child: Column(
        children: [
          AddStudentWidget(),
          Expanded(child: ListStudentWidget()),
        ],
      )),
    );
  }
}

class AddStudentWidget extends StatelessWidget {
  AddStudentWidget({super.key});
  final _namecontroller = TextEditingController();
  final _agecontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          TextFormField(
            controller: _namecontroller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'name',
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: _agecontroller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Age',
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton.icon(
            onPressed: () {
              onAddStudentBotton();
            },
            icon: Icon(Icons.add),
            label: Text('Add student'),
          ),
        ],
      ),
    );
  }

  Future<void> onAddStudentBotton() async {
    final _name = _namecontroller.text.trim();
    final _age = _agecontroller.text.trim();
    if (_name.isEmpty || _age.isEmpty) {
      return;
    }
    print('$_name $_age');
    final _student = StudentModel(name: _name, age: _age);
    addStudent(_student);
  }
}

class ListStudentWidget extends StatelessWidget {
  const ListStudentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: StudentListNotifier,
      builder:
          (BuildContext ctx, List<StudentModel> studentList, Widget? child) {
        return ListView.separated(
            itemBuilder: (ctx, index) {
              final data = studentList[index];
              return ListTile(
                title: Text(data.name),
                subtitle: Text(data.age),
                trailing: IconButton(
                  onPressed: () {
                    if (data.id != null) {
                      deleteStudent(data.id!);
                    } else {
                      print('student is null unable to delete');
                    }
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              );
            },
            separatorBuilder: (ctx, index) {
              return const Divider();
            },
            itemCount: studentList.length);
      },
    );
  }
}

//List of class students
@HiveType(typeId: 1)
class StudentModel {
  @HiveField(0)
  int? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String age;

  StudentModel({required this.name, required this.age, this.id});
}

ValueNotifier<List<StudentModel>> StudentListNotifier = ValueNotifier([]);

Future<void> addStudent(StudentModel value) async {
  //print(value.toString());
  final studentDB =
      await Hive.openBox<StudentModel>('student_db'); //open database
  final _id = await studentDB.add(value);
  value.id = _id;

  StudentListNotifier.value.add(value);
  StudentListNotifier.notifyListeners();
}

Future<void> getAllStudent() async {
  final studentDB = await Hive.openBox<StudentModel>('student_db');
  StudentListNotifier.value.clear();

  StudentListNotifier.value.addAll(studentDB.values);
  StudentListNotifier.notifyListeners();
}

Future<void> deleteStudent(int id) async {
  final studentDB = await Hive.openBox<StudentModel>('student_db');
  await studentDB.delete(id);
  getAllStudent();
}
