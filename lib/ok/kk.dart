import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'kk.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String text;
  NoteModel({
    required this.title,
    required this.text,
  });

  NoteModel copyWith({
    String? title,
    String? text,
  }) {
    return NoteModel(
      title: title ?? this.title,
      text: text ?? this.text,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'text': text,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      title: map['title'],
      text: map['text'],
    );
  }

  String toJson() => json.encode(toMap());

  factory NoteModel.fromJson(String source) =>
      NoteModel.fromMap(json.decode(source));

  @override
  String toString() => 'NoteModel(title: $title, text: $text)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NoteModel && other.title == title && other.text == text;
  }

  @override
  int get hashCode => title.hashCode ^ text.hashCode;
}

//TODO старайся выносить виджеты,
// если это какие-то отдельные компоненты в отдельные файлы
// этим ты повысишь читаемость кода за счет уменьшения кол-ва строк в одном файле
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _userHome;

  List<NoteModel> homelist = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //кстати прикольное решение
    return ValueListenableBuilder(
      valueListenable: Hive.box('ok').listenable(),
      builder: (BuildContext context, Box box, Widget? child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(20),
            child: AppBar(
              title: Text(
                'Notebook',
                style: TextStyle(color: Colors.black),
              ),
              centerTitle: true,
              backgroundColor: Colors.grey.shade500,
            ),
          ),
          body: ListView.builder(
              itemCount: box.length,
              //можно вынести отдельный метод
              itemBuilder: (BuildContext context, var index) {
                final note = box.getAt(index);
                //get('notes')).elementAt(index);
                return Dismissible(
                  key: Key(note.title),
                  child: GestureDetector(
                    child: Card(
                      color: Colors.grey.shade500,
                      child: ListTile(
                        title: Text(
                          note.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.black),
                          onPressed: () {
                            setState(() {
                              box.deleteAt(index);
                            });
                          },
                        ),
                      ),
                    ),
                    //для лучшей читаемости - в отдельный метод
                    onTap: () async {
                      final text = await Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return FirstScreen(
                          initialValue: note.text,
                        );
                      }));
                      if (text != null) {
                        final newNote =
                            NoteModel(title: note.title, text: text);
                        box.putAt(index, newNote);
                        // homelist[index] = homelist[index].copyWith(text: text);
                      }
                    },
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      box.deleteAt(index);
                    });
                  },
                );
              }),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Add'),
                      content: TextField(
                        decoration: InputDecoration(hintText: "Тема заметки"),
                        maxLength: 32,
                        onChanged: (String? value) {
                          _userHome = value;
                        },
                      ),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                box.add(NoteModel(title: _userHome, text: ''));
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text('Добавить'))
                      ],
                    );
                  });
            },
            child: Icon(
              Icons.add,
              color: Colors.black,
            ),
          ),
        );
      },
    );
  }
}

//выноси в отдельные виджеты
class FirstScreen extends StatefulWidget {
  final String? initialValue;
  const FirstScreen({Key? key, this.initialValue}) : super(key: key);

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  late final TextEditingController textCont;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textCont = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    //TODO тебе в большинстве случаев Scaffold не нужен, тут можно было обойтись контейнером
    // Scaffold чаще всего используют в страницах которые главные, например главая Вконтакте с кучей менюшек
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(20),
        child: AppBar(
          title: Text(
            'Notebook',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.grey.shade500,
        ),
      ),
      body: TextFormField(
        controller: textCont,
        style: TextStyle(fontSize: 24),
        decoration: InputDecoration(
            hintText: "Ваша заметка",
            labelStyle: TextStyle(
              fontSize: 30,
              color: Colors.black,
            )),
        maxLines: 60,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).pop(textCont.text);
        },
        child: Icon(
          Icons.savings_rounded,
          color: Colors.black,
        ),
      ),
    );
  }
}
