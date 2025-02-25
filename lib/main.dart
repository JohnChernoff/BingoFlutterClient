import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:zug_utils/zug_utils.dart';
import 'package:zugclient/zug_app.dart';
import 'package:zugclient/zug_client.dart';
import 'bingo_lobby.dart';
import 'game_client.dart';
import 'game_page.dart';

/*
 Maybe something to share your win on various social media.
 Clearer "Select Game" dropdown?
 InstaBingo sounds

 TV should always be on

 chess logic?!

 autogenerate "interesting" board names

 quicker autoclose/removal of finished boards (filter out from list?)

 responsive(er) layout, especially when square screen

 more help (videos, etc.)

 see other player boards

 persistent (and richer) chat
 */

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
          "Welcome to $appName ${client.packageInfo?.version ?? '0.?'}, ${client.userName?.name ?? "Unknown User"}",
          style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget createMainPage(ZugClient client) => GamePage(client as GameClient);

  @override
  Widget createLobbyPage(ZugClient client) => BingoLobby(client);

}

