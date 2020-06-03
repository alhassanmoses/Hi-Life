import 'package:flutter/material.dart';

class CategoryItemCard extends StatelessWidget {
  CategoryItemCard(this.title, this.num);
  final int num;
  final String title;
  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.orangeAccent,
    Colors.teal,
    Colors.black12,
    Colors.amber,
    Colors.lightBlueAccent,
    Colors.cyan,
  ];
  @override
  Widget build(BuildContext context) {
    if (title == 'Non-Specialist') {
      return Container();
    } else {
      return GestureDetector(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          height: 80.0,
          width: 120.0,
//            child: Image.asset('assets/images/$num.png'),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 2,
                horizontal: 7,
              ),
              child: Text(
                title,
                overflow: TextOverflow.fade,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                    fontSize: 12,
                    fontFamily: 'ChelseaMarket'),
              ),
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: colors[num - 1],
          ),
        ),
        onTap: () {},
      );
    }
  }
}
