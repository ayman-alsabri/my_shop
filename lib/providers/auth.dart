import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _timer;



  bool get isAuthinticated {
    
    return token != null;
  }

  String? get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now())) {
      return _token;
    }

    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> signUp(String email, String password) async {
    final Uri url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyAjfpnYJCIzDi_Z8XTRCQI_25Jj0x-mCkg');
    final response = await http.post(url,
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }));
    final response2 = jsonDecode(response.body);

    if (response2['error'] != null) {
      throw HttpException(response2['error']['message']);
    }
    _token = response2['idToken'];
    _expiryDate = DateTime.now()
        .add(Duration(seconds: int.parse(response2['expiresIn'])));
    _userId = response2['localId'];
    _autoLogOut();
    notifyListeners();
    final pref = await SharedPreferences.getInstance();
    final insertedData = jsonEncode({
      'token': _token,
      'expiryDate': _expiryDate!.toIso8601String(),
      'userId': _userId,
    });
    pref.setString('userData', insertedData);
  }

  Future<void> logIn(String email, String password) async {
    final Uri url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyAjfpnYJCIzDi_Z8XTRCQI_25Jj0x-mCkg');
    final response = await http.post(url,
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }));
    final response2 = jsonDecode(response.body);
    if (response2['error'] != null) {
      throw HttpException(response2['error']['message']);
    }
    _token = response2['idToken'];
    _expiryDate = DateTime.now()
        .add(Duration(seconds: int.parse(response2['expiresIn'])));

    _userId = response2['localId'];
    _autoLogOut();

    notifyListeners();
    final pref = await SharedPreferences.getInstance();
    final insertedData = jsonEncode({
      'token': _token,
      'expiryDate': _expiryDate!.toIso8601String(),
      'userId': _userId,
    });
    pref.setString('userData', insertedData);
  }

  Future<bool> autoLogin() async {
    final pref = await SharedPreferences.getInstance();
    final extractedData =
        jsonDecode((pref.get('userData') as String?)??'') as Map<String, dynamic>;
        
    if (extractedData['token'] == null ||
        extractedData['expiryDate'] == null ||
        extractedData['userId'] == null) {
          
      return false;
      
    }
    if (DateTime.parse(extractedData['expiryDate']).isBefore(DateTime.now())) {
                

      return false;
    }  
      _token = extractedData['token'];
      _expiryDate = DateTime.parse(extractedData['expiryDate']);
      _userId = extractedData['userId'];
      
      notifyListeners();
                

      return true;
    
  }

  Future<void> logOut() async{
    final pref =await SharedPreferences.getInstance();
    pref.clear();
    _token = null;
    _userId = null;
    _expiryDate = null;

    if (_timer != null) {
      _timer!.cancel();
    }
    notifyListeners();
  }

  void _autoLogOut() {
    if (_timer != null) {
      _timer!.cancel();
    }
    final expiryDuration =
        _expiryDate?.difference(DateTime.now()).inSeconds ?? 0;

    _timer = Timer(
      Duration(seconds: expiryDuration),
      () => logOut(),
    );
  }
}
