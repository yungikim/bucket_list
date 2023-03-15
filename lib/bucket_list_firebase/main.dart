import 'package:bucket_list/bucket_list_firebase/auth_service.dart';
import 'package:bucket_list/bucket_list_firebase/bucket_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthService()),
      ChangeNotifierProvider(create: (context) => BucketService()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = context.read<AuthService>().currentUser();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //main에서 async를 사용하기 위해서 이부분을 추가해 줘야 한다.
      home: user == null ? LoginPage() : HomePage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        User? user = authService.currentUser();

        return Scaffold(
          appBar: AppBar(title: Text("로그인")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    user == null ? "로그인해 주세요 🙂" : "${user.email}님 안녕하세요",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
                SizedBox(
                  height: 32,
                ),

                //이메일
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "이메일",
                  ),
                ),

                //비밀번호
                TextField(
                  controller: passwordController,
                  obscureText: false, //비밀번호 안보이게
                  decoration: InputDecoration(
                    hintText: "비밀번호",
                  ),
                ),

                SizedBox(
                  height: 32,
                ),
                ElevatedButton(
                  onPressed: () {
                    authService.signIn(
                        email: emailController.text,
                        password: passwordController.text,
                        onSuccess: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("로그인 성공"),
                            ),
                          );
                          //HomePage로 이동
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                        onError: (e) {
                          //에러 발생
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e),
                            ),
                          );
                        });
                  },
                  child: Text(
                    "로그인",
                    style: TextStyle(fontSize: 21),
                  ),
                ),

                //회원가입 버튼
                ElevatedButton(
                  onPressed: () {
                    authService.signUp(
                      email: emailController.text,
                      password: passwordController.text,
                      onSuccess: () {
                        //회원가입 성공
                        print("회원가입 성공");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("회원가입 성공"),
                        ));
                      },
                      onError: (err) {
                        //에러 발생
                        print("회원가입실패 : $err");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(err),
                        ));
                      },
                    );
                  },
                  child: Text(
                    "회원 가입",
                    style: TextStyle(fontSize: 21),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//홈페이지
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController jobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<BucketService>(
      builder: (context, bucketService, child) {
        final authService = context.read<AuthService>();
        User user = authService.currentUser()!;
        return Scaffold(
          appBar: AppBar(
            title: Text("버킷 리스트"),
            actions: [
              TextButton(
                onPressed: () {
                  //로그 아웃
                  context.read<AuthService>().signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text(
                  "로그아웃",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: jobController,
                        decoration: InputDecoration(
                          hintText: "하고 싶은 일을 입력하세요",
                        ),
                      ),
                    ),

                    //추가 버튼
                    ElevatedButton(
                      onPressed: () {
                        //create bucket
                        if (jobController.text.isNotEmpty) {
                          bucketService.create(jobController.text, user.uid);
                        }
                      },
                      child: Icon(Icons.add),
                    )
                  ],
                ),
              ),
              Divider(height: 1,),

              //버킷 리스트
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                  future: bucketService.read(user.uid),
                  builder: (context, snapshot) {
                    print(snapshot.hasData);
                    final documents = snapshot.data?.docs ?? [];
                    if (documents.isEmpty){
                      return Center(child: Text("버킷 리스트를 작성해주세요"));
                    }
                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        String job = doc.get("job");
                        bool isDone = doc.get("isDone");
                        return ListTile(
                          title: Text(
                            job,
                            style: TextStyle(
                              fontSize: 24,
                              color: doc.get("isDone") ? Colors.grey : Colors.black,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(CupertinoIcons.delete),
                            onPressed: (){
                              //삭제 함수
                              bucketService.delete(doc.id);
                            },
                          ),
                          onTap: (){
                            bucketService.update(doc.id, !doc.get("isDone"));
                          },
                        );
                      },
                    );
                  }
                ),
              )
            ],
          ),
        );
      }
    );
  }
}
