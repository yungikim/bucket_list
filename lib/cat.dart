import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  //main() 함수에서 async를 쓰려면 필요
  WidgetsFlutterBinding.ensureInitialized();
  //shared_preferences 인스턴스 생성
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => CatService(prefs)),
    ],
    child: Myapp(),
  ));
}

class Myapp extends StatelessWidget {
  const Myapp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class CatService extends ChangeNotifier {
  //고양이 사진을 담을 변수
  List<String> catImages = [];

  //좋아요 사진
  List<String> favoriteImages = [];

  //sharedPrefernces 인스턴스
  SharedPreferences prefs;

  //생성자
  CatService(this.prefs) {
    print("CatService 시작한다.");
    getRandomCatImages();

    //favorites로 저장된 favoriteImages를 가져옵니다.
    //저장된 값이 없는 경우 null을 반환하므로 이때는 빈 배열을 넣어줍니다.
    favoriteImages = prefs.getStringList("favorites") ?? [];
    print(favoriteImages.length);
  }

  void getRandomCatImages() async {
    var result = await Dio().get(
      "https://api.thecatapi.com/v1/images/search?limit=10&mime_type=jpg",
    );
   // print(result.data);
    for (int i = 0; i < result.data.length; i++) {
      var map = result.data[i];
     // print(map);
      print(map['url']);
      catImages.add(map['url']);
    }

    notifyListeners();
  }

  void toggleFavoriteImage(String catImage){
    if (favoriteImages.contains(catImage)){
      favoriteImages.remove(catImage);
    }else{
      favoriteImages.add(catImage);
    }
    print("저장합니다");
    prefs.setStringList("favorites", favoriteImages);

    notifyListeners();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CatService>(builder: (context, catService, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text("랜덤 고양이"),
          backgroundColor: Colors.amber,
          actions: [
            //종아요 페이지로 이동
            IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritePage()),
                );
              },
            )
          ],
        ),
        body: GridView.count(
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: EdgeInsets.all(8),
          crossAxisCount: 2,
          children: List.generate(
              catService.catImages.length, (index) {
            String catImage = catService.catImages[index];
            return GestureDetector(
              onTap: () {
                print("클릭 $index");
                catService.toggleFavoriteImage(catImage);
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      catImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Icon(
                      Icons.favorite,
                      color: catService.favoriteImages.contains(catImage) ? Colors.amber : Colors.transparent,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      );
    });
  }
}

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CatService>(builder: (context, catService, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text("좋아요"),
          backgroundColor: Colors.amber,
        ),
        body: GridView.count(
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: EdgeInsets.all(8),
          crossAxisCount: 2,
          children: List.generate(
              catService.favoriteImages.length,
              (index) {
            String catImage = catService.favoriteImages[index];
            return GestureDetector(
              onTap: () {
                catService.toggleFavoriteImage(catImage);
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      catImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Icon(
                      Icons.favorite,
                      color: catService.favoriteImages.contains(catImage) ? Colors.amber : Colors.transparent,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      );
    });
  }
}
