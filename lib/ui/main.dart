import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:window_manager/window_manager.dart';

import 'about.dart';
import 'home.dart';

class Destination {
  const Destination(this.title, this.icon, this.selectedIcon);

  final String title;
  final IconData icon;
  final IconData selectedIcon;
}

void main() async {
  if (Platform.isWindows) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MyApp());
}

// Fictitious brand color.
const _brandBlue = Color(0xFF1848AF);

class MyApp extends StatelessWidget with WindowListener {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Wrap MaterialApp with a DynamicColorBuilder.
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          // On Android S+ devices, use the provided dynamic color scheme.
          // (Recommended) Harmonize the dynamic color scheme' built-in semantic colors.
          lightColorScheme = lightDynamic.harmonized();

          // Repeat for the dark color scheme.
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // Otherwise, use fallback schemes.
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: _brandBlue,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: _brandBlue,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          title: 'Sentiment Analysis',
          theme: ThemeData(
            colorScheme: lightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          home: const RootPage(title: 'Sentiment Analysis'),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key, required this.title});

  final String title;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WindowListener {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.selected;
  double groupAlignment = 0.0;

  bool busy = false;
  String busyReason = '';

  late bool showNavigationDrawer;

  var destinations = const <Destination>[
    Destination('Playground', Icons.home_outlined, Icons.home),
    Destination('About', Icons.info_outline, Icons.info),
  ];

  void callback(bool show, String text) {
    setState(() {
      busy = show;
      busyReason = text;
    });
  }

  List<Widget> getNavDrawerChildren() {
    var list = destinations.map((Destination destination) {
      return NavigationDrawerDestination(
        icon: Icon(destination.icon),
        selectedIcon: Icon(destination.selectedIcon),
        label: Text(destination.title),
      ) as Widget;
    }).toList();
    list.insert(
      0,
      DragToMoveArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            "Sentiment Analysis",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
    );
    return list;
  }

  Widget switchSelectedPage(int index) {
    switch (index) {
      case 0:
        return HomePage(callback: callback);
      case 1:
        return const AboutPage();
      default:
        return const AboutPage();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showNavigationDrawer = MediaQuery.of(context).size.width >= 845;
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _init();
  }

  void _init() async {
    // 添加此行以覆盖默认关闭处理程序
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            body: Row(
              children: [
                if (showNavigationDrawer)
                  NavigationDrawer(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    children: getNavDrawerChildren(),
                  ),
                Expanded(
                  child: Scaffold(
                    appBar: Platform.isWindows
                        ? AppBar(
                            title: const DragToMoveArea(
                              child: SizedBox(
                                width: double.infinity,
                                height: kToolbarHeight,
                              ),
                            ),
                            actions: [
                              IconButton(
                                onPressed: () {
                                  windowManager.minimize();
                                },
                                icon: const Icon(Icons.remove_outlined),
                              ),
                              IconButton(
                                onPressed: () async {
                                  if (await windowManager.isMaximized()) {
                                    windowManager.unmaximize();
                                  } else {
                                    windowManager.maximize();
                                  }
                                },
                                icon: const Icon(Icons.crop_square_outlined),
                              ),
                              IconButton(
                                onPressed: () {
                                  windowManager.close();
                                },
                                icon: const Icon(Icons.close_outlined),
                              ),
                              const SizedBox(width: 8),
                            ],
                          )
                        : (Platform.isAndroid
                            ? AppBar(
                                title: Text(destinations[_selectedIndex].title))
                            : null),
                    body: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: switchSelectedPage(_selectedIndex),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: showNavigationDrawer
                ? null
                : BottomNavigationBar(
                    currentIndex: _selectedIndex,
                    onTap: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    items: destinations.map((Destination destination) {
                      return BottomNavigationBarItem(
                        icon: Icon(destination.icon),
                        activeIcon: Icon(destination.selectedIcon),
                        label: destination.title,
                      );
                    }).toList()),
          ),
          if (busy)
            const ModalBarrier(
              dismissible: false,
              color: Colors.black54,
            ),
          if (busy)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(busyReason),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Exit'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
