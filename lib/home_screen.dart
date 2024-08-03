import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fooddiary/database/fooddata.dart';
import 'package:fooddiary/pickImage_screen.dart';

import 'colors.dart';

class FoodHome extends StatefulWidget {
  final FoodDataProvider foodDataProvider;

  FoodHome({required this.foodDataProvider, Key? key}) : super(key: key);

  @override
  State<FoodHome> createState() => _FoodHomeState();
}

class _FoodHomeState extends State<FoodHome> {
  bool isToday = true;
  String startDate = DateTime.now().toString().substring(0, 10);
  String endDate = DateTime.now().toString().substring(0, 10);
  bool isLoading = true;
  int total = 0;
  late Future<List<FoodData>> fooddatas =
      widget.foodDataProvider.getFoodlog(startDate, endDate);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    debugPrint('>>>>>>>>>>>> fooddatas!! ');

  }

  Future<void> _showDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: Text('Where do I get the image?'),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    return await _navigateAndReload(context, true, null);
                  },
                  child: Text(
                    "Camera",
                    style: TextStyle(color: PRIMARY_COLOR),
                  )),
              ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    return await _navigateAndReload(context, false, null);
                  },
                  child: Text(
                    "Gallery",
                    style: TextStyle(color: PRIMARY_COLOR),
                  )),
            ],
          );
        });
  }

  Future<void> _navigateAndReload(
      BuildContext context, bool isCamera, FoodData? fData) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PickImageScreen(
                foodDataProvider: widget.foodDataProvider,
                isCamera: isCamera,
                fData: fData,
                startDate : startDate,
              )),
    );

    // if result value is date String
    if(result != null && result.toString().contains('-')){
      setState(() {
        startDate = result;
        endDate = result;
      });
    }
    _dataReload();
  }

  void _dataReload() {
    // 상태를 다시 로딩
    setState(() {
      debugPrint("startDate : $startDate / endDate : $endDate ");
      fooddatas = widget.foodDataProvider.getFoodlog(startDate, endDate);
      total = 0;
      isLoading = true;
      if (startDate == DateTime.now().toString().substring(0, 10)) {
        isToday = true;
      } else {
        isToday = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Food Diary',
          style: TextStyle(color: PRIMARY_TEXT_COLOR),
        ),
        backgroundColor: PRIMARY_COLOR,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            margin: EdgeInsets.only(top: 8),
            // color: Colors.cyanAccent,
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isToday ? 'Today, ' : 'Date, ',
                  style: TextStyle(
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                ),
                Text(
                  isToday ? '$startDate' : '$startDate',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0),
                ),
                IconButton(
                  onPressed: () async {
                    List<String> pickdate = startDate.split('-');
                    debugPrint('${int.parse(pickdate[0])} ,${int.parse(pickdate[1])}, ${int.parse(pickdate[2])} ');
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
                        startDate = selectedDate
                            .toString()
                            .substring(0, 10); // 선택한 날짜는 date 변수에 저장
                        endDate = selectedDate.toString().substring(0, 10);
                        _dataReload();
                      });
                    }
                  },
                  color: Colors.lightBlue,
                  highlightColor: PRIMARY_COLOR,
                  icon: Icon(Icons.calendar_month_rounded),
                  tooltip: 'select day',
                ),
              ],
            ),
          ),
          if (total != 0)
            Container(
              height: 20.0,
              child: Text('Total Calories : $total'),
            ),
          const SizedBox(
            height: 10,
          ),
          FutureBuilder(
            future: fooddatas,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error : ${snapshot.error}');
              } else {
                List<FoodData> foodList = snapshot.data as List<FoodData>;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  debugPrint('foodlist : ${foodList.length}');
                  if (isLoading) {
                    setState(() {
                      isLoading = false;
                    });
                    for (int i = 0; i < foodList.length; i++) {
                      var data = foodList[i];
                      setState(() {
                        total += data.calories;
                      });
                    }
                  }
                });

                if (foodList.length <= 0) {
                  return Center(
                    child: Text('Nothing Food Log.'),
                  );
                } else {
                  return Expanded(
                    child: ListView.builder(
                        itemCount: foodList.length,
                        itemBuilder: (context, index) {
                          var fData = foodList[index];
                          return GestureDetector(
                              onTap: () {
                                debugPrint('click : ${fData.foods}');
                                _navigateAndReload(context, false, fData);
                              },
                              child: _FoodLogCard(fData));
                        }),
                  );
                }
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        tooltip: 'Pick Image',
        child: Icon(
          Icons.add_a_photo,
          color: PRIMARY_COLOR,
        ),
        backgroundColor: INPUT_BG_COLOR,
      ),
    );
  }

  Widget _FoodLogCard(FoodData fData) {
    return Row(
      children: [
        Container(
          width: 120,
          height: 120,
          margin: EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: FoodData.uint8listToImage(fData.image),
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
                      fData.content!,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      color: PRIMARY_COLOR,
                      iconSize: 22.0,
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: true, //바깥 영역 터치시 닫을지 여부 결정
                          builder: ((context) {
                            return AlertDialog(
                              title: Text("Delete"),
                              content: Text(
                                  "Are you sure you want to delete this food?"),
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
                                      await widget.foodDataProvider
                                          .delete(fData.id!);
                                      Navigator.of(context).pop();
                                      _dataReload();
                                      // setState(() {
                                      //   fooddatas = widget.foodDataProvider
                                      //       .getFoodlog(startDate, endDate);
                                      // });
                                    },
                                    child: Text(
                                      "Yes",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: PRIMARY_COLOR),
                                    ),
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
                'Foods : ${fData.foods}',
                style: TextStyle(color: BODY_TEXT_COLOR, fontSize: 14.0),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                'calories : ${fData.calories}',
                style: TextStyle(color: BODY_TEXT_COLOR, fontSize: 14.0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
