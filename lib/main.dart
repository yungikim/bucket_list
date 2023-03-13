import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class Bucket {
  String job;
  bool isDone;

  Bucket(this.job, this.isDone);
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Bucket> bucketList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("버킷 리스트"),
        centerTitle: true,
      ),
      body: bucketList.isEmpty
          ? Center(child: Text("버킷 리스트를 작성해 주세요."))
          : ListView.builder(
              itemCount: bucketList.length,
              itemBuilder: (context, index) {
                Bucket bucket = bucketList[index];
                return ListTile(
                  title: Text(
                    bucket.job,
                    style: TextStyle(
                      fontSize: 24,
                      color: bucket.isDone ? Colors.grey : Colors.black,
                      decoration: bucket.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(CupertinoIcons.delete),
                    onPressed: () {
                      showDeleteDialog(context, index);
                    },
                  ),
                  onTap: () {
                    setState(() {
                      bucket.isDone = !bucket.isDone;
                    });
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          String? job = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePage()),
          );
          if (job != null) {
            setState(() {
              Bucket newBucket = Bucket(job, false);
              bucketList.add(newBucket);
            });
          }
        },
      ),
    );
  }

   void showDeleteDialog(BuildContext context, int index) {
     showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "정말로 삭제하시겠습니까?"
          ),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: (){
                setState(() {
                  bucketList.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text("확인", style: TextStyle(color: Colors.pink),),
            )
          ],
        );
      },
    );
  }
}

class CreatePage extends StatefulWidget {
  const CreatePage({Key? key}) : super(key: key);

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  TextEditingController textController = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("버킷리스트 만들기"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(CupertinoIcons.chevron_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                autofocus: true,
                controller: textController,
                decoration: InputDecoration(
                  hintText: "하고 싶은 일을 입력하세요",
                  errorText: error,
                ),
              ),
              SizedBox(
                height: 32,
              ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  child: Text(
                    "추가하기",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () {
                    //추가히기 버튼 클릭시
                    String job = textController.text;
                    if (job.isEmpty) {
                      setState(() {
                        error = "내용을 입력해주세요.";
                      });
                    } else {
                      setState(() {
                        error = null;
                      });
                      Navigator.pop(context, job);
                    }
                  },
                ),
              )
            ],
          ),
        ));
  }
}
