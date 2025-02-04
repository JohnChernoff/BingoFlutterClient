import 'package:zugclient/zug_app.dart';
import 'package:zugclient/zug_client.dart';
import 'dialogs.dart';
import 'game.dart';

enum GameMsg { phase, gameWin, gameLose, top, instaBingo, rob, newFeatured, fetchFeatured }

class TvGame {
  final String wName, bName, wTitle, bTitle;
  final int wRating, bRating;
  int wClock, bClock;

  TvGame(this.bName, this.bTitle, this.bRating, this.bClock, this.wName, this.wTitle, this.wRating, this.wClock);

  String formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes;
    final seconds = totalSeconds % 60;

    final minutesString = '$minutes'.padLeft(2, '0');
    final secondsString = '$seconds'.padLeft(2, '0');
    return '$minutesString:$secondsString';
  }

  String getPlayerString(GameSide turn) {
    if (turn == GameSide.white) return "$wTitle $wName ($wRating) : ${formatDuration(wClock)}";
    return "$bTitle $bName ($bRating) : ${formatDuration(bClock)}";
  }
}

class GameClient extends ZugClient {

  TvGame? tvGame;
  bool helpMode = false;
  Game get currentGame => currentArea as Game;

  GameClient(super.domain, super.port, super.remoteEndpoint, super.prefs, {super.localServer}) { showServMess = true;
    clientName = "BingoClient";
    addFunctions({
      GameMsg.gameWin: handleVictory,
      GameMsg.gameLose: handleDefeat,
      GameMsg.top: handleTop,
      GameMsg.phase : handlePhase,
      GameMsg.newFeatured : handleFeatured,
    });
    if (prefs?.getBool(AudioType.sound.name) == null) {
      prefs?.setBool(AudioType.sound.name, true);
    }
    checkRedirect("lichess.org");
  }

  void setHelpMode(bool b) {
    helpMode = b;
    notifyListeners();
  }

  void handlePhase(data) { //print("New Phase: $data");
    Area area = getOrCreateArea(data);
    if (area is Game) area.setPhase(data["phase"]);
  }

  Future<void> handleVictory(data) async {
    playClip("victory");

  }

  Future<void> handleDefeat(data) async {
    playClip("defeat");
  }

  void handleTop(data) {
    TopDialog(zugAppNavigatorKey.currentContext!,data["users"] as List<dynamic>).raise();
  }

  void handleFeatured(data) {
      tvGame = TvGame(data["bName"],data["bTitle"], data["bRating"], data["bClock"], data["wName"], data["wTitle"], data["wRating"], data["wClock"]);
  }

  @override
  bool handleUpdateArea(data) {
    tvGame?.bClock = data["bClock"];
    tvGame?.wClock = data["wClock"];
    return super.handleUpdateArea(data); //getOrCreateArea(data).updateArea(data);
  }

  @override
  Area createArea(data) {
    return Game(data);
  }

}