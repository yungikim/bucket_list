class Book{
  String title;
  String subtitle;
  String thumbnail;
  String previewLink;

  Book({
    required this.title,
    required this.subtitle,
    required this.thumbnail,
    required this.previewLink,
  });

  //Map<String, dynamci>을 전달 받아 Book클래스 인스턴스를 반환하는 함수
  //Factory 키워드를 붙여서 생성자로 사용

  factory Book.fromJson(Map<String, dynamic> volumeInfo){
    return Book(
      //title이 없는 경우 빈 문자열 할당
        title: volumeInfo["title"] ?? "",
        subtitle: volumeInfo["subtitle"] ?? "",
        thumbnail: volumeInfo["imageLinks"] ? ["thumbnail"] ?? "https://i.ibb.co/2ypYwdr/no-photo.png",
        previewLink: volumeInfo["previewLink"] ?? ""
    );
  }
}