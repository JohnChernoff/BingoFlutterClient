import 'package:bingo_client/game_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart' hide Color;
import 'package:zug_utils/zug_utils.dart';
import 'package:zugclient/options_page.dart';
import 'package:zugclient/zug_fields.dart';
import 'bingo_fields.dart';
import 'dialogs.dart';
import 'bingo_game.dart';

class BingoBoardWidget2 extends StatelessWidget {
  final GameClient client;
  final double size;
  final BingoBoard board;
  final BingoGame game;
  final SquareCoord? selectedSquare;
  final int bingColHex;
  final double imgWidth = 901;
  final double imgHeight = 890;
  const BingoBoardWidget2(this.client,this.game,this.board,this.selectedSquare,this.size,{super.key,this.bingColHex = 0xFFE0C4A2});

  @override
  Widget build(BuildContext context) {
    double xf =  size / imgWidth;
    double yf = size / imgHeight;
    Offset offset = Offset(size * (136/imgWidth), size * (182/imgHeight));
    double sqrWidth = 99 * xf;
    double sqrHeight = 106 * yf;
    double barWidth = 7 * yf;
    double barHeight = 7 * yf;
    double selectBoxWidth = sqrWidth * .75;
    double selectBoxHeight = sqrHeight * .75;
    double txtBoxWidth = sqrWidth * .5;
    double txtBoxHeight = sqrHeight *.5;
    Offset instaBoxOff = Offset(size * (353/imgWidth),0);
    double instaBoxWidth = 187 * xf;
    double instaBoxHeight = 72 * yf;
    Offset infoBoxOff = Offset(size * (243/imgWidth),size * (753/imgHeight));
    double infoBoxWidth = 414 * xf;
    double infoBoxHeight = 97 * yf;
    Offset optBoxOff = Offset(size * (399/imgWidth),size * (130/imgHeight));
    double optBoxWidth = 100 * xf;
    double optBoxHeight = 36 * yf;
    Color bingCol = Color(bingColHex); //Color.fromRGBO(224, 196, 162, 1);
    dynamic player = client.currentGame.getOccupant(client.userName);
    bool instaPress = game.phase == GamePhase.running && (player != null && player["instatry"] == true);

    List<Widget> stack = [
      SizedBox(width: size, height: size, child: game.phase == GamePhase.finished
          ? Image(image: ZugUtils.getAssetImage("images/bingo_board_fin.png"),fit: BoxFit.fill)
          : Image(image: ZugUtils.getAssetImage("images/bingo_board.png"),fit: BoxFit.fill)),
      Positioned(
          left: instaBoxOff.dx,
          top: instaBoxOff.dy,
          width: instaBoxWidth,
          height: instaBoxHeight,
          child: TextButton(
              style: getInstaButtStyle(instaPress),
              onPressed: switch(game.phase) {
                GamePhase.pregame => () => client.areaCmd(ClientMsg.startArea),
                GamePhase.running =>  () => client.areaCmd(GameMsg.instaBingo),
                GamePhase.finished => () => client.areaCmd(ClientMsg.partArea),
                GamePhase.unknown => null,
              },
              child: FittedBox(
                  child: Text(switch (game.phase) {
                        GamePhase.pregame => "Start",
                        GamePhase.running => "Insta-Bingo",
                        GamePhase.finished => "Leave",
                        GamePhase.unknown => "?",
                      },
                  style: TextStyle(color: instaPress ? Colors.white : Colors.black))
              )
          )
      ),
      Positioned(
          left: infoBoxOff.dx,
          top: infoBoxOff.dy,
          width: infoBoxWidth,
          height: infoBoxHeight,
          child: SingleChildScrollView(
              child: Text(
                game.messages.getLastServMsg()?.message ?? "",
                style: TextStyle(color: bingCol)
              )
          ),
        ),
        Positioned(
            left: optBoxOff.dx,
            top: optBoxOff.dy,
            width: optBoxWidth,
            height: optBoxHeight,
            child: TextButton(
                onPressed: () => client.fetchOptions(() => OptionDialog(client,context,OptionScope.area).raise()),
                child: const FittedBox(child: Text("options", style: TextStyle(fontWeight: FontWeight.bold),)), //const Icon(Icons.menu),
                //visualDensity: VisualDensity.compact,
            )
        )
    ];

    stack.addAll(List.generate(board.squares.length, (i) {
        BingoSquare sqr = board.squares.elementAt(i);
        int row = i % board.dim;
        int col = (i / board.dim).truncate();
        Widget boxTxt = Center(child: Text(sqr.chessSqr,style: TextStyle(
            color: sqr.checked > 0 ? Colors.black : bingCol, fontWeight: FontWeight.bold)));
        return Positioned(
          left: offset.dx + ((sqrWidth + barWidth) * row),
          width: sqrWidth,
          top: offset.dy + ((sqrHeight + barHeight) * col),
          height: sqrHeight,
          child: Center(child: Container(
              width: selectBoxWidth,
              height: selectBoxHeight,
              decoration: BoxDecoration(
                  color:  sqr.checked > 0 ? bingCol : null, //Color.fromRGBO(255, 255, 0, .75), //
                  shape: BoxShape.circle,
                  border: selectedSquare?.name == sqr.chessSqr.toLowerCase() ? Border.all(color: Colors.white,width: 4) : null,
              ),
              child: Center(child: SizedBox(
                  width: txtBoxWidth,
                  height: txtBoxHeight,
                  child: FittedBox(child: boxTxt)
              ))
          ))
        ); // : const SizedBox.shrink();
    }
    ));

    return SizedBox(
      width: size,
      height: size,
      child: Stack(children: stack)
    );
  }

  ButtonStyle getInstaButtStyle(bool pressed) {
    return ButtonStyle(
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((Set<WidgetState> states) => const BeveledRectangleBorder()),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) =>
      pressed ? const Color.fromRGBO(255,0,0,.5) : null),
    );
  }

}