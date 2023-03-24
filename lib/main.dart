import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:onetrust_publishers_native_cmp/onetrust_publishers_native_cmp.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test OneTrust',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Test OneTrust'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _storageLocation = 'cdn.cookielaw.org';
  static const _domainIdentifier = String.fromEnvironment('DOMAIN_IDENTIFIER');
  static const _languageCode = 'de';
  static const _apiVersion = '202301.2.0';

  static const _flutterSdkVersion = '202301.2.0';

  static const targetingCategoryId = 'C0004';

  final List<String> _logs = [];

  bool _isButtonEnabled = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _initializeSdk();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(_logs[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextButton(
              onPressed: _isButtonEnabled ? _bannerAllowAll : null,
              child: const Text('Banner Allow All'),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _initializeSdk() async {
    _logSeparator();
    _log('Flutter SDK version: $_flutterSdkVersion');
    _logSeparator();
    _log('Storage Location: $_storageLocation');
    _log('Domain Identifier: $_domainIdentifier');
    _log('Language Code: $_languageCode');
    _log('API Version: $_apiVersion');
    _logSeparator();

    _log('Initializing SDK...');

    final status = await OTPublishersNativeSDK.startSDK(
      _storageLocation,
      _domainIdentifier,
      _languageCode,
      {
        "setAPIVersion": _apiVersion,
      },
    );
    if (!status) {
      throw StateError("Could not initialize OneTrust SDK");
    }

    _log('SDK initialized successfully');

    _log('Checking consent values on initialization:');
    await _logConsentsValues();
    _logSeparator();

    _setButtonEnabled(true);
  }

  Future<void> _bannerAllowAll() async {
    OTPublishersNativeSDK.saveConsent(OTInteractionType.bannerAllowAll);

    _setButtonEnabled(false);

    _log('Banner Allow All');
    await _logConsentsValues();
    _log('Waiting 5 seconds to check again...');
    await Future.delayed(const Duration(seconds: 5));
    await _logConsentsValues();
    _logSeparator();

    _setButtonEnabled(true);
  }

  void _setButtonEnabled(bool isEnabled) {
    setState(() {
      _isButtonEnabled = isEnabled;
    });
  }

  Future<void> _logConsentsValues() async {
    final status = await OTPublishersNativeSDK.getConsentStatusForCategory(
      targetingCategoryId,
    );

    _log('getConsentStatusForCategory($targetingCategoryId) = $status');
  }

  void _logSeparator() {
    _log('==================================');
  }

  void _log(String text) {
    setState(() {
      _logs.add(text);
    });

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeIn,
      );
    });
  }
}
