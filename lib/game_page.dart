import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:zugclient/zug_fields.dart';
import 'package:zugclient_template/game_client.dart';

import 'game.dart';

class GamePage extends StatefulWidget {

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
    if (widget.client.currentGame.boards.isEmpty) return const Text("Game not running");
    BingoBoard board = widget.client.currentGame.boards.first;
    chessBoardController.loadFen(Game.fen ?? "");
    return Column(
      children: [
        Expanded(
            child: Row(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: board.dim,
                children: List.generate(
                    board.dim * board.dim,
                    (int index) {
                      BingoSquare cell = board.squares.elementAt(index);
                      return Container(
                        color: cell.checked ? Colors.green : Colors.black,
                        child: Center(child: Text(cell.chessSqr,style: const TextStyle(color: Colors.white)),
                        ),
                      );
                    }
              ),
            )),
            ChessBoard(
              controller: chessBoardController,
              size: 480,
              boardColor: BoardColor.darkBrown,
            )
          ],
        ))
      ],
    );
  }
}