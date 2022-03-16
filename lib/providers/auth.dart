import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool? get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _token != null &&
        (_expiryDate as DateTime).isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId == null ? "" : _userId as String;
  }

  Future logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(('userData'))) {
      return false;
    }
    final extractUserData =
        jsonDecode(prefs.getString("userData") as String) as Map;
    final expiryDate = DateTime.parse(extractUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractUserData['token'];
    _userId = extractUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _authLogout();
    return true;
  }

  Future _authenticate(String email, String password, String urlSegment) async {
    var url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCoYsf_NCsCKu6VYvCLCqjTuYBGs_MphRk ");
    try {
      final response = await http.post(url,
          body: jsonEncode({
            "email": email,
            "password": password,
            "returnSecureToken": true,
          }));
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _authLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({
        "token": _token,
        "userId": _userId,
        "expiryDate": _expiryDate?.toIso8601String()
      });
      prefs.setString("userData", userData);
    } catch (e) {
      throw e;
    }
  }

  void _authLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  Future signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}
