import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:zugclient/zug_client.dart';
import 'bingo_fields.dart';

const String startFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

class ChessGame {
  ChessBoardController controller = ChessBoardController();
  final Map<PlayerColor,String?> playerName = {}, playerTitle = {};
  final Map<PlayerColor,int?> playerRating = {}, playerClock = {};
  PlayerColor? orientation;

  ChessGame({String initialFen = startFEN,String? bName, String? bTitle, int? bRating, int? bClock, String? wName, String? wTitle, int? wRating, int? wClock}) {
    controller.loadFen(initialFen);
    playerName[PlayerColor.black] = bName;
    playerTitle[PlayerColor.black] = bTitle;
    playerRating[PlayerColor.black] = bRating;
    playerClock[PlayerColor.black] = bClock;
    playerName[PlayerColor.white] = wName;
    playerTitle[PlayerColor.white] = wTitle;
    playerRating[PlayerColor.white] = wRating;
    playerClock[PlayerColor.white] = wClock;
  }

  factory ChessGame.fromData(Map<String,dynamic> data) {
    return ChessGame(initialFen: data[BingoFields.fen],
        bName: data[BingoFields.blackName],
        bTitle: data[BingoFields.blackTitle],
        bRating: data[BingoFields.blackRating],
        bClock: data[BingoFields.blackTime],
        wName: data[BingoFields.whiteName],
        wTitle: data[BingoFields.whiteTitle],
        wRating: data[BingoFields.whiteRating],
        wClock: data[BingoFields.whiteTime]);
  }

  String formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes;
    final seconds = totalSeconds % 60;

    final minutesString = '$minutes'.padLeft(2, '0');
    final secondsString = '$seconds'.padLeft(2, '0');
    return '$minutesString:$secondsString';
  }

  void update(dynamic data) {
    controller.loadFen(data[BingoFields.fen] ?? startFEN);
    playerClock[PlayerColor.black] = data["bClock"];
    playerClock[PlayerColor.white] = data["wClock"];
  }

  PlayerColor getTurn() {
    List<String> fenFields = controller.getFen().split(" ");
    if (fenFields.length > 1) {
      return fenFields.elementAt(1) == "w" ? PlayerColor.white : PlayerColor.black;
    } else {
      return PlayerColor.white;
    }
  }

  String getPlayerString(PlayerColor turn) {
    String rat = (playerRating[turn] ?? 0) > 0 ? "(${playerRating[turn]})" : "";
    return "${playerTitle[turn]} ${playerName[turn]} ($rat) : ${formatDuration(playerClock[turn] ?? 0)}";
  }

  PlayerColor getOrientation(UniqueName? uName) {
    return orientation ?? getUserColor(uName) ?? PlayerColor.white;
  }

  PlayerColor? getUserColor(UniqueName? uName) {
    if (playerName[PlayerColor.white] == uName?.name) return PlayerColor.white;
    if (playerName[PlayerColor.black] == uName?.name) return PlayerColor.black;
    return null;
  }
}