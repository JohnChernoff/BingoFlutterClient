import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'bingo_fields.dart';

const String startFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

enum GameSide{white,black}

class ChessGame {
  ChessBoardController controller = ChessBoardController();
  final Map<GameSide,String?> playerName = {}, playerTitle = {};
  final Map<GameSide,int?> playerRating = {}, playerClock = {};

  ChessGame({String initialFen = startFEN,String? bName, String? bTitle, int? bRating, int? bClock, String? wName, String? wTitle, int? wRating, int? wClock}) {
    controller.loadFen(initialFen);
    playerName[GameSide.black] = bName;
    playerTitle[GameSide.black] = bTitle;
    playerRating[GameSide.black] = bRating;
    playerClock[GameSide.black] = bClock;
    playerName[GameSide.white] = wName;
    playerTitle[GameSide.white] = wTitle;
    playerRating[GameSide.white] = wRating;
    playerClock[GameSide.white] = wClock;
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
    playerClock[GameSide.black] = data["bClock"];
    playerClock[GameSide.white] = data["wClock"];
  }

  GameSide getTurn() {
    List<String> fenFields = controller.getFen().split(" ");
    if (fenFields.length > 1) {
      return fenFields.elementAt(1) == "w" ? GameSide.white : GameSide.black;
    } else {
      return GameSide.white;
    }
  }

  String getPlayerString(GameSide turn) {
    String rat = (playerRating[turn] ?? 0) > 0 ? "(${playerRating[turn]})" : "";
    return "${playerTitle[turn]} ${playerName[turn]} ($rat) : ${formatDuration(playerClock[turn] ?? 0)}";
  }
}