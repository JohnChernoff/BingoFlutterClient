import 'package:bingo_client/game_client.dart';
import 'package:flutter/material.dart';
import 'package:zugclient/zug_app.dart';

class TopDialog {
  BuildContext ctx;
  List<dynamic> data;
  TopDialog(this.ctx, this.data);

  Future<bool?> raise() {
    return showDialog<bool?>(
        context: ctx,
        builder: (BuildContext context) {
          return SimpleDialog(children: [DataTable(columns: const [
            DataColumn(label: Text("Name")),
            DataColumn(label: Text("Gold")),
          ], rows: List.generate(data.length, (index) =>
              DataRow(cells: [
                DataCell(getCell(data[index]?["playerName"] ?? "?",Colors.white,Colors.black)),
                DataCell(getCell(data[index]?["gold"]?.toString() ?? "?",Colors.white,Colors.black)),
              ])),
          )]);
        });
  }

  Widget getCell(String txt, Color bgCol, Color txtCol) {
    return Container(color: bgCol, child: Text(txt,style: TextStyle(color: txtCol)));
  }
}

class HelpDialog {
  GameClient client;
  String helpTxt;

  HelpDialog(this.client, this.helpTxt);

  Future<void> raise() async {
    if (zugAppNavigatorKey.currentContext == null) return;
    return showDialog<void>(
        context: zugAppNavigatorKey.currentContext!,
        builder: (BuildContext context) {
          return SimpleDialog(
              backgroundColor: Colors.cyan,
              children: [
                Text(helpTxt),
                HelpModeDialogOption(client),
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Return",style: TextStyle(backgroundColor: Colors.white)),
                ),
          ]);
        });
  }
}

class HelpModeDialogOption extends StatefulWidget {
  final GameClient client;
  const HelpModeDialogOption(this.client,{super.key});
  @override
  State<StatefulWidget> createState() => HelpModeDialogOptionState();
}

class HelpModeDialogOptionState extends State<HelpModeDialogOption> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () {
        setState(() => widget.client.setHelpMode(!widget.client.helpMode));
      },
      child: Text("${widget.client.helpMode ? 'Deactivate' : 'Activate'} Help Mode",style: const TextStyle(backgroundColor: Colors.lime)),
    );
  }
}