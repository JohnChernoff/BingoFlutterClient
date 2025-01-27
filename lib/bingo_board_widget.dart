import 'package:flutter/material.dart';
import 'game.dart';
import 'game_page.dart';

class BingoBoardWidget extends StatelessWidget {
  final double size;
  final BingoBoard board;
  final Color borderColor, checkColor, uncheckColor;
  const BingoBoardWidget(this.board, this.size, {
    required this.borderColor,
    this.checkColor = Colors.green,
    this.uncheckColor = Colors.black,
    super.key}
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: size, height: size,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(board.playerName.name, style: GamePage.txtStyle),
            getGrid(size - 36)
          ],
        ));
  }

  Widget getGrid(double gridSize) {
    return Column(
      children: List.generate(board.dim, (y) => Row(
        children: List.generate(board.dim, (x) {
          BingoSquare cell = board.squares.elementAt((y * board.dim) + x);
          return Container(
            decoration: BoxDecoration(
              color: cell.checked > 0 ? checkColor : uncheckColor,
              border: Border.all(color: borderColor,width: 1),
            ),
            width:  gridSize/board.dim,
            height: gridSize/board.dim,
            child: Center(child: Text(cell.chessSqr,style: GamePage.txtStyle),
            ),
          );
        }),
      )),
    );
  }

}
