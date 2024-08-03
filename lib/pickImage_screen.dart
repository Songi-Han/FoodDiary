import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

import 'colors.dart';
import 'database/fooddata.dart';

class PickImageScreen extends StatefulWidget {
  final FoodDataProvider foodDataProvider;
  final bool isCamera;
  final FoodData? fData;
  final String startDate;

  PickImageScreen(
      {required this.foodDataProvider,
      required this.isCamera,
        required this.startDate,
      this.fData,
      Key? key})
      : super(key: key);

  @override
  State<PickImageScreen> createState() => _PickImageScreenState();
}

class _PickImageScreenState extends State<PickImageScreen> {
  String? _result;
  bool _isRes = false;

  File? _image;
  Image? fDataImage;
  String? date;
  String? time;
  String? foods;
  int? calorie;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.fData == null) {
      _pickImage();
    } else {
      setState(() {
        fDataImage = FoodData.uint8listToImage(widget.fData!.image);
        date = widget.fData!.date.toString().substring(0, 10);
        time = widget.fData!.date.toString().substring(11, 16);
        foods = widget.fData!.foods;
        calorie = widget.fData!.calories;

        _isRes = true;
      });
    }
  }

  Future<void> _pickImage() async {
    setState(() {
      _isRes = false;
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: widget.isCamera ? ImageSource.camera : ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _geminiLoad(_image!);
      });
    }
  }

  Future<void> _geminiLoad(File image) async {
    final apiKey = dotenv.get('API_KEY');
    if (apiKey == null) {
      debugPrint('[>> ] No \$API_KEY environment variable');
      return;
    }
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: "application/json",
      ),
    );
    final loadImage = await image.readAsBytes();
    final prompt = TextPart(
        "Extracts objects from a provided image and outputs them as an alphabetized list."
        " \nOnly foods are extracted from the printed list."
        " \nIt tells you the calories of each extracted food list."
        " \nFinally, it also gives you the calorie total for all your listings."
        "\n\nExample "
        "\nresponse : {'Foods' : ['Cheese', 'Meat','Pasta'] , 'calorie' : 500}");
    final imageParts = [
      DataPart('image/jpeg', loadImage),
    ];
    final response = await model.generateContent([
      Content.multi([prompt, ...imageParts])
    ]);

    setState(() {
      _result = response!.text;
      _isRes = true;
      debugPrint("[>> response:  $_result");

      final jsonData = jsonDecode(_result.toString());
      final foodsJson = jsonData["Foods"];
      final calorieJson = jsonData['calorie'];

      date = widget.startDate;
      time = DateTime.now().toString().substring(11, 16);
      calorie = int.parse(calorieJson.toString());
      foods = foodsJson.join(',').toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Food Info"),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: _image != null || fDataImage != null
              ? _isRes
                  ? _foodImageResult()
                  : Center(child: Text('Gemini API Loading...'))
              : Center(child: Text('No image selected')),
        ),
      ),
    );
  }

  Widget _foodImageResult() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: _image != null
              ? Image.file(
                  _image!,
                  fit: BoxFit.cover,
                )
              : fDataImage != null
                  ? fDataImage
                  : Text('Image Loading Error'),
        ),
        const SizedBox(
          height: 16.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    '$date',
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    onPressed: () async {
                      List<String> pickdate = date!.split('-');
                      final selectedDate = await showDatePicker(
                        context: context,
                        // 팝업으로 띄우기 때문에 context 전달
                        initialDate: DateTime(int.parse(pickdate[0]),int.parse(pickdate[1]),int.parse(pickdate[2])),
                        // 달력을 띄웠을 때 선택된 날짜.
                        firstDate: DateTime(2022),
                        // 시작 년도
                        lastDate: DateTime.now(),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              primaryColor: PRIMARY_COLOR,
                              colorScheme:
                                  ColorScheme.light(primary: PRIMARY_COLOR),
                              buttonTheme: ButtonThemeData(
                                textTheme: ButtonTextTheme.primary,
                              ),
                            ),
                            child: child!,
                          );
                        }, // 마지막 년도. 오늘로 지정하면 미래의 날짜는 선택할 수 없음
                      );
                      if (selectedDate != null) {
                        setState(() {
                          date = selectedDate.toString().substring(0, 10);
                          debugPrint("date : $date");
                        });
                      }
                    },
                    color: Colors.lightBlue,
                    highlightColor: PRIMARY_COLOR,
                    icon: Icon(Icons.calendar_month_rounded),
                    tooltip: 'select day',
                  ),
                  Text(
                    ' /   $time',
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    onPressed: () async {
                      final selectedTime = await showTimePicker(
                        context: context, // 팝업으로 띄우기 때문에 context 전달
                        initialTime: TimeOfDay.now(), // 달력을 띄웠을 때 선택된 날짜.
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              primaryColor: PRIMARY_COLOR,
                              colorScheme:
                                  ColorScheme.light(primary: PRIMARY_COLOR),
                              buttonTheme: ButtonThemeData(
                                textTheme: ButtonTextTheme.primary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (selectedTime != null) {
                        setState(() {
                          time =
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                          debugPrint("time : $time");
                        });
                      }
                    },
                    color: Colors.lightBlue,
                    highlightColor: PRIMARY_COLOR,
                    icon: Icon(Icons.timelapse),
                    tooltip: 'select day',
                  ),
                ],
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                'Foods : ${foods}',
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
              if (_image != null)
                ElevatedButton(
                  onPressed: () async {
                    await putFooddata();
                    Navigator.pop(context, date);
                  },
                  child: Text(
                    'SAVE',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY_COLOR,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0))),
                ),
              if (fDataImage != null)
                ElevatedButton(
                  onPressed: () async {
                    await putFooddata();
                    Navigator.pop(context, date);
                  },
                  child: Text(
                    'UPDATE',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY_COLOR,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0))),
                ),
              const SizedBox(height: 20.0,),
            ],
          ),
        ),
      ],
    );

    // return FoodinfoCard(
    //     foodDataProvider: widget.foodDataProvider,
    //     image: _image!,
    //     datetime: DateTime(int.parse(dateList[0]), int.parse(dateList[1]), int.parse(dateList[2]), int.parse(timeList[0]), int.parse(timeList[1])),
    //     content: content,
    //     foods: strFoods,
    //     calorie: int.parse(calorie.toString())
    // );
  }

  Future<void> putFooddata() async {
    List dateList = date!.split('-');
    List timeList = time!.split(':');
    DateTime datetime = DateTime(int.parse(dateList[0]), int.parse(dateList[1]),
        int.parse(dateList[2]), int.parse(timeList[0]), int.parse(timeList[1]));

    debugPrint("datetime update : ${dateTimeToString(datetime!)}");

    if (widget.fData != null) {
      widget.fData!.date = dateTimeToString(datetime!);
      widget.fData!.content = '$date / $time';
      await widget.foodDataProvider.update(widget.fData!);
    } else {
      var result = await FlutterImageCompress.compressWithFile(
        _image!.absolute.path,
        minWidth: 1920,
        minHeight: 1080,
        quality: 95,
      );
      if(result == null ){
        debugPrint("image Compress ERROR !!! ");
        return;
      }

      Map<String, dynamic> fooddata = ({
        '_datetime': dateTimeToString(datetime!),
        'content': '$date / $time',
        'foods': foods.toString(),
        // 'image': await _image!.readAsBytes(),
        'image': result,
        //await을 넣지 않으면 Future<Uint8List> 형이 들어감
        'calories': calorie,
      });
      await widget.foodDataProvider.insert(fooddata);
    }
  }

  String dateTimeToString(DateTime dateTime) {
    return dateTime.toIso8601String().split('.')[0].replaceAll('T', ' ');
  }


}
