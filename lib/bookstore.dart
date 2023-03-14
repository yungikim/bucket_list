import 'package:bucket_list/bookPage/book_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bucket_list/bookstore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bookPage/book.dart';

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
    print("검색을 수행합니다");
    String keyword = searchController.text;
    if (keyword.isNotEmpty) {
      if (bookService.bookList.length > 0){
        bookService.bookList.clear();
      }

      bookService.getBookList(keyword);
    }else{
      print("검색결과가 존재하지 않습니다");
    }

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<BookService>(builder: (context, bookService, child) {
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
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(right: 12),
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
                preferredSize: Size.fromHeight(80.0), // Size(double.infinity, 72),
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: TextField(

                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "원하는 책을 검색해주세요",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),

                      ),
                      //돋보기 아이콘 포커스시 표시됨
                      suffix: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          //돋보기 아이콘 클릭
                          search(bookService);
                        },
                      ),
                    ),
                    onSubmitted: (_) {
                      search(bookService);
                    },
                  ),
                ),
              ),
            ),
            body: bookService.bookList.isEmpty
                ? Center(
                    child: Text(
                      "검색어를 입력해 주세요",
                      style: TextStyle(fontSize: 21, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: bookService.bookList.length,
                    itemBuilder: (context, index) {
                      Book book = bookService.bookList[index];
                      return ListTile(
                        leading: Image.network(
                          book.thumbnail,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        title: Text(book.title),
                        subtitle: Text(book.subtitle),
                        onTap: () {
                          Uri uri = Uri.parse(book.previewLink);
                          launchUrl(uri);
                        },
                      );
                    },
                  ));
      }),
    );
  }
}
