import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart' hide Color;
import 'package:zugclient/lobby_page.dart';
import 'package:zugclient/zug_chat.dart';
import 'package:zugclient/zug_fields.dart';
import 'bingo_board_widget.dart';
import 'game.dart';
import 'game_client.dart';
import 'main.dart';

class GamePage extends StatefulWidget {
  static TextStyle txtStyle = const TextStyle(color: Colors.white);
  final GameClient client;
  const GamePage(this.client, {super.key});

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<GamePage> {
  ChessBoardController chessBoardController = ChessBoardController();

  @override
  void initState() {
    super.initState();
    widget.client.areaCmd(ClientMsg.setDeaf,data:{fieldDeafened:false});
  }

  @override
  Widget build(BuildContext context) {
    //List<BingoBoard> boards = widget.client.currentGame.boards;  //if (boards.isEmpty) return LobbyPage(widget.client, style: LobbyStyle.tersePort, width: 320);
    BingoBoard? userBoard = widget.client.currentGame.getBoardByUser(widget.client.userName);
    List<BingoBoard> otherBoards = widget.client.currentGame.getOtherBoards(widget.client.userName);
    chessBoardController.loadFen(Game.fen ?? "");
    return Container(color: Colors.black, child : LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) =>
        constraints.maxWidth > constraints.maxHeight
            ? getLandscapeLayout(userBoard, otherBoards, constraints)
            : getPortraitLayout(userBoard, otherBoards, constraints)
    ));
  }

  ButtonStyle getInstaButtStyle(dynamic player, {pressCol = Colors.redAccent, pressedCol = Colors.lightBlueAccent, normCol = Colors.greenAccent}) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return pressCol;
        }
        else {
          if (player != null && player["instatry"] == true) {
            return pressedCol;
          } else {
            return normCol;
          }
        } // Use the component's default.
      },
      ),
    );
  }

  Widget getTextBox(String txt, Color color, {txtCol = Colors.black, borderCol = Colors.white, borderWidth = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderCol, width: borderWidth)
      ),
      child: Text(txt,style: TextStyle(color: txtCol)),
    );
  }

  Widget getLandscapeLayout(BingoBoard? userBoard,List<BingoBoard> otherBoards,BoxConstraints constraints) {
    dynamic player = widget.client.currentGame.getOccupant(widget.client.userName);

    bool isRunning = widget.client.currentGame.phase == "running";
    Color borderColor = isRunning ? Colors.white : Colors.brown;
    bool isActiveGame = isRunning && player != null;
    double headerHeight = 128;
    double boardSize = min(constraints.maxWidth / 4,constraints.maxHeight * .8);
    double upperHeight = boardSize + headerHeight;
    double bottomHeight = constraints.maxHeight - upperHeight;

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            //height: upperHeight,
            child: Column(
            children: [
            //status
            if (widget.client.currentGame.phase != null) Text(
              "${widget.client.currentGame.title} (${widget.client.currentGame.phase})",
              style: GamePage.txtStyle,
            ),
            const SizedBox(height: 16),
            //info
            if (widget.client.currentGame.phase != null) Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getTextBox("Ante: ${widget.client.currentGame.ante} ",Colors.redAccent),
                getTextBox("Pot: ${widget.client.currentGame.pot} ",Colors.greenAccent),
                getTextBox("Insta-Pot: ${widget.client.currentGame.instapot} ",Colors.blueAccent),
                ]
            ),
            const SizedBox(height: 16),
            //Insta-Bingo Button
            if (isActiveGame) ElevatedButton(onPressed: () => widget.client.areaCmd(GameMsg.instaBingo),
                style: getInstaButtStyle(player, normCol: Colors.green),
                child: const Text("Insta-Bingo",style: TextStyle(color: Colors.black))),
            const SizedBox(height: 16),
            //TV and user boards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (userBoard != null) BingoBoardWidget(userBoard, boardSize, borderColor: borderColor),
                ChessBoard(
                  controller: chessBoardController,
                  size: boardSize,
                  boardColor: BoardColor.darkBrown,
                  blackPieceColor: Colors.white,
                ),
              ],
            ),
            //other player boards
            SizedBox(
              height: bottomHeight,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                        otherBoards.length,
                        (index) => BingoBoardWidget(borderColor: borderColor,
                            otherBoards.elementAt(index), bottomHeight * .8)),
                  ))),
            ]),
          ),
        BingoLobby(widget.client,
          style: LobbyStyle.tersePort,
          width: 320,
          buttonsBkgCol: Colors.black,
          areaFlex: 1,
          chatArea: ZugChat(widget.client, width: 320))
      ]);
  }

  Widget getPortraitLayout(BingoBoard? userBoard,List<BingoBoard> otherBoards,BoxConstraints constraints) {
    return const Text("Ergh");
  }
}

