import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart' hide Color;
import 'package:zugclient/lobby_page.dart';
import 'package:zugclient/zug_chat.dart';
import 'package:zugclient/zug_fields.dart';
import 'game.dart';
import 'game_client.dart';
import 'main.dart';

class GamePage extends StatefulWidget {
  static TextStyle textStyle = const TextStyle(color: Colors.white);
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

  Widget getLandscapeLayout(BingoBoard? userBoard,List<BingoBoard> otherBoards,BoxConstraints constraints) {
    TextStyle txtStyle = const TextStyle(color: Colors.white);
    bool isRunning = widget.client.currentGame.phase == "running";
    Color borderColor = isRunning ? Colors.white : Colors.brown;
    bool isActiveGame = isRunning && widget.client.currentGame.containsOccupant(widget.client.userName);
    double boardSize = constraints.maxWidth / 4;
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
      Expanded(child: Column(
        children: [
          if (widget.client.currentGame.phase != null) Text(
            "${widget.client.currentGame.title} (${widget.client.currentGame.phase})",
            style: txtStyle,
          ),
          const SizedBox(height: 16),
          if (isActiveGame) ElevatedButton(onPressed: () => widget.client.areaCmd(GameMsg.instaBingo),
              style: ButtonStyle(
                  backgroundColor: WidgetStateColor.resolveWith((state) => Colors.greenAccent), //foregroundColor: WidgetStateColor.resolveWith((state) => Colors.black),
              ),
              child: const Text("Insta-Bingo",style: TextStyle(color: Colors.black))),
          Expanded(
              child: Row(
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
          )),
          SizedBox(
              height: 480,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                        otherBoards.length,
                        (index) => BingoBoardWidget(borderColor: borderColor,
                            otherBoards.elementAt(index), boardSize / 2)),
                  )))
        ],
      )),
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

class BingoBoardWidget extends StatelessWidget {
  final double size;
  final BingoBoard board;
  final Color borderColor, checkColor, uncheckColor;
  const BingoBoardWidget(this.board, this.size, {
        required this.borderColor,
        this.checkColor = Colors.green,
        this.uncheckColor = Colors.black,
        super.key}
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: size, height: size,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(board.playerName.name, style: GamePage.textStyle),
            getGrid(size - 36)
          ],
        ));
  }

  Widget getGrid(double gridSize) {
    return Column(
      children: List.generate(board.dim, (y) => Row(
        children: List.generate(board.dim, (x) {
          BingoSquare cell = board.squares.elementAt((y * board.dim) + x);
          return Container(
            decoration: BoxDecoration(
              color: cell.checked > 0 ? checkColor : uncheckColor,
              border: Border.all(color: borderColor,width: 1),
            ),
            width:  gridSize/board.dim,
            height: gridSize/board.dim,
            child: Center(child: Text(cell.chessSqr,style: GamePage.textStyle),
            ),
          );
        }),
      )),
    );
  }

}