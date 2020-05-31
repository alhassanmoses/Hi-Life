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
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: colors[num - 1],
        child: Stack(
          children: <Widget>[
            Container(
              height: 100.0,
              width: 120.0,
              child: Image.asset('assets/images/$num.png'),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 30.0),
//                height: 150.0,
//                width: 150.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 0),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 5,
                      ),
                      child: Text(
                        title,
                        softWrap: true,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
