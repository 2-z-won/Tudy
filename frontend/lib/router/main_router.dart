import 'package:get/get.dart';

import 'package:frontend/layout/navigationLayout.dart';
import 'package:frontend/layout/noLayout.dart';

import 'package:frontend/pages/MainPage.dart';

class MainRouter {
  static final List<GetPage> routes = [
    GetPage(
      name: '/main',
      page: () => NavigationLayout(child: MainPageView()),
    ),
    // GetPage(
    //   name: '/main',
    //   page: () => NoLayout(child: MainPageView()),
    // ),
  ];
}
