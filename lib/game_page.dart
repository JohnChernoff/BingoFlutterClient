//import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zug_utils/zug_utils.dart';
import 'package:zugclient/lobby_page.dart';
import 'package:zugclient/zug_chat.dart';
import 'package:zugclient/zug_client.dart';
import 'package:zugclient/zug_fields.dart';
import 'bingo_client.dart';
import 'bingo_fields.dart';
import 'bingo_lobby.dart';
import 'bingo_main_board_widget.dart';
import 'bingo_opp_board_widget.dart';
import 'chess_game.dart';
import 'bingo_game.dart';
import 'chess_widget.dart';
import 'help_widget.dart';
import 'text_box.dart';

class GamePage extends StatefulWidget {
  static TextStyle txtStyle = const TextStyle(color: Colors.white);
  final BingoClient client;

  const GamePage(this.client, {super.key});

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Offset? mouseOff;
  HelpArea helpArea = HelpArea.none;

  @override
  void initState() {
    super.initState();
    widget.client.areaCmd(ClientMsg.setDeaf,data:{fieldDeafened:false});
    widget.client.areaCmd(ClientMsg.updateArea); //GameMsg.fetchFeatured);
    countdown();
  }

  @override
  Widget build(BuildContext context) {
    BingoBoard? userBoard =
        widget.client.currentGame.getBoardByUser(widget.client.userName);
    List<BingoBoard> otherBoards =
        widget.client.currentGame.getOtherBoards(widget.client.userName);

    return ColoredBox(color: Colors.black, child: Center(
        child: AspectRatio(
            aspectRatio: MediaQuery.of(context).orientation == Orientation.landscape ? 2 : .5,
            child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) =>  ColoredBox(
                    color: Colors.black,
                    child: Stack(
                      children: [
                        constraints.maxWidth > constraints.maxHeight
                            ? getLandscapeLayout(
                                userBoard, otherBoards, constraints)
                            : getPortraitLayout(
                                userBoard, otherBoards, constraints),
                        if (helpArea != HelpArea.none)
                          Positioned(
                              left: mouseOff?.dx,
                              width: constraints.maxWidth / 4,
                              top: mouseOff?.dy,
                              height: constraints.maxHeight / 4,
                              child: HelpWidget(helpArea)),
                      ],
                    ))))));
  }

  Future<void> countdown() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 1));
      ChessGame game = widget.client.currentGame.chessGame;
      if (mounted) {
        int newTime = (game.playerClock[game.getTurn()] ?? 0) - 1;
        if (newTime >= 0) {
          setState(() {
            widget.client.currentGame.chessGame.playerClock
                .update(game.getTurn(), (i) => newTime);
          });
        }
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

  Widget getInfoWidget(double width) {
    if (widget.client.currentGame.phase != GamePhase.unknown) {
      return SizedBox(width: width, child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: TextBox("Ante: ${widget.client.currentGame.ante} ",Colors.redAccent)),
          Expanded(child: TextBox("Pot: ${widget.client.currentGame.pot} ",Colors.greenAccent)),
          Expanded(child: TextBox("Insta-Pot: ${widget.client.currentGame.instapot} ",Colors.blueAccent)),
          Expanded(child: InkWell(onTap:  () => widget.client.areaCmd(GameMsg.resign), child: const TextBox("Resign",Colors.red))),
          Expanded(child: InkWell(onTap:  () => widget.client.areaCmd(GameMsg.draw), child: const TextBox("Draw",Colors.white))),
        ]
      ));
    }
    return const SizedBox.shrink();
  }




  Widget getMainArea(BingoBoard? userBoard,double boardSize,Color borderColor, Axis axis) {
    Widget bbw = userBoard != null ? BingoMainBoardWidget(
        widget.client,widget.client.currentGame,userBoard,boardSize
    ) : const SizedBox.shrink();
    Widget tv = widget.client.currentGame != widget.client.noArea
        ? ChessBoardWidget(widget.client,boardSize)
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

  Widget getOtherBingoBoards(List<BingoBoard> otherBoards, double size, Color borderColor, Axis axis) {
    return SizedBox(
        width: axis == Axis.vertical ? size : null,
        height: axis == Axis.horizontal ? size : null,
        child: SingleChildScrollView(
            scrollDirection: axis,
            child: Flex(
              direction: axis,
              children: List.generate(
                otherBoards.length,
                    (index) => BingoOpponentBoardWidget(
                  otherBoards.elementAt(index), size * .8,
                  borderColor: borderColor,
                  selectedSquare: widget.client.selectedSquare,
                  onTap: (x,y) => handleTap(x, y, otherBoards.elementAt(index).playerName),
                ),
              ),
            )));
  }

  Widget getLandscapeLayout(BingoBoard? userBoard,List<BingoBoard> otherBoards,BoxConstraints constraints) {
    bool isRunning = widget.client.currentGame.phase == GamePhase.running;
    Color borderColor = isRunning ? Colors.white : Colors.brown; //double headerHeight = min(48,constraints.maxHeight * .2);
    double boardSize = constraints.maxHeight * .8;
    double chessboardSize = constraints.maxHeight/2;
    double upperHeight = chessboardSize;
    double bottomHeight = constraints.maxHeight - upperHeight;

    Widget bbw = userBoard != null ? BingoMainBoardWidget(
        widget.client,widget.client.currentGame,userBoard,boardSize
    ) : const SizedBox.shrink();

    Widget tv = widget.client.currentGame != widget.client.noArea //TODO: handle this better
        ? ChessBoardWidget(widget.client,chessboardSize)
        : const SizedBox.shrink();

    Widget userBoardArea =  widget.client.helpMode ? getHelpWrapper(bbw, HelpArea.mainBoard) : bbw;

    Widget tvArea = widget.client.helpMode ? getHelpWrapper(tv, HelpArea.tv) : tv;

    Widget infoArea = widget.client.helpMode ? getHelpWrapper(getInfoWidget(chessboardSize), HelpArea.info) : getInfoWidget(chessboardSize);

    Widget lobbyArea = BingoLobby(widget.client,
        style: LobbyStyle.tersePort,
        width: 320,
        buttonsBkgCol: Colors.black,
        zugChat: ZugChat(widget.client, width: 320,
          defScope: widget.client.currentArea == widget.client.noArea ? MessageScope.server : MessageScope.area));

    Widget otherBoardsArea = widget.client.helpMode
        ? getHelpWrapper(getOtherBingoBoards(otherBoards, bottomHeight, borderColor, Axis.horizontal),
        HelpArea.otherBoard)
        : getOtherBingoBoards(otherBoards, bottomHeight, borderColor, Axis.horizontal);

    Image bkgImg =  Image(image: ZugUtils.getAssetImage("images/bingo_bkg_land.png"), fit: BoxFit.fill);

    return (widget.client.currentArea == widget.client.noArea)
        ? Row(children: [Expanded(child: bkgImg), lobbyArea])
        : Row(children: [
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
           Expanded(child: Column(children: [
              const Expanded(child: SizedBox()), //ColoredBox(color: Colors.green, child: SizedBox(width: chessboardSize))),
              Expanded(flex: 2, child: userBoard != null ? infoArea : const SizedBox()),
              const Expanded(child: SizedBox()), //ColoredBox(color: Colors.green, child: SizedBox(width: chessboardSize))),
            ])),
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
        getInfoWidget(boardSize),
        const SizedBox(height: 16),
        getMainArea(userBoard, boardSize, borderColor, Axis.vertical),
        const SizedBox(height: 16),
        getOtherBingoBoards(otherBoards, constraints.maxWidth, borderColor, Axis.vertical),
        const SizedBox(height: 16),
        SizedBox(
          height: constraints.maxHeight,
          child: BingoLobby(widget.client,
              style: LobbyStyle.tersePort,
              width: constraints.maxWidth,
              buttonsBkgCol: Colors.black,
              zugChat: ZugChat(widget.client, width: constraints.maxWidth, defScope: MessageScope.server)),
        )
      ],
    ));
  }
}

