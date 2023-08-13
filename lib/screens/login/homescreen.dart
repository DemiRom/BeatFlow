import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:beatflow/screens/browsing/home_page.dart';
import 'package:beatflow/screens/browsing/starred_page.dart';
import 'package:beatflow/screens/login/albums_page.dart';
import 'package:beatflow/screens/login/artists_page.dart';
import 'package:beatflow/screens/login/loginscreen.dart';
import 'package:beatflow/screens/login/settings_page.dart';
import 'package:beatflow/state/appstate.dart';

import 'myscaffold.dart';

class HomeScreen extends StatelessWidget {
  static final routeName = "/home";

  final int initialTabIndex;

  const HomeScreen({
    Key? key,
    this.initialTabIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ServerData>(
      converter: (st) => st.state.loginState,
      builder: (context, state) => !state.isValid
          ? LoginScreen()
          : DefaultTabController(
              length: 4,
              initialIndex: initialTabIndex,
              child: MyScaffold(
                appBar: AppBarSettings(
                  title: Text("Home"),
                  bottom: TabBar(
                    onTap: (idx) {},
                    tabs: [
                      Tab(
                        text: "Starred",
                      ),
                      Tab(
                        text: "Artists",
                      ),
                      Tab(
                        text: "Albums",
                      ),
                      Tab(
                        text: "Home",
                      ),
                    ],
                  ),
                ),
                body: (context) => Center(
                  child: TabBarView(
                    children: [
                      Center(child: StarredPage()),
                      Center(child: ArtistsPage()),
                      Center(child: AlbumsPage()),
                      Center(child: HomePage()),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
