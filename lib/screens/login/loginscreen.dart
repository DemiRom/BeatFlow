import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:beatflow/screens/login/myscaffold.dart';
import 'package:beatflow/screens/login/settings_page.dart';

class LoginScreen extends StatelessWidget {
  static final routeName = "/settings";

  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      disableBottomBar: true,
      appBar: AppBarSettings(
        title: const Text("Login"),
        pinned: true,
      ),
      body: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          ServerSetupForm(),
        ],
      ),
    );
  }
}
