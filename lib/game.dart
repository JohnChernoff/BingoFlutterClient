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

class Game extends Area {
  static String? fen;
  String? phase;
  int? ante,pot, instapot;
  List<BingoBoard> boards = [];
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
      fen = data["fen"];
      phase = data["phase"];
      ante = data["ante"];
      pot = data["pot"];
      instapot = data["instapot"];
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

/*
data: {title: AnselAdamsraccoon, phase: initializing, phase_time_remaining: -1737494614461, exists: true, creator: {source: none, name: AnselAdamsraccoon}, fen: r2q1rk1/bp3ppp/2p1bnn1/p2pp3/4P3/2PP1NN1/PPB2PPP/R1BQR1K1, dim: 5, boards: [{away: false, banned: false, user: {logged_in: true, uname: {source: none, name: AnselAdamsraccoon}}, squares: [{checked: false, square: G3}, {checked: false, square: D5}, {checked: false, square: E5}, {checked: false, square: A4}, {checked: false, square: F7}, {checked: false, square: D8}, {checked: false, square: G6}, {checked: false, square: F6}, {checked: false, square: B1}, {checked: false, square: NONE}, {checked: false, square: F8}, {checked: false, square: E4}, {checked: false, square: F3}, {checked: false, square: E6}, {checked: false, square: B7}, {checked: false, square: G5}, {checked: false, square: H4}, {checked: false, square: B3}, {checked: false, square: C2}, {checked: false, square: F5}, {checked: false, square: G1}, {checked: false, square: B4}, {checked: false, square: C3}, {checked: false, square: E8}, {checked: false, square: D3}]}]}
INFO: 2025-01-21 13:23:35.374: Sending: ClientMsg.setDeaf, {deafened: false, title: AnselAdamsraccoon}
 */