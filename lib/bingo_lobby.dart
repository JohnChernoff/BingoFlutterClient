import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zugclient/lobby_page.dart';
import 'package:zugclient/options_page.dart';
import 'package:zugclient/zug_client.dart';

import 'dialogs.dart';
import 'game_client.dart';

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
  List<Widget> getExtraCmdButtons(BuildContext context) {
    return [
      ElevatedButton(
          style: getButtonStyle(Colors.white, Colors.greenAccent),
          onPressed: () async => HelpDialog(client as GameClient,await rootBundle.loadString('txt/help.txt')).raise(),
          child: Text("Help", style: getButtonTextStyle())
      ),
      ElevatedButton(
          style: getButtonStyle(Colors.blue, Colors.greenAccent),
          onPressed: () => OptionDialog(client as GameClient,context,OptionScope.general).raise(),
          child: Text("Settings", style: getButtonTextStyle())
      ),
      ElevatedButton(
          style: getButtonStyle(Colors.green, Colors.redAccent),
          onPressed: () => client.send(GameMsg.top),
          child: Text("Scores", style: getButtonTextStyle())
      ),
    ];
  }

}
