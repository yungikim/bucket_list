import 'package:bucket_list/bookPage/book_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bucket_list/bookstore.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => BookService()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //검색어를 가져올 수 있도록 TextField와 연결해 준다.
  final TextEditingController searchController = TextEditingController();

  //검색 함수
  //엔터를 누르거나 돋보기 아이콘을 누를 때 호출
  void search(BookService bookService) {
    String keyword = searchController.text;
    if (keyword.isNotEmpty) {
      bookService.getBookList(keyword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookService>(builder: (context, bookService, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Book Store",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          centerTitle: false,
          actions: [
            Container(
              child: Text(
                "total ${bookService.bookList.length}",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ],
          //AppBar의 bottom은 항상 PreferredSize 위젯으로 시작해야 한다.
          bottom: PreferredSize(
            preferredSize: Size(double.infinity, 72),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(

              ),
            ),
          ),
        ),


      );
    });
  }
}
