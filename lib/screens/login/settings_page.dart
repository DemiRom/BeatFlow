// TODO:
// - edit server settings
// - clear artwork cache
// - clear file cache

import 'dart:developer';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:beatflow/screens/login/homescreen.dart';
import 'package:beatflow/screens/login/myscaffold.dart';
import 'package:beatflow/state/appstate.dart';
import 'package:beatflow/storage/cache.dart';
import 'package:beatflow/subsonic/context.dart';
import 'package:beatflow/subsonic/requests/ping.dart';
import 'package:beatflow/subsonic/response.dart';
import 'package:beatflow/utils/utils.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBarSettings(
        title: const Text("Settings"),
        pinned: true,
      ),
      disableBottomBar: true,
      body: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          ServerSettings(),
          SizedBox(height: 20),
          SettingsSect(
            title: "Caching",
            child: DownloadCacheStatsWidget(
                stats: DownloadCacheManager().getStats()),
          ),
          SizedBox(height: 10),
          ArtworkCacheStats(),
        ],
      ),
    );
  }
}

class SettingsSect extends StatelessWidget {
  final String title;
  final Widget child;

  SettingsSect({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium)
        ]),
        SizedBox(height: 5),
        child,
      ],
    );
  }
}

class ServerSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ServerSetupForm();
  }
}

class ArtworkCacheStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Artwork Cache"),
        SizedBox(height: 5),
        Text("Not implemented"),
      ],
    );
  }
}

class DownloadCacheStatsWidget extends StatelessWidget {
  final Future<CacheStats> stats;

  DownloadCacheStatsWidget({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CacheStats>(
      future: stats,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          CacheStats data = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Song cache"),
              SizedBox(height: 5),
              Text("Items: ${data.itemCount}"),
              Text("Storage used: ${formatFileSize(data.totalSize)}"),
            ],
          );
        } else {
          return Text("Calculating...");
        }
      },
    );
  }
}

class ServerSetupModel {
  final ServerData? inititalData;
  final Future<void> Function(ServerData) onSave;

  ServerSetupModel({
    this.inititalData,
    required this.onSave,
  });
}

class ServerSetupForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ServerSetupModel>(
        converter: (store) => ServerSetupModel(
            inititalData: store.state.loginState,
            onSave: (next) => store.dispatchAsync(SaveServerState(
                  next.uri,
                  next.username,
                  next.password,
                ))),
        builder: (context, model) => _ServerSetupForm(
              onSave: model.onSave,
              inital: model.inititalData,
            ));
  }
}

class _ServerSetupForm extends StatefulWidget {
  final ServerData initialData;
  final Future<void> Function(ServerData) onSave;

  const _ServerSetupForm({
    Key? key,
    ServerData? inital,
    required this.onSave,
  })  : initialData = inital ?? const ServerData(username: '', password: ''),
        super(key: key);

  @override
  State<_ServerSetupForm> createState() => _ServerSetupFormState();
}

class _ServerSetupFormState extends State<_ServerSetupForm> {
  final _formKey = GlobalKey<FormState>();
  late ServerData _dataHolder;
  bool _canSave = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _dataHolder = ServerData(
      username: widget.initialData.username,
      password: widget.initialData.password,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        onChanged: () {},
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Text('Login to Beatflow',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            TextFormField(
              initialValue: _dataHolder.username,
              decoration: const InputDecoration(hintText: "Enter username"),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return "Username can not be blank";
                } else {
                  return null;
                }
              },
              onChanged: (value) {
                log("username:onChanged $value");

                if (value.isNotEmpty) {
                  _canSave = true;
                }

                setState(() {
                  var old = _dataHolder;
                  _dataHolder = ServerData(
                    username: value,
                    password: old.password,
                  );
                });
              },
            ),
            TextFormField(
              initialValue: _dataHolder.password,
              obscureText: true,
              decoration: const InputDecoration(hintText: "Enter password"),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return "Password can not be blank";
                } else {
                  return null;
                }
              },
              onChanged: (value) {
                log("password:onChanged");

                if (value.isNotEmpty) {
                  _canSave = true;
                }

                setState(() {
                  var old = _dataHolder;
                  _dataHolder = ServerData(
                    username: old.username,
                    password: value,
                  );
                });
              },
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // ElevatedButton(
                  //   child: Text("Test"),
                  //   onPressed: _isTesting
                  //       ? null
                  //       : () async {
                  //           if (!_formKey.currentState!.validate()) {
                  //             return;
                  //           }
                  //           setState(() {
                  //             _isTesting = true;
                  //           });

                  //           var data = _dataHolder;
                  //           var ctx = SubsonicContext(
                  //             serverId: '',
                  //             name: '',
                  //             endpoint: Uri.parse(data.uri),
                  //             user: data.username,
                  //             pass: data.password,
                  //           );
                  //           var pong = await Ping().run(ctx).catchError((err) {
                  //             log('error: network issue?', error: err);
                  //             return Future.value(SubsonicResponse(
                  //               ResponseStatus.failed,
                  //               "Network issue",
                  //               '',
                  //             ));
                  //           });
                  //           if (pong.status == ResponseStatus.ok) {
                  //             setState(() {
                  //               _canSave = true;
                  //               _isTesting = false;
                  //             });
                  //             ScaffoldMessenger.of(context)
                  //               ..removeCurrentSnackBar()
                  //               ..showSnackBar(SnackBar(
                  //                   content: Text("Connection successful!")));
                  //           } else {
                  //             setState(() {
                  //               _canSave = false;
                  //               _isTesting = false;
                  //             });

                  //             final errorText =
                  //                 "Ping server ${data.uri} failed.";

                  //             ScaffoldMessenger.of(context)
                  //               ..removeCurrentSnackBar()
                  //               ..showSnackBar(
                  //                   SnackBar(content: Text(errorText)));
                  //           }
                  //         },
                  // ),
                  ElevatedButton(
                    child: _canSave ? Text("Login") : Text("Login"),
                    onPressed: _canSave
                        ? () {
                            save().then((value) {
                              Navigator.of(context)
                                  .pushReplacementNamed(HomeScreen.routeName);
                            });
                          }
                        : null,
                  ),
                ],
              ),
            )
          ],
        ));
  }

  Future<void> save() {
    return widget.onSave(ServerData(
      username: _dataHolder.username,
      password: _dataHolder.password,
    ));
  }
}
