import 'dart:developer';
import 'package:bingo_client/dialogs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:zug_utils/zug_utils.dart';
import 'package:zugclient/lobby_page.dart';
import 'package:zugclient/zug_app.dart';
import 'package:zugclient/zug_client.dart';
import 'package:zugclient/zug_fields.dart';
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

class BingoLobby extends LobbyPage {
  const BingoLobby(super.client, {
    super.backgroundImage,
    super.areaName = "BingoGame",
    super.bkgCol,
    super.buttonsBkgCol,
    super.style = LobbyStyle.tersePort,
    super.width,
    super.borderWidth  = 1,
    super.borderCol = Colors.white,
    super.areaFlex  = 3,
    super.key, super.chatArea});

  @override
  List<DataColumn> getOccupantHeaders({Color color = Colors.white}) {
    return [
      DataColumn(label: Expanded(child: Text("Name",style: TextStyle(color: color)))),
      DataColumn(label: Expanded(child: Text("Gold",style: TextStyle(color: color)))),
      DataColumn(label: Expanded(child: Text("Games",style: TextStyle(color: color)))),
    ];
  }

  @override
  DataRow getOccupantData(UniqueName uName, Map<String,dynamic> json, {Color color = Colors.white}) { //print("json: $json , name: $uName");
    return DataRow(cells: [
      DataCell(Text(uName.name,style: TextStyle(color: color))),
      DataCell(Text("${json["user"]["gold"]}", style: TextStyle(color: color))),
      DataCell(Text("${json["user"]["games"]}", style: TextStyle(color: color))),
    ]);
  }

  @override
  List<Widget> getExtraCmdButtons() {
    return [
      ElevatedButton(
          style: getButtonStyle(Colors.white, Colors.greenAccent),
          onPressed: () async => HelpDialog(client as GameClient,await rootBundle.loadString('txt/help.txt')).raise(),
          child: Text("Help", style: getButtonTextStyle())
      ),
      ElevatedButton(
          style: getButtonStyle(Colors.blue, Colors.greenAccent),
          onPressed: () {}, //=> client.fetchOptions(() => OptionDialog(client as GameClient).raise()),
          child: Text("options", style: getButtonTextStyle())
      ),
      ElevatedButton(
          style: getButtonStyle(Colors.green, Colors.redAccent),
          onPressed: () => client.send(GameMsg.top),
          child: Text("Scores", style: getButtonTextStyle())
      ),
    ];
  }

}