import "package:flutter/material.dart";
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget{
  @override
State<HomePage> createState()=>_HomePageState();
}

class _HomePageState extends State<HomePage>{
TextEditingController dateController=TextEditingController();

@override
void initState(){
  super.initState();
  dateController.text="";
}

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title:const Text("Date picker")),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Center(child: TextField(
          controller: dateController,
          decoration: const InputDecoration(
            icon: Icon(Icons.calendar_today),
            labelText: "Enter Date"
          ),
          readOnly: true,
          onTap: () async{
            DateTime? pickedDate=await showDatePicker(context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            );
            if(pickedDate!=null){
              String formattedDate=DateFormat("yyyy-MM-dd").format(pickedDate);

                setState(() {
                  dateController.text=formattedDate.toString();
                });
            }else{
              print("Not selected");
            }
          },
        ))),
    );
  }
}