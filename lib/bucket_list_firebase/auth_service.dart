import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  User? currentUser() {
    //현재 유저(로그인 되지 않은 경우 null 반환)
    return FirebaseAuth.instance.currentUser;
  }

  void signUp({
    required String email,
    required String password,
    required Function onSuccess,
    required Function(String err) onError,
  }) async {
    //회원 가입
    if (email.isEmpty) {
      onError("이메일을 입력해주세요");
      return;
    } else if (password.isEmpty) {
      onError("패스워드릉 입력해주세요");
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      //성공 함수 호출
      onSuccess();
    } on FirebaseAuthException catch (e) {
      print(e.message);
      if (e.message == "weak-password") {
        onError('비밀번호를 6자리 이상 입력해 주세요');
      } else if (e.message == "email-already-in-use") {
        onError('이미 가입된 이메일 입니다.');
      } else if (e.message == "invalid-email") {
        onError('이메일 형식을 확인해 주세요');
      } else if (e.message == "user-not-found") {
        onError('일치하는 이메일이 없습니다');
      } else if (e.message == "wrong-password") {
        onError('비밀번호가 일치하지 않습니다');
      } else {
        onError(e.message!);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  void signIn({
    required String email,
    required String password,
    required Function onSuccess,
    required Function(String err) onError,
  }) async {
    //로그인
    if (email.isEmpty) {
      onError("이메일을 입력해주세요");
      return;
    } else if (password.isEmpty) {
      onError("패스워드릉 입력해주세요");
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );

      onSuccess();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      onError(e.toString());
    }
  }

  void signOut() async {
    //로그 아웃
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }

}