import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:video_platform_flutter/src/app.dart';

import 'fake_platform_api.dart';
import 'fake_session_store.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    FakePlatformApi? api,
    FakeSessionStore? sessionStore,
    String path = '/front/home',
  }) async {
    tester.view.physicalSize = const Size(1440, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MyApp(
        api: api ?? FakePlatformApi(),
        sessionStore: sessionStore ?? FakeSessionStore(),
        initialUri: Uri.parse('https://example.com$path'),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('guest can browse details but protected actions require login',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('open-video-video_1')).first);
    await tester.pumpAndSettle();

    expect(find.text('互动操作'), findsOneWidget);

    await tester.tap(find.byKey(const Key('detail-like-button')));
    await tester.pumpAndSettle();

    expect(find.text('该功能需要登录后使用'), findsOneWidget);
  });

  testWidgets('member can login and check in without seeing admin entry',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.person_outline).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '账号'), 'member');
    await tester.enterText(find.widgetWithText(TextField, '密码'), 'password123');
    await tester.tap(find.byKey(const Key('guest-login-button')));
    await tester.pumpAndSettle();

    expect(find.text('个人中心'), findsOneWidget);
    expect(find.byKey(const Key('enter-admin-button')), findsNothing);

    await tester.tap(find.byKey(const Key('profile-checkin-button')));
    await tester.pumpAndSettle();

    expect(find.text('签到成功'), findsOneWidget);
  });

  testWidgets('admin login shows management entry and can access console',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.person_outline).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '账号'), 'admin');
    await tester.enterText(find.widgetWithText(TextField, '密码'), 'password123');
    await tester.tap(find.byKey(const Key('guest-login-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('enter-admin-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('enter-admin-button')));
    await tester.pumpAndSettle();

    expect(find.text('管理端控制台'), findsOneWidget);
  });

  testWidgets('non admin user is blocked from admin route',
      (WidgetTester tester) async {
    await pumpApp(
      tester,
      sessionStore: FakeSessionStore('token_member'),
      path: '/admin/dashboard',
    );

    expect(find.text('当前账号没有管理员权限'), findsOneWidget);
    expect(find.text('管理端控制台'), findsNothing);
  });

  testWidgets('admin review, report, and user actions refresh UI',
      (WidgetTester tester) async {
    await pumpApp(
      tester,
      sessionStore: FakeSessionStore('token_admin'),
      path: '/admin/dashboard',
    );

    expect(find.text('管理端控制台'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.verified_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('审核视频'), findsOneWidget);
    await tester.tap(find.text('通过').last);
    await tester.pumpAndSettle();
    expect(find.text('视频已通过审核'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.flag_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('处理举报'), findsOneWidget);
    await tester.tap(find.text('标记已处理').first);
    await tester.pumpAndSettle();
    expect(find.text('举报已处理'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.people_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('用户管理'), findsAtLeastNWidgets(1));
    await tester.tap(find.text('封禁账号').first);
    await tester.pumpAndSettle();
    expect(find.text('账号状态已更新'), findsOneWidget);
  });

  testWidgets('session restore shows admin entry when me returns admin',
      (WidgetTester tester) async {
    await pumpApp(
      tester,
      sessionStore: FakeSessionStore('token_admin'),
      path: '/front/profile',
    );

    expect(find.byKey(const Key('enter-admin-button')), findsOneWidget);
  });
}
