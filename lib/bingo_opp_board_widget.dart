import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart' hide Color;
import 'bingo_game.dart';
import 'game_page.dart';

class BingoOpponentBoardWidget extends StatelessWidget {
  final BingoBoard board;
  final SquareCoord? selectedSquare;
  final double size, infoHeight, borderWidth;
  final Color borderColor, checkColor, uncheckColor;
  final Function(int row, int col) onTap;

  const BingoOpponentBoardWidget(this.board, this.size, {
    required this.borderColor,
    required this.onTap,
    this.checkColor = Colors.green,
    this.uncheckColor = Colors.black,
    this.selectedSquare,
    this.infoHeight = 24,
    this.borderWidth = 0,
    super.key});

  @override
  Widget build(BuildContext context) {
    double gridSize = size - ((infoHeight + borderWidth)*2);
    return Container(
        decoration: BoxDecoration(
          border: (borderWidth > 0) ? Border.all(color: Colors.white, width: borderWidth) : null,
        ),
        width: size, height: size,
        child: Column(
          children: [
            SizedBox(height: infoHeight, child: Text(board.playerName.name, style: GamePage.txtStyle)),
            Center(child: Container(
              width: gridSize,
              height: gridSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white,width: 1)
              ),
              child:  getGrid(gridSize-2)),
            ),
            SizedBox(height: infoHeight)
          ],
        ));
  }

  Widget getGrid(double gridSize) {
    return Column(
      children: List.generate(board.dim, (y) => Row(mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(board.dim, (x) {
          BingoSquare cell = board.squares.elementAt((y * board.dim) + x);
          return InkWell(onTap: () => onTap(x,y), child: Container(
            decoration: BoxDecoration(
              color: cell.checked > 0 ? checkColor : uncheckColor,
              shape: selectedSquare?.name == cell.chessSqr.toLowerCase() ? BoxShape.circle : BoxShape.rectangle,
              border: Border.all(
                  color: borderColor,
                  //width: selectedSquare?.name == cell.chessSqr.toLowerCase() ? 8 : 1
              ),
            ),
            width:  gridSize/board.dim,
            height: gridSize/board.dim,
            child: Center(child: Text(cell.pieceType + cell.chessSqr,style: GamePage.txtStyle),
          )));
        }),
      )),
    );
  }

}
