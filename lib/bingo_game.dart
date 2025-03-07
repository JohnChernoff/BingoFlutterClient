import 'package:flutter/material.dart';
import 'package:zugclient/zug_client.dart';
import 'package:zugclient/zug_fields.dart';
import 'bingo_fields.dart';
import 'chess_game.dart';
import 'bingo_client.dart';

class BingoBoard {
  final int dim;
  final UniqueName playerName;
  final List<BingoSquare> squares;
  BingoBoard(this.playerName,this.squares,this.dim);

  Iterable<BingoSquare> getChecked() {
    return squares.where((sqr) => sqr.checked > 0);
  }
}

class BingoSquare {
  final int checked;
  final String pieceType;
  final String chessSqr;
  final Widget widget;

  BingoSquare(this.chessSqr, this.pieceType, this.checked)
      : widget = Text(
          switch (pieceType) {
                "P" => "I",
                "N" => "K",
                "B" => "J",
                "R" => "L",
                "Q" => "M",
                "K" => "N",
                String() => pieceType,
              } +
              chessSqr.toLowerCase(),
          style: const TextStyle(
            fontFamily: "Chess",
            color: Colors.white,
          ),
        );
}

enum GamePhase{pregame,running,finished,unknown}

class BingoGame extends Area {
  ChessGame chessGame = ChessGame();
  GamePhase phase = GamePhase.unknown;
  int? ante,pot, instapot;
  List<BingoBoard> boards = [];
  bool playing = false;

  void setPhase(dynamic p) => phase = switch(p as String) {
    "pregame" => GamePhase.pregame,
    "running" => GamePhase.running,
    "finished" => GamePhase.finished,
    String() => GamePhase.unknown
  };

  BingoGame(super.data);

  @override
  bool updateArea(Map<String,dynamic> data) {
    update(data);
    return super.updateArea(data);
  }

  //TODO: create squareChanged() to reduce spam
  void update(dynamic data,{ BingoClient? client } ) { //print("game data: $data");
    boards.clear();
    List<dynamic> boardList = data[BingoFields.boards];
    for (dynamic boardData in boardList) {
      List<BingoSquare> sqrList = [];
      List<dynamic> squareList = boardData[BingoFields.squares];
      for (dynamic square in squareList) {
        sqrList.add(BingoSquare(
          square[BingoFields.square] == "NONE" ? "?" : square[BingoFields.square],
          square[BingoFields.pieceType] == "NONE" ? "" : square[BingoFields.pieceType],
          square[BingoFields.checked],
        ));
      }
      setPhase(data[fieldPhase]);
      boards.add(BingoBoard(UniqueName.fromData(boardData[fieldUser]), sqrList,data[BingoFields.boardSize]));
      ante = data[BingoFields.ante];
      pot = data[BingoFields.pot];
      instapot = data[BingoFields.instaPot];
      playing = data[BingoFields.playingGame];
    }
  }

  BingoBoard? getBoardByUser(UniqueName? name) {
    if (boards.isEmpty) return null;
    return boards.where((board) => board.playerName.eq(name)).firstOrNull;
  }

  List<BingoBoard> getOtherBoards(UniqueName? name) {
    return boards.where((board) => !board.playerName.eq(name)).toList();
  }

}
