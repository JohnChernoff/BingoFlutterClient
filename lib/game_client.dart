import 'package:audioplayers/audioplayers.dart';
import 'package:zugclient/dialogs.dart';
import 'package:zugclient/zug_app.dart';
import 'dialogs.dart';
import 'package:zugclient/zug_client.dart';
import 'package:zugclient/zug_fields.dart';
import 'game.dart';

enum GameMsg { phase, gameWin, gameLose, top, instaBingo, rob, newFeatured, fetchFeatured, goodCheck, badCheck, victory, defeat }

class TvGame {
  final String initFen;
  final String wName, bName, wTitle, bTitle;
  final int wRating, bRating;
  int wClock, bClock;

  TvGame(this.initFen,this.bName, this.bTitle, this.bRating, this.bClock, this.wName, this.wTitle, this.wRating, this.wClock);

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
  AssetSource coolClip = AssetSource("audio/clips/cool.mp3");
  AssetSource defeatClip = AssetSource("audio/clips/defeat.mp3");
  AssetSource victoryClip = AssetSource("audio/clips/victory.mp3");
  AssetSource dingClip = AssetSource("audio/clips/ding.mp3");
  AssetSource doinkClip = AssetSource("audio/clips/doink.mp3");

  GameClient(super.domain, super.port, super.remoteEndpoint, super.prefs, {super.localServer}) { //showServMess = true;
    clientName = "BingoClient";
    addFunctions({
      ServMsg.updateServ : handleUpdateServ,
      GameMsg.top : handleTop,
      GameMsg.phase : handlePhase,
      GameMsg.newFeatured : handleFeatured,
      GameMsg.goodCheck : handleGoodCheck,
      GameMsg.badCheck : handleBadCheck,
      GameMsg.victory : handleVictory,
      GameMsg.defeat : handleDefeat,
    });
    checkRedirect("lichess.org");
  }

  @override
  void connected() {
    super.connected();
    IntroDialog("Bingo Chess",zugAppNavigatorKey.currentContext!).raise().then((play) {
      if (play ?? false) {
        editOption(AudioOpt.music, true);
        playAudio(AssetSource("audio/tracks/bingo_intro.mp3")); //bingo_intro.mp3");
      }
    });
  }

  @override
  Future<bool> loggedIn(data) async {
    bool logOK = await super.loggedIn(data);
    if (logOK) startShuffle(initialTrack: 1);
    return logOK;
  }

  void handleUpdateServ(data) {
    ZugClient.log.info("Serv: $data");
  }

  void setHelpMode(bool b) {
    helpMode = b;
    notifyListeners();
  }

  @override
  bool handleUpdateOptions(data, {Area? area}) {
    bool b = super.handleUpdateOptions(data);
    return b;
  }

  @override
  bool handleUpdateArea(data) {
    tvGame?.bClock = data["bClock"];
    tvGame?.wClock = data["wClock"];
    return super.handleUpdateArea(data); //getOrCreateArea(data).updateArea(data);
  }

  void handlePhase(data) { //print("New Phase: $data");
    Area area = getOrCreateArea(data);
    if (area is Game) {
      area.setPhase(data["phase"]);
      if (data["phase"] == "running") playAudio(AssetSource("audio/tracks/game_start.mp3"));
    }
  }

  void handleTop(data) {
    playAudio(AssetSource("audio/tracks/bingo_high_score.mp3"));
    TopDialog(zugAppNavigatorKey.currentContext!,data["users"] as List<dynamic>).raise().then((onValue) {
      startShuffle();
    });
  }

  void handleFeatured(data) { //print("Feat: $data");
    try {
      tvGame = TvGame(data["fen"],data["bName"],data["bTitle"], data["bRating"], data["bClock"], data["wName"], data["wTitle"], data["wRating"], data["wClock"]);
      Game.fen = data["fen"];
    }
    catch (e) {
      ZugClient.log.info("Feature Error: $data, $e");
    }
  }

  void handleGoodCheck(data) { //print("Playing Good Check");
    if (currentArea == getOrCreateArea(data)) {
      playAudio(dingClip,clip: true, pauseCurrentTrack: false);
    }
  }

  void handleBadCheck(data) { //print("Playing Bad Check");
    if (currentArea == getOrCreateArea(data)) {
      playAudio(doinkClip, clip: true, pauseCurrentTrack: false);
    }
  }

  void handleVictory(data) {
    if (currentArea == getOrCreateArea(data)) {
      playAudio(coolClip,clip: true).then((onValue) { //print("Next...");
        playAudio(victoryClip, clip: true).then((onData) { //print("finished clips");
        });
      });
    }
  }

  void handleDefeat(data) {
    if (currentArea == getOrCreateArea(data)) {
      playAudio(defeatClip,clip: true,pauseCurrentTrack: false);
    }
  }

  @override
  Area createArea(data) {
    return Game(data);
  }

}