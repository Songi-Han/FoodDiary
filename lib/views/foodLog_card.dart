import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fooddiary/colors.dart';

class FoodLogCard extends StatelessWidget {
  final int id;
  final Image image;
  final String content;
  final String foods;
  final int calorie;

  const FoodLogCard({
    required this.id,
    required this.image,
    required this.content,
    required this.foods,
    required this.calorie,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 120,
          height: 120,
          margin: EdgeInsets.all( 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: image,
          ),
        ),

        // const SizedBox(width: 16,),
        Container(
          width: MediaQuery.of(context).size.width - 150,
          height: 120,
          // color: Colors.lightBlueAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 40,
                // color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      color: PRIMARY_COLOR,
                      iconSize: 22.0,
                      onPressed: (){
                        showDialog(
                          context: context,
                          barrierDismissible: true, //바깥 영역 터치시 닫을지 여부 결정
                          builder: ((context) {
                            return AlertDialog(
                              title: Text("Delete"),
                              content: Text("Are you sure you want to delete this food?"),
                              actions: <Widget>[
                                Container(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); //창 닫기
                                    },
                                    child: Text("NO"),
                                  ),
                                ),
                                Container(
                                  child: ElevatedButton(
                                    onPressed: () async {

                                      Navigator.of(context).pop(); //창 닫기
                                    },
                                    child: Text("Yes", style: TextStyle(fontWeight: FontWeight.w700, color: PRIMARY_COLOR), ),
                                    style: ElevatedButton.styleFrom(
                                      // backgroundColor: Colors.white,
                                      // side: BorderSide(width: 1.0, color: PRIMARY_COLOR),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),

              Text(
                'Foods : $foods',
                style: TextStyle(color: BODY_TEXT_COLOR, fontSize: 14.0 ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                "calroies : $calorie",
                style: TextStyle(color: BODY_TEXT_COLOR, fontSize: 14.0 ),
              ),

            ],
          ),
        ),
      ],
    );
  }
}
