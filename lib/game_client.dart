import 'package:zugclient/zug_client.dart';
import 'game.dart';

enum GameMsg { phase, gameWin, gameLose, top, scoreRank, instaBingo, rob }

class GameClient extends ZugClient {

  Game get currentGame => currentArea as Game;

  GameClient(super.domain, super.port, super.remoteEndpoint, super.prefs, {super.localServer}) { showServMess = true;
    clientName = "BingoClient";
    addFunctions({
      GameMsg.gameWin: handleVictory,
      GameMsg.gameLose: handleDefeat,
      GameMsg.top: handleTop,
      GameMsg.scoreRank: handleScoreRank,
      GameMsg.phase : handlePhase,
    });
    if (prefs?.getBool(AudioType.sound.name) == null) {
      prefs?.setBool(AudioType.sound.name, true);
    }
    checkRedirect("lichess.org");
  }

  void handlePhase(data) { //print("New Phase: $data");
    Area area = getOrCreateArea(data);
    if (area is Game) area.phase = data["phase"];
  }

  Future<void> handleVictory(data) async {
    playClip("victory");

  }

  Future<void> handleDefeat(data) async {
    playClip("defeat");
  }

  void handleTop(data) {
    //TopDialog(zugAppNavigatorKey.currentContext!,data["scores"] as List<dynamic>).raise();
  }

  void handleScoreRank(data) {
    //InfoDialog(zugAppNavigatorKey.currentContext!, "Your score ranks ${getPlace(data["rank"])} (out of ${data["scores"]})").raise();
  }

  @override
  bool handleUpdateArea(data) {
    super.handleUpdateArea(data);
    return getOrCreateArea(data).updateArea(data);
  }

  @override
  Area createArea(data) {
    return Game(data);
  }

}