
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fooddiary/colors.dart';
import 'database/fooddata.dart';
import 'home_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  // The Gemini 1.5 models are versatile and work with both text-only and multimodal prompts
  // final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  // final content = [Content.text('Write a story about a AI and magic')];
  // final response = await model.generateContent(content);
  // print(response.text);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FoodDataProvider foodDataProvider = FoodDataProvider();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Diary',
      theme: ThemeData(
        primaryColor: PRIMARY_COLOR,
      ),
      home: FoodHome(foodDataProvider: foodDataProvider,),
    );
  }
  



  Widget _foodImageReslut(){

    // final jsonData = jsonDecode(_result.toString());
    // final foods = jsonData["Foods"];
    // final calorie = jsonData['calorie'];
    //
    // String content = "time ";

    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        Center(child: Text("Today's foodlog ListView"),)
        // FoodLogCard(image: Image.file(_image!, fit: BoxFit.cover,), content: content , foods: foods, calorie: calorie),
      ],
    );


  }

}

