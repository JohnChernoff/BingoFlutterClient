import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:zugclient/lobby_page.dart';
import 'package:zugclient/zug_chat.dart';
import 'package:zugclient/zug_fields.dart';
import 'package:zugclient_template/game_client.dart';
import 'game.dart';

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
    List<BingoBoard> boards = widget.client.currentGame.boards;
    //if (boards.isEmpty) return LobbyPage(widget.client, style: LobbyStyle.tersePort, width: 320);
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
    double boardSize = constraints.maxWidth / 4;
    return Column(
      children: [
        Text(widget.client.currentGame.title),
        Text(widget.client.currentGame.phase ?? ""),
        Expanded(child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            userBoard == null ?
            const SizedBox.shrink() : BingoBoardWidget(userBoard,boardSize),
            ChessBoard(
              controller: chessBoardController,
              size: boardSize,
              boardColor: BoardColor.darkBrown,
              blackPieceColor: Colors.white,
            ),
            LobbyPage(widget.client, style: LobbyStyle.tersePort, width: 320, buttonsBkgCol: Colors.black,
                chatArea: ZugChat(widget.client,width: 320)),
          ],
        )),
        SizedBox(
            height: 480,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, child: Row(
              children: List.generate(otherBoards.length,
                      (index) => BingoBoardWidget(otherBoards.elementAt(index),boardSize/2)
              ),
            )))
      ],
    );
  }

  Widget getPortraitLayout(BingoBoard? userBoard,List<BingoBoard> otherBoards,BoxConstraints constraints) {
    return const Text("Ergh");
  }
}

class BingoBoardWidget extends StatelessWidget {
  final double size;
  final BingoBoard board;
  const BingoBoardWidget(this.board,this.size,{super.key});

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
              color: cell.checked > 0 ? Colors.green : Colors.black,
              border: Border.all(color: Colors.brown,width: 2),
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