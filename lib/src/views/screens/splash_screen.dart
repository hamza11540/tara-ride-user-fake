// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../app_colors.dart';
import '../../controllers/setting_controller.dart';
import '../../controllers/splash_controller.dart';
import '../../controllers/user_controller.dart';
import '../../helper/assets.dart';
import '../../repositories/notification_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  late SplashController _con;
  late UserController _userCon;
  late SettingController _settingCon;

  SplashScreenState() : super(SplashController()) {
    _con = controller as SplashController;
    _userCon = UserController();
    _settingCon = SettingController(doInitSettings: true);
    add(_userCon);
    add(_settingCon);
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadSettings() async {
    await _settingCon.doGetSettings().then((value) {
      setState(() => _con.progress.value["Setting"] = 40);
      _con.progress.notifyListeners();
    }).catchError((error) async {
      await Future.delayed(const Duration(seconds: 5), () {
        loadSettings();
      });
    });
  }

  Future<void> initializeFirebase() async {
    await NotificationRepository().initializeFirebase().then((value) {
      setState(() => _con.progress.value["Firebase"] = 20);
      _con.progress.notifyListeners();
    }).catchError((error) async {
      await Future.delayed(const Duration(seconds: 10), () {
        initializeFirebase();
      });
    });
  }

  Future<void> verifyLogin() async {
    await _userCon.doVerifyLogin().then((value) {
      setState(() => _con.progress.value["User"] = 40);
      _con.progress.notifyListeners();
    }).catchError((error) async {
      await Future.delayed(const Duration(seconds: 10), () {
        verifyLogin();
      });
    });
  }

  Future<void> loadData() async {
    verifyLogin();
    loadSettings();
    initializeFirebase();
    _con.progress.addListener(() {
      double progress = 0;
      for (var _progress in _con.progress.value.values) {
        progress += _progress;
      }
      if (progress == 100) {
        Navigator.of(context).pushReplacementNamed("/Home");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.mainBlue,
        body: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/img/eb669a40-feb6-47af-b97d-3e6571162c41.JPG',
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Text("Tara Ride",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mainBlue)),
                Text("Move with safety",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w200,
                        color: AppColors.mainBlue)),
                const SizedBox(height: 50),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainBlue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
