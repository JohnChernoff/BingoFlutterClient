import 'dart:developer';
import 'package:bingo_client/dialogs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:zug_utils/zug_utils.dart';
import 'package:zugclient/lobby_page.dart';
import 'package:zugclient/options_page.dart';
import 'package:zugclient/zug_app.dart';
import 'package:zugclient/zug_client.dart';
import 'package:zugclient/zug_fields.dart';
import 'bingo_lobby.dart';
import 'game_client.dart';
import 'game_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  String appName = "Bingo Chess";
  ZugUtils.getIniDefaults("defaults.ini").then((defaults) {
    ZugUtils.getPrefs().then((prefs) {
      String domain = defaults["domain"] ?? "chess.bingo";
      int port = int.parse(defaults["port"] ?? "5678");
      String endPoint = defaults["endpoint"] ?? "bingosrv";
      bool localServer = bool.parse(defaults["localServer"] ?? "true");
      log("Starting $appName Client, domain: $domain, port: $port, endpoint: $endPoint, localServer: $localServer");
      GameClient client = GameClient(domain,port,endPoint,prefs,localServer : localServer);
      runApp(GameApp(client,appName));
    });
  });
}

class GameApp extends ZugApp {
  GameApp(super.client, super.appName,
      {super.key, super.logLevel = Level.INFO, super.noNav = kIsWeb});

  @override
  AppBar createAppBar(BuildContext context, ZugClient client,
      {Widget? txt, Color? color}) {
    return AppBar(
      backgroundColor: Colors.black,
      title: Text(
          "Welcome to $appName, ${client.userName?.name ?? "Unknown User"}! ",
          style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget createMainPage(client) => GamePage(client);

  @override
  Widget createLobbyPage(client) => BingoLobby(client);

}

