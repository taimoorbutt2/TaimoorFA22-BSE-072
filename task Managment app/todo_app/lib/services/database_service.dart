import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo_app/models/task.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    debugPrint('DatabaseService: Database initialized');
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            iconData INTEGER,
            title TEXT,
            bgColor INTEGER,
            iconColor INTEGER,
            btnColor INTEGER,
            dueDate TEXT,
            desc TEXT
          )
        ''');
        debugPrint('DatabaseService: Tasks table created');
      },
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    debugPrint('DatabaseService: Retrieved ${maps.length} tasks from database');

    return List.generate(maps.length, (i) {
      final desc = maps[i]['desc'] != null
          ? (maps[i]['desc'] as String).split('|').map((e) => Map<String, dynamic>.from(eval(e))).toList()
          : <Map<String, dynamic>>[];
      return Task(
        id: maps[i]['id'],
        iconData: IconData(maps[i]['iconData'], fontFamily: 'MaterialIcons'),
        title: maps[i]['title'],
        bgColor: Color(maps[i]['bgColor']),
        iconColor: Color(maps[i]['iconColor']),
        btnColor: Color(maps[i]['btnColor']),
        dueDate: maps[i]['dueDate'] != null ? DateTime.parse(maps[i]['dueDate']) : null,
        desc: desc,
      );
    });
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    final descString = task.desc.map((e) => e.toString()).join('|');
    await db.update(
      'tasks',
      {
        'id': task.id,
        'iconData': task.iconData.codePoint,
        'title': task.title,
        'bgColor': task.bgColor.value,
        'iconColor': task.iconColor.value,
        'btnColor': task.btnColor.value,
        'dueDate': task.dueDate?.toIso8601String(),
        'desc': descString,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
    debugPrint('DatabaseService: Updated task with id=${task.id}, desc=$descString');
  }

  // Temporary eval function for parsing desc (replace with proper JSON parsing in production)
  Map<String, dynamic> eval(String input) {
    // Simplified parsing for demo; use jsonDecode in production
    return {
      'title': input.contains('title') ? input.split('title: ')[1].split(',')[0] : '',
      'description': input.contains('description') ? input.split('description: ')[1].split(',')[0] : '',
      'isRepeated': input.contains('isRepeated: true'),
      'dueDate': input.contains('dueDate') ? input.split('dueDate: ')[1].split(',')[0] : null,
      'createdAt': input.contains('createdAt') ? input.split('createdAt: ')[1].split('}')[0] : null,
    };
  }
}