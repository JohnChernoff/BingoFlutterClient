import 'dart:math';
import 'package:bingo_client/help_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart' hide Color;
import 'package:zug_utils/zug_utils.dart';
import 'package:zugclient/lobby_page.dart';
import 'package:zugclient/zug_chat.dart';
import 'package:zugclient/zug_client.dart';
import 'package:zugclient/zug_fields.dart';
import 'bingo_board_widget.dart';
import 'bingo_board_widget2.dart';
import 'game.dart';
import 'game_client.dart';
import 'main.dart';

class GamePage extends StatefulWidget {
  static TextStyle txtStyle = const TextStyle(color: Colors.white);
  final GameClient client;

  const GamePage(this.client, {super.key});

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Offset? mouseOff;
  HelpArea helpArea = HelpArea.none;
  SquareCoord? selectedSquare;
  ChessBoardController chessBoardController = ChessBoardController();

  @override
  void initState() {
    super.initState();
    widget.client.areaCmd(ClientMsg.setDeaf,data:{fieldDeafened:false});
    widget.client.areaCmd(GameMsg.fetchFeatured);
    countdown();
  }

  @override
  Widget build(BuildContext context) {
    BingoBoard? userBoard = widget.client.currentGame.getBoardByUser(widget.client.userName);
    List<BingoBoard> otherBoards = widget.client.currentGame.getOtherBoards(widget.client.userName);
    chessBoardController.loadFen(Game.fen ?? widget.client.tvGame?.initFen ?? "8/8/8/8/8/8/8/8 w - - 0 1");

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) =>
        ColoredBox(color: Colors.black, child: Stack(
          children: [
            constraints.maxWidth > constraints.maxHeight
                ? getLandscapeLayout(userBoard, otherBoards, constraints)
                : getPortraitLayout(userBoard, otherBoards, constraints),
            if (helpArea != HelpArea.none)
              Positioned(
                  left: mouseOff?.dx, width: constraints.maxWidth/4,
                  top: mouseOff?.dy, height: constraints.maxHeight/4, //+ 127
                  child: HelpWidget(helpArea)
              ),
          ],
        )
    ));
  }

  Future<void> countdown() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          if (widget.client.currentGame.lastTurn == GameSide.black) {
            widget.client.tvGame?.bClock--;
          } else {
            widget.client.tvGame?.wClock--;
          }
        });
      }
    }
  }

  void handleTap(int row, int col, UniqueName oppName) {
    widget.client.areaCmd(GameMsg.rob,data: {
      "row": row, "col": col, fieldUniqueName : oppName.toJSON()
    });
  }

  Widget getHelpWrapper(Widget w, HelpArea area) {
    if (kIsWeb) {
      return MouseRegion(
        onEnter: (e) {
          mouseOff = e.position; //print(mouseOff);
          setState(() => helpArea = area);
        },
        onExit: (e) => setState(() => helpArea = HelpArea.none),
        child: w);
    }
    else {
      return InkWell(
      onTapDown: (details) {
          mouseOff = details.globalPosition;
          setState(() => helpArea = area);
        },
      onTapUp: (details) => setState(() => helpArea = HelpArea.none),
      child: w);
    }
  }

  Widget getTextBox(String txt, Color color, {double? width, double? height, txtCol = Colors.black, borderCol = Colors.white, double borderWidth = 1, margin = 0.0}) {
    return Container(
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(
        color: color,
        border: (borderWidth > 0) ? Border.all(color: borderCol, width: borderWidth) : null
      ),
      width: width, height: height,
      child: Center(child: Text(txt,style: TextStyle(color: txtCol))),
    );
  }

  Widget getTvBoard(double boardSize, {double infoHeight = 24, double borderWidth = 0}) {
    return Container(
        decoration: BoxDecoration(
          border: (borderWidth > 0) ? Border.all(color: Colors.white,width: borderWidth) : null,
        ),
        width: boardSize,
        height: boardSize,
        child: Center( child: Column(children: [
      getTextBox("${widget.client.currentGame.lastTurn == GameSide.black ? "***" : ""} ${widget.client.tvGame?.getPlayerString(GameSide.black)}",
          borderWidth: 0, //widget.client.currentGame.lastTurn == Turn.black ? 1 : 0,
          height: infoHeight,
          Colors.black,
          txtCol: Colors.white), //widget.client.currentGame.lastTurn == Turn.black ? Colors.green : Colors.white),
      ChessBoard(
        controller: chessBoardController,
        size: boardSize - ((infoHeight  + borderWidth) * 2),
        boardColor: BoardColor.darkBrown,
        blackPieceColor: Colors.white,
        onSquareSelect: (sqr,selected) {
          if (selected) { setState(() { selectedSquare = sqr; }); }
        },
      ),
      getTextBox("${widget.client.currentGame.lastTurn == GameSide.white ? "***" : ""} ${widget.client.tvGame?.getPlayerString(GameSide.white)}",
          borderWidth: 0, //widget.client.currentGame.lastTurn == Turn.white ? 1 : 0,
          height: infoHeight,
          Colors.black,
          txtCol: Colors.white), //widget.client.currentGame.lastTurn == Turn.white ? Colors.green : Colors.white),
    ])));
  }

  Widget getInfoWidget(double height) {
    if (widget.client.currentGame.phase != GamePhase.unknown) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          getTextBox(height: height,"Ante: ${widget.client.currentGame.ante} ",Colors.redAccent),
          getTextBox(height: height,"Pot: ${widget.client.currentGame.pot} ",Colors.greenAccent),
          getTextBox(height: height,"Insta-Pot: ${widget.client.currentGame.instapot} ",Colors.blueAccent),
        ]
      );
    }
    return const SizedBox.shrink();
  }

  Widget getMainBoardsWidget(BingoBoard? userBoard,double boardSize,Color borderColor, Axis axis) {
    Widget bbw = userBoard != null ? BingoBoardWidget2(
        widget.client,widget.client.currentGame,userBoard,selectedSquare,boardSize
    ) : const SizedBox.shrink();
    Widget tv = widget.client.currentGame != widget.client.noArea
        ? getTvBoard(boardSize)
        : const SizedBox.shrink();
    return Flex(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      direction: axis,
      children: [
        widget.client.helpMode ? getHelpWrapper(bbw, HelpArea.mainBoard) : bbw,
        widget.client.helpMode ? getHelpWrapper(tv, HelpArea.tv) : tv,
      ],
    );
  }

  Widget getOtherBoardsWidget(List<BingoBoard> otherBoards, double size, Color borderColor, Axis axis) {
    return SizedBox(
        width: axis == Axis.vertical ? size : null,
        height: axis == Axis.horizontal ? size : null,
        child: SingleChildScrollView(
            scrollDirection: axis,
            child: Flex(
              direction: axis,
              children: List.generate(
                otherBoards.length,
                    (index) => BingoBoardWidget(
                  otherBoards.elementAt(index), size * .8,
                  borderColor: borderColor,
                  onTap: (x,y) => handleTap(x, y, otherBoards.elementAt(index).playerName),
                ),
              ),
            )));
  }

  Widget getLandscapeLayout(BingoBoard? userBoard,List<BingoBoard> otherBoards,BoxConstraints constraints) {
    bool isRunning = widget.client.currentGame.phase == GamePhase.running;
    Color borderColor = isRunning ? Colors.white : Colors.brown;
    double headerHeight = min(48,constraints.maxHeight * .1);
    double boardSize = constraints.maxHeight * .8;
    double tvSize = constraints.maxHeight/2;
    double upperHeight = tvSize;
    double bottomHeight = constraints.maxHeight - upperHeight;

    Widget bbw = userBoard != null ? BingoBoardWidget2(
        widget.client,widget.client.currentGame,userBoard,selectedSquare,boardSize
    ) : const SizedBox.shrink();

    Widget tv = widget.client.currentGame != widget.client.noArea
        ? getTvBoard(tvSize)
        : const SizedBox.shrink();

    Widget userBoardArea =  widget.client.helpMode ? getHelpWrapper(bbw, HelpArea.mainBoard) : bbw;

    Widget tvArea = widget.client.helpMode ? getHelpWrapper(tv, HelpArea.tv) : tv;

    Widget infoArea = widget.client.helpMode ? getHelpWrapper(getInfoWidget(headerHeight), HelpArea.info) : getInfoWidget(headerHeight);

    Widget lobbyArea = BingoLobby(widget.client,
        style: LobbyStyle.tersePort,
        width: 320,
        buttonsBkgCol: Colors.black,
        chatArea: ZugChat(widget.client, width: 320, defScope: MessageScope.server));

    Widget otherBoardsArea = widget.client.helpMode
        ? getHelpWrapper(getOtherBoardsWidget(otherBoards, bottomHeight, borderColor, Axis.horizontal),
        HelpArea.otherBoard)
        : getOtherBoardsWidget(otherBoards, bottomHeight, borderColor, Axis.horizontal);

    Image bkgImg =  Image(image: ZugUtils.getAssetImage("images/bingo_bkg_land.png"), fit: BoxFit.fill);

    return (userBoard == null)
        ? Row(children: [Expanded(child: bkgImg), lobbyArea])
        : Row(children: [
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            infoArea,
            userBoardArea
          ]),
          Expanded(child: Column(children: [
            tvArea,
            otherBoardsArea
          ])),
          lobbyArea
        ]);
  }

  Widget getPortraitLayout(BingoBoard? userBoard,List<BingoBoard> otherBoards,BoxConstraints constraints) {
    bool isRunning = widget.client.currentGame.phase == GamePhase.running;
    Color borderColor = isRunning ? Colors.white : Colors.brown;
    double boardSize = constraints.maxWidth * .8;

    return SingleChildScrollView(child: Column(
      children: [
        const SizedBox(height: 16),
        getInfoWidget(128),
        const SizedBox(height: 16),
        getMainBoardsWidget(userBoard, boardSize, borderColor, Axis.vertical),
        const SizedBox(height: 16),
        getOtherBoardsWidget(otherBoards, constraints.maxWidth, borderColor, Axis.vertical),
        const SizedBox(height: 16),
        SizedBox(
          height: constraints.maxHeight,
          child: BingoLobby(widget.client,
              style: LobbyStyle.tersePort,
              width: constraints.maxWidth,
              buttonsBkgCol: Colors.black,
              chatArea: ZugChat(widget.client, width: constraints.maxWidth, defScope: MessageScope.server)),
        )
      ],
    ));
  }
}

