import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:video_platform_flutter/src/app.dart';

void main() {
  testWidgets('guest can browse details but protected actions require login',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-video-video_1')));
    await tester.pumpAndSettle();

    expect(find.text('互动操作'), findsOneWidget);

    await tester.tap(find.byKey(const Key('detail-like-button')));
    await tester.pumpAndSettle();

    expect(find.text('该功能需要登录后使用'), findsOneWidget);
  });

  testWidgets('member profile supports login and check-in flow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.account_circle_outlined).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('guest-login-button')));
    await tester.pumpAndSettle();

    expect(find.text('个人中心'), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile-checkin-button')));
    await tester.pumpAndSettle();

    expect(find.text('签到成功，获得 5 枚硬币'), findsOneWidget);
  });

  testWidgets('admin can login and access management console',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('demo-role-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('管理端').last);
    await tester.pumpAndSettle();

    expect(find.text('管理员登录'), findsOneWidget);

    await tester.tap(find.byKey(const Key('admin-login-button')));
    await tester.pumpAndSettle();

    expect(find.text('管理端控制台'), findsOneWidget);
  });

  testWidgets('admin review, report, and user pages are reachable and actionable',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('demo-role-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('管理端').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('admin-login-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('视频审核'));
    await tester.pumpAndSettle();
    expect(find.text('审核视频'), findsOneWidget);

    await tester.tap(find.byKey(const Key('audit-tile-audit_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('通过').last);
    await tester.pumpAndSettle();
    expect(find.text('视频已通过审核'), findsOneWidget);

    await tester.tap(find.text('举报处理'));
    await tester.pumpAndSettle();
    expect(find.text('处理举报'), findsOneWidget);
    await tester.tap(find.text('标记已处理').first);
    await tester.pumpAndSettle();
    expect(find.text('举报已处理'), findsOneWidget);

    await tester.tap(find.text('用户管理'));
    await tester.pumpAndSettle();
    expect(find.text('用户管理'), findsAtLeastNWidgets(1));
    await tester.tap(find.text('封禁账号').first);
    await tester.pumpAndSettle();
    expect(
      find.text('账号状态已更新').evaluate().isNotEmpty ||
          find.text('账号已封禁').evaluate().isNotEmpty,
      isTrue,
    );
  });
}
