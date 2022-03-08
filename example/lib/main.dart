// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TrayListener, WindowListener {
  @override
  void initState() {
    trayManager.addListener(this);
    windowManager.addListener(this);
    _init();
    super.initState();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  void _init() async {
    await trayManager.setIcon(
      Platform.isWindows
          ? 'images/tray_icon_original.ico'
          : 'images/tray_icon_original.png',
    );
    List<MenuItem> items = [
      MenuItem(
        key: 'show_window',
        title: 'Show Window',
      ),
      MenuItem(
        key: 'hide_window',
        title: 'Hide Window',
      ),
      MenuItem(
        key: 'show_alert_ok',
        title: 'Show OK',
      ),
      MenuItem.separator,
      MenuItem(
        key: 'exit_app',
        title: 'Exit App',
      ),
    ];
    await trayManager.setContextMenu(items);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text('Flutter Platform Alert')),
            body: ListView(children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Play Alert Sounds',
                    style: Theme.of(context).textTheme.headline6),
              ),
              ListTile(
                  onTap: () async {
                    await FlutterPlatformAlert.playAlertSound();
                  },
                  title: const Text('Play Alert Sound (Default)')),
              ListTile(
                  onTap: () async {
                    await FlutterPlatformAlert.playAlertSound(
                      iconStyle: IconStyle.exclamation,
                    );
                  },
                  title: const Text('Play Alert Sound (exclamation)')),
              ListTile(
                  onTap: () async {
                    await FlutterPlatformAlert.playAlertSound(
                      iconStyle: IconStyle.error,
                    );
                  },
                  title: const Text('Play Alert Sound (error)')),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Text('Standard Alert with Styles',
                    style: Theme.of(context).textTheme.headline6),
              ),
              ListTile(
                  onTap: () async {
                    final result = await FlutterPlatformAlert.showAlert(
                      windowTitle: '白日依山盡 黃河入海流',
                      text: '芋頭西米露 保力達蠻牛',
                      iconStyle: IconStyle.exclamation,
                      alertStyle: AlertButtonStyle.abortRetryIgnore,
                      options: FlutterPlatformAlertOption(
                        runAsSheetOnMac: true,
                        preferMessageBoxOnWindows: true,
                      ),
                    );
                    print(result);
                  },
                  title: const Text('Show non-ascii characters')),
              const Divider(),
              ListTile(
                  onTap: () async {
                    final result = await FlutterPlatformAlert.showAlert(
                      windowTitle: 'This ia title',
                      text: 'This is body',
                      iconStyle: IconStyle.warning,
                    );
                    print(result);
                  },
                  title: const Text('Show warning style')),
              ListTile(
                  onTap: () async {
                    final result = await FlutterPlatformAlert.showAlert(
                      windowTitle: 'This ia title',
                      text: 'This is body',
                      iconStyle: IconStyle.information,
                    );
                    print(result);
                  },
                  title: const Text('Show information style')),
              ListTile(
                  onTap: () async {
                    final result = await FlutterPlatformAlert.showAlert(
                      windowTitle: 'This ia title',
                      text: 'This is body',
                      iconStyle: IconStyle.error,
                    );
                    print(result);
                  },
                  title: const Text('Show error style')),
              const Divider(),
              ListTile(
                  onTap: () async {
                    final result = await FlutterPlatformAlert.showAlert(
                        windowTitle: 'This ia title', text: 'This is body');
                    print(result);
                  },
                  title: const Text('Show OK')),
              ListTile(
                  onTap: () async {
                    final result = await FlutterPlatformAlert.showAlert(
                        windowTitle: 'This ia title',
                        text: 'This is body',
                        alertStyle: AlertButtonStyle.okCancel);
                    print(result);
                  },
                  title: const Text('Show OK/Cancel')),
              ListTile(
                  onTap: () async {
                    final result = await FlutterPlatformAlert.showAlert(
                        windowTitle: 'This ia title',
                        text: 'This is body',
                        alertStyle: AlertButtonStyle.abortRetryIgnore);
                    print(result);
                  },
                  title: const Text('Show Abort/Retry/Ignore')),
              ListTile(
                  onTap: () async {
                    final result = await FlutterPlatformAlert.showAlert(
                        windowTitle: 'This ia title',
                        text: 'This is body',
                        alertStyle: AlertButtonStyle.cancelTryContinue);
                    print(result);
                  },
                  title: const Text('Show Cancel/Try/Continue')),
              ListTile(
                  onTap: () async {
                    final result = await FlutterPlatformAlert.showAlert(
                        windowTitle: 'This ia title',
                        text: 'This is body',
                        alertStyle: AlertButtonStyle.retryCancel);
                    print(result);
                  },
                  title: const Text('Show Retry/Cancel')),
              ListTile(
                  onTap: () async {
                    final result = await FlutterPlatformAlert.showAlert(
                        windowTitle: 'This ia title',
                        text: 'This is body',
                        alertStyle: AlertButtonStyle.yesNo);
                    print(result);
                  },
                  title: const Text('Show Yes/No')),
              ListTile(
                  onTap: () async {
                    final result = await FlutterPlatformAlert.showAlert(
                        windowTitle: 'This ia title',
                        text: 'This is body',
                        alertStyle: AlertButtonStyle.yesNoCancel);
                    print(result);
                  },
                  title: const Text('Show Yes/No/Cancel')),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Custom Alerts',
                    style: Theme.of(context).textTheme.headline6),
              ),
              ListTile(
                  onTap: () async {
                    final result = await FlutterPlatformAlert.showCustomAlert(
                      windowTitle: 'This ia title',
                      text: 'This is body',
                      positiveButtonTitle: "Positive",
                      negativeButtonTitle: "Negative",
                      neutralButtonTitle: "Neutral",
                      options: FlutterPlatformAlertOption(
                          additionalWindowTitleOnWindows: 'Window title',
                          showAsLinksOnWindows: false),
                    );
                    print(result);
                  },
                  title: const Text('Show Positive/Negative/Neutral')),
              ListTile(
                  onTap: () async {
                    final result = await FlutterPlatformAlert.showCustomAlert(
                      windowTitle: 'This ia title',
                      text: 'This is body',
                      positiveButtonTitle: "Positive",
                      negativeButtonTitle: "Negative",
                      neutralButtonTitle: "Neutral",
                      options: FlutterPlatformAlertOption(
                          additionalWindowTitleOnWindows: 'Window title',
                          showAsLinksOnWindows: true),
                    );
                    print(result);
                  },
                  title: const Text(
                      'Show Positive/Negative/Neutral (as links on windows)')),
            ])));
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show_window':
        await windowManager.show();
        await windowManager.setSkipTaskbar(false);
        break;
      case 'hide_window':
        await windowManager.hide();
        await windowManager.setSkipTaskbar(true);
        break;
      case 'show_alert_ok':
        final result = await FlutterPlatformAlert.showAlert(
            windowTitle: 'This ia title', text: 'This is body');
        print(result);
        break;
      default:
        break;
    }
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }
}
