import 'package:bingo_client/game_page.dart';
import 'package:flutter/material.dart';

enum HelpArea {none,info,insta,tv,mainBoard,otherBoard}

class HelpWidget extends StatelessWidget {
  final HelpArea helpArea;
  final double? size;

  const HelpWidget(this.helpArea, {this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.green, //Color.fromARGB(222, 0, 0, 0),
        border: Border.all(color: Colors.white)
      ),
      child: Center(child: RichText(
        text: TextSpan(          //text: 'Hello ',
          style:GamePage.txtStyle,
          children: <TextSpan>[ //const TextSpan(text: 'Help!\n', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: getHelpTxt(),style: const TextStyle(color: Colors.black)),
          ],
        ),
      )),
    ));
  }

  String getHelpTxt() {
    return switch(helpArea) {
      HelpArea.none => "?",
      HelpArea.info => "This is the info box, displaying the board's ante, pot, and current Insta-Pot.",
      HelpArea.tv => "This is the chessboard box, displaying a game on lichess TV.",
      HelpArea.mainBoard => "This is your Bingo card.  Check five boxes in a row to win!",
      HelpArea.otherBoard => "These are your opponent's Bingo cards. You can click on checked squares to remove them if you've recently made a correct Insta-Bingo guess.",
      HelpArea.insta => """
      This is the Insta-Bingo button - if the next move played after pressing this button checks a box on your card, you gain the power to uncheck squares on your opponent's card.  
      
      Further, if the next move results in a Bingo (five in a row) for you, you win the Insta-Pot!  
      
      However, if you guess wrong you lose an ante's worth of gold and the Insta-Pot increases by the same amount. 
      """ ,
    };
  }

}