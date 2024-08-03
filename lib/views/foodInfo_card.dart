import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fooddiary/database/fooddata.dart';

import '../colors.dart';
class FoodinfoCard extends StatelessWidget {
  final FoodDataProvider foodDataProvider;

  final File image;
  final DateTime datetime;
  final String content;
  final String foods;
  final int calorie;

  const FoodinfoCard({
    required this.foodDataProvider,
    required this.image,
    required this.datetime,
    required this.content,
    required this.foods,
    required this.calorie,
    Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.file(image, fit: BoxFit.cover,),
        ),
        const SizedBox(
          height: 16.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                content,
                style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                'foods : ${foods}',
                style: TextStyle(color: BODY_TEXT_COLOR, fontSize: 16.0),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                'calories : ${calorie.toString()}',
                style: TextStyle(color: BODY_TEXT_COLOR, fontSize: 16.0),
              ),
              const SizedBox(
                height: 40.0,
              ),
              ElevatedButton(
                onPressed: () async {
                    await insertFooddata();
                    Navigator.pop(context, 'foodListUpdate');
                },
                child: Text('SAVE', style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Future<void> insertFooddata() async {

    Map<String , dynamic> fooddata = ({
      '_datetime': dateTimeToString(datetime),
      'content': content,
      'foods': foods.toString(),
      'image':
        await image.readAsBytes(), //await을 넣지 않으면 Future<Uint8List> 형이 들어감
      'calories' : calorie,
    });

    await foodDataProvider.insert(fooddata);
  }

  String dateTimeToString(DateTime dateTime) {
    return dateTime.toIso8601String().split('.')[0].replaceAll('T', ' ');
  }
}


