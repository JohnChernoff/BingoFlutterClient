import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:zug_utils/zug_dialogs.dart';
import 'package:zugclient/dialogs.dart';
import 'package:zugclient/zug_app.dart';
import 'bingo_fields.dart';
import 'chess_game.dart';
import 'dialogs.dart';
import 'package:zugclient/zug_client.dart';
import 'package:zugclient/zug_fields.dart';
import 'bingo_game.dart';

class BingoClient extends ZugClient {

  bool helpMode = false;
  BingoGame get currentGame => currentArea as BingoGame;
  SquareCoord? _selectedSquare;
  SquareCoord? get selectedSquare => _selectedSquare;
  set selectedSquare(SquareCoord? coord) {
    _selectedSquare = coord;
    notifyListeners();
  }
  AssetSource coolClip = AssetSource("audio/clips/cool.mp3");
  AssetSource defeatClip = AssetSource("audio/clips/defeat.mp3");
  AssetSource victoryClip = AssetSource("audio/clips/victory.mp3");
  AssetSource dingClip = AssetSource("audio/clips/ding.mp3");
  AssetSource doinkClip = AssetSource("audio/clips/doink.mp3");
  AssetSource moveClip = AssetSource("audio/clips/move.mp3");

  BingoClient(super.domain, super.port, super.remoteEndpoint, super.prefs, {super.localServer}) { //showServMess = true;
    clientName = "BingoClient";
    addFunctions({
      GameMsg.top : handleTop,
      GameMsg.phase : handlePhase,
      GameMsg.newFeatured : handleFeatured,
      GameMsg.goodCheck : handleGoodCheck,
      GameMsg.badCheck : handleBadCheck,
      GameMsg.victory : handleVictory,
      GameMsg.defeat : handleDefeat,
      GameMsg.newMove : handleNewMove,
      GameMsg.errNotTurn : handleErrTurn,
      GameMsg.updateChessGame : handleUpdateChessGame,
    });
    checkRedirect("lichess.org");
  }

  @override
  void connected() {
    super.connected();
    IntroDialog("Bingo Chess",zugAppNavigatorKey.currentContext!).raise().then((play) {
      if (play ?? false) {
        editOption(AudioOpt.music, true);
        playAudio(AssetSource("audio/tracks/bingo_intro.mp3"));
      }
    });
  }

  @override
  Future<bool> loggedIn(data) async {
    bool logOK = await super.loggedIn(data);
    if (logOK) startShuffle(initialTrack: 1);
    return logOK;
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
  bool handleUpdateArea(data) { //print(data);
    handleUpdateChessGame(data);
    super.handleUpdateArea(data);
    return true;
  }

  @override
  void handleResponseRequest(data) {
    super.handleResponseRequest(data);
    if (data[fieldResponseType] == BingoFields.confStart) {
      ZugDialogs.confirm("Start Game?",canceller: dialogTracker[BingoFields.confStart])
          .then((confirm) => areaCmd(ClientMsg.response, data: {fieldResponse : confirm, fieldResponseType : BingoFields.confStart}));
    }
    else if (data[fieldResponseType] == BingoFields.confRematch) {
      ZugDialogs.confirm("Rematch?",canceller: dialogTracker[BingoFields.confRematch])
          .then((confirm) => areaCmd(ClientMsg.response, data: {fieldResponse : confirm, fieldResponseType : BingoFields.confRematch}));
    }
    else if (data[fieldResponseType] == BingoFields.confDraw) {
      ZugDialogs.confirm("Draw?",canceller: dialogTracker[BingoFields.confDraw])
          .then((confirm) => areaCmd(ClientMsg.response, data: {fieldResponse : confirm, fieldResponseType : BingoFields.confDraw}));
    }
  }

  void handleUpdateChessGame(data) {
    if (currentArea == getOrCreateArea(data) && data[fieldPhase] != "finished") {
      currentGame.chessGame.update(data[BingoFields.game]);
    }

  }

  void handlePhase(data) { //print("New Phase: $data");
    Area area = getOrCreateArea(data);
    if (area is BingoGame) {
      area.setPhase(data[fieldPhase]); //TODO: enum phases
      if (data[fieldPhase] == "running") playAudio(AssetSource("audio/tracks/game_start.mp3"));
    }
  }

  void handleTop(data) {
    playAudio(AssetSource("audio/tracks/bingo_high_score.mp3"));
    TopDialog(zugAppNavigatorKey.currentContext!,data["users"] as List<dynamic>).raise().then((onValue) {
      startShuffle();
    });
  }

  void handleFeatured(data) {
    if (currentArea == getOrCreateArea(data)) { //print("Feat: $data");
      try { currentGame.chessGame = ChessGame.fromData(data); }
      catch (e) { ZugClient.log.info("Feature Error: $data, $e"); }
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

  void handleErrTurn(data) {
    ZugDialogs.popup("Not your turn!");
  }

  void handleNewMove(data) {
    if (currentArea == getOrCreateArea(data)) {
      UniqueName pName = UniqueName.fromData(data[fieldOccupant]);
      addAreaMsg("New move: ${data[BingoFields.pan]} ($pName)", currentArea.id);
      if (!pName.eq(userName)) playAudio(moveClip,clip: true, pauseCurrentTrack: false);
    }
  }

  @override
  Area createArea(data) {
    return BingoGame(data);
  }

}