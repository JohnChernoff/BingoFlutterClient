enum GameMsg { phase, gameWin, gameLose, top, instaBingo, rob, newFeatured, fetchFeatured, goodCheck, badCheck, victory, defeat, newMove, errNotTurn, updateChessGame }

class BingoFields {
  static String id = "id";
  static String boards = "boards";
  static String squares = "squares";
  static String square = "square";
  static String pieceType = "pieceType";
  static String checked = "checked";
  static String boardSize = "dim";
  static String ante = "ante";
  static String pot = "pot";
  static String san = "san";
  static String pan = "pan";
  static String gold = "gold";
  static String bingos = "bingos";
  static String games = "games";
  static String winner = "winner";
  static String instaPot = "instapot";
  static String instaTry = "instatry";
  static String gameId = "gameId";
  static String whiteName = "wName";
  static String blackName = "bName";
  static String whiteRating = "wRating";
  static String blackRating = "bRating";
  static String whiteTitle = "wTitle";
  static String blackTitle = "bTitle";
  static String blackTime = "bClock";
  static String whiteTime = "wClock";
  static String row = "row";
  static String col = "col";
  static String numTop = "numTop";
  static String playerName = "playerName";
  static String channel = "channel";
  static String featured = "featured";
  static String move = "move";
  static String game = "game";
  static String fen = "fen";
  static String playingGame = "playingGame";
}