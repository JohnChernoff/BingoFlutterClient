import 'package:zugclient/zug_client.dart';
import 'package:zugclient/zug_fields.dart';
import 'game_client.dart';

class BingoBoard {
  final int dim;
  final UniqueName playerName;
  final List<BingoSquare> squares;
  BingoBoard(this.playerName,this.squares,this.dim);
}

class BingoSquare {
  final int checked;
  final String chessSqr;
  BingoSquare(this.chessSqr,this.checked);
}

enum GameSide{white,black}
class Game extends Area {

  static String? fen;
  String? phase;
  int? ante,pot, instapot;
  List<BingoBoard> boards = [];
  GameSide lastTurn = GameSide.white;
  Game(super.data);

  @override
  bool updateArea(Map<String,dynamic> data) {
    update(data);
    return super.updateArea(data);
  }

  //TODO: create squareChanged() to reduce spam
  void update(dynamic data,{ GameClient? client } ) { //print("data: $data");
    boards.clear();
    List<dynamic> boardList = data["boards"];
    for (dynamic boardData in boardList) {
      List<BingoSquare> sqrList = [];
      List<dynamic> squareList = boardData["squares"];
      for (dynamic square in squareList) {
        sqrList.add(BingoSquare(
          square["square"],
          square["checked"],
        ));
      }
      boards.add(BingoBoard(UniqueName.fromData(boardData[fieldUser]), sqrList,data["dim"]));
      phase = data["phase"];
      ante = data["ante"];
      pot = data["pot"];
      instapot = data["instapot"];
      fen = data["fen"];
      List<String> fenFields = fen!.split(" ");
      if (fenFields.length > 1) {
        lastTurn = fenFields.elementAt(1) == "w" ? GameSide.white : GameSide.black;
      }
      else {
        lastTurn = lastTurn == GameSide.white ? GameSide.black : GameSide.white;
      }
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
