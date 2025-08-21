import 'package:frontend/pages/DiaryPage/DiaryPage.dart';
import 'package:frontend/pages/Inside/InsidePage.dart';
import 'package:frontend/pages/LoginSignup/LoginPage.dart';
import 'package:frontend/pages/LoginSignup/SignupPage_Email.dart';
import 'package:frontend/pages/LoginSignup/SingUpPage.dart';
import 'package:frontend/pages/MyPage/EditMyPage.dart';
import 'package:frontend/pages/MyPage/FriendPage.dart';
import 'package:frontend/pages/MyPage/GroupPage.dart';
import 'package:frontend/pages/MyPage/MyPage.dart';
import 'package:frontend/pages/TodoPage.dart';
import 'package:frontend/pages/TodoPage_new.dart';
import 'package:frontend/pages/stopwatchPage.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/stopwatchPage.dart';

import 'package:frontend/layout/navigationLayout.dart';
import 'package:frontend/layout/noLayout.dart';

import 'package:frontend/pages/MainPage/MainPage.dart';

class MainRouter {
  static final List<GetPage> routes = [
    GetPage(
      name: '/login',
      page: () => NoLayout(child: LoginPage()),
    ),
    GetPage(
      name: '/signupEmail',
      page: () => NoLayout(child: SignUpEmailPage()),
    ),
    GetPage(
      name: '/signup',
      page: () => NoLayout(child: SingupPage()),
    ),
    GetPage(
      name: '/main',
      page: () => NavigationLayout(child: MainPageView()),
    ),
    GetPage(
      name: '/Todo',
      page: () => NavigationLayout(child: NewTodoPageView()),
    ),
    GetPage(
      name: '/diary',
      page: () => NavigationLayout(child: DiaryPage()),
    ),
    GetPage(
      name: '/mypage',
      page: () => NavigationLayout(child: MyPageView()),
    ),
    GetPage(
      name: '/group',
      page: () => NoLayout(child: GroupPage()),
    ),
    GetPage(
      name: '/friend',
      page: () => NoLayout(child: Friendpage()),
    ),
    GetPage(
      name: '/inside',
      page: () => NoLayout(child: InsidePageView()),
    ),
    GetPage(
      name: '/editMypage',
      page: () => NoLayout(child: EditMypageView()),
    ),
    GetPage(
      name: '/stopwatch',
      page: () => NavigationLayout(child: StopwatchPage()),
    ),
  ];
}
