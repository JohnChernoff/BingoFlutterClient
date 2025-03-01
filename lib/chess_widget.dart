import 'package:bingo_client/game_client.dart';
import 'package:bingo_client/text_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart' as cb;
import 'bingo_fields.dart';
import 'chess_game.dart';

class ChessBoardWidget extends StatefulWidget {
  final double boardSize, infoHeight, borderWidth;
  final GameClient client;
  final ChessGame chessGame;

  ChessBoardWidget(this.client,this.boardSize, {super.key, this.infoHeight = 24, this.borderWidth = 0}) : chessGame = client.currentGame.chessGame;

  @override
  State<StatefulWidget> createState() => _ChessBoardWidgetState();

}

class _ChessBoardWidgetState extends State<ChessBoardWidget> {

    @override
    Widget build(BuildContext context) {
      cb.PlayerColor bottomColor = widget.chessGame.getOrientation(widget.client.userName);
      cb.PlayerColor topColor = bottomColor == cb.PlayerColor.white ? cb.PlayerColor.black : cb.PlayerColor.white;

      return Container(
          decoration: BoxDecoration(
            border: (widget.borderWidth > 0) ? Border.all(color: Colors.white,width: widget.borderWidth) : null,
          ),
          width:  widget.boardSize,
          height:  widget.boardSize,
          child: Center( child: Column(children: [
            TextBox("${widget.chessGame.getTurn() == topColor ? "***" : ""} ${ widget.chessGame.getPlayerString(topColor)}",
                borderWidth: 0, //widget.client.currentGame.lastTurn == Turn.black ? 1 : 0,
                height:  widget.infoHeight,
                Colors.black,
                txtCol: Colors.white), //widget.client.currentGame.lastTurn == Turn.black ? Colors.green : Colors.white),
            cb.ChessBoard(
              controller:  widget.chessGame.controller,
              boardOrientation: bottomColor,
              size:  widget.boardSize - ((widget.infoHeight  +  widget.borderWidth) * 2),
              boardColor: cb.BoardColor.darkBrown,
              blackPieceColor: Colors.white,
              onMove: (from,to,prom) {
                if (widget.chessGame.getTurn() != widget.chessGame.getUserColor(widget.client.userName)) {
                  widget.chessGame.controller.undoMove();
                }
                widget.client.areaCmd(GameMsg.newMove,data: {BingoFields.move : "$from$to${prom ?? ''}"});
              },
              onSquareSelect: (sqr,selected) {
                if (selected) { setState(() { widget.client.selectedSquare = sqr; }); }
              },
            ),
            TextBox("${widget.client.currentGame.chessGame.getTurn() == bottomColor ? "***" : ""} ${widget.client.currentGame.chessGame.getPlayerString(bottomColor)}",
                borderWidth: 0, //widget.client.currentGame.lastTurn == Turn.white ? 1 : 0,
                height: widget.infoHeight,
                Colors.black,
                txtCol: Colors.white), //widget.client.currentGame.lastTurn == Turn.white ? Colors.green : Colors.white),
          ])));
    }
}

