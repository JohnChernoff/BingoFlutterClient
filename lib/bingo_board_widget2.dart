import 'package:flutter/material.dart';
import 'game.dart';

class BingoBoardWidget2 extends StatelessWidget {
  final double size;
  final BingoBoard board;
  final Game game;
  const BingoBoardWidget2(this.game,this.board,this.size,{super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> stack = [ game.phase == "finished" ? const Image(image: AssetImage("images/bingo_board_fin.png")) : const Image(image: AssetImage("images/bingo_board.png"))];

    double xf =  size / 901;
    double yf = size / 890;
    Offset offset = Offset(size * (136/901), size * (182/890));
    double sqrWidth = 99 * xf;
    double sqrHeight = 106 * yf;
    double barWidth = 7 * yf;
    double barHeight = 7 * yf;
    const Color bingCol = Color.fromRGBO(224, 196, 162, 1);

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
          child: sqr.checked > 0 ? Center(child: Container(
              width: sqrWidth * .5,
              height: sqrHeight * .5,
              decoration: const BoxDecoration(
                  color: bingCol, //Color.fromRGBO(255, 255, 0, .75), //
                  shape: BoxShape.circle,

              ), child: boxTxt)) : boxTxt
        ); // : const SizedBox.shrink();
    }
    ));
    return SizedBox(width: size, height: size, child: Stack(
      children: stack,
    ));
  }

}