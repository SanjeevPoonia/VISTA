import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import 'dart:io';
import '../network/Utils.dart';
import '../network/api_dialog.dart';
import '../network/api_helper.dart';
import '../utils/app_theme.dart';
import '../utils/audio_recording_dialog.dart';
import '../utils/textfield_widget.dart';

class AssignCompletedTask extends StatefulWidget{
  String taskId;
  String taskTitle;
  String categoryId;

  AssignCompletedTask(this.taskId,this.taskTitle,this.categoryId ,{super.key});

  _assignTaskState createState()=>_assignTaskState();
}
class _assignTaskState extends State<AssignCompletedTask>{
  var sMobileNumber="";
  var sPersonName="";
  var sUserLanguage="";
  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";
  var empRoleId="";
  var empShiftId="";
  var pageTitle="Assign Task";
  var remarkController=TextEditingController();


  List<String> occasionList=["Daily","Alternately","Weekly"];
  String? selectedOccasion;
  String selectedOccasionId="";

  List<String> frequencyList=[];
  String? selectedFrequency;
  String selectedFrequencyId="";

  String selectedStartDate="";
  String selectedStartTime="";
  String selectedEndDate="";
  String selectedEndTime="";

  List<String> priorityList=["critical","high","medium","low"];
  String? selectedPriority;

  List<String> reminderList=["05 Minutes","10 Minutes","15 Minutes","20 Minutes","30 Minutes","45 Minutes"];
  String? selectedReminder;
  String selectedReminderId="";

  List<dynamic> categoryList=[];
  List<dynamic> buildingMainList=[];
  List<dynamic> unitMainList=[];
  List<dynamic> filteredUnitMainList=[];
  List<dynamic> durationsMainList=[];
  List<dynamic> shiftsMainList=[];
  List<dynamic> usersMainList=[];

  List<String> userList=[];
  String? selectedUser;
  String selectedUserId="";

  List<String> shiftList=[];
  String? selectedShift;
  String selectedShiftId="";



  List<String> buildingList=[];
  String? selectedBuilding;
  String selectedBuildingId="";

  List<String> unitList=[];
  String?selectedUnit;
  String selectedUnitId="";

  List<String> durationList=[];
  String?selectedDuration;
  String selectedDurationId="";


  String? _filePathRecording;
  String recordingFileName="";
  String categoryName="";

  File? imageFile;

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return SafeArea(
        child:
        Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar  (
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_outlined, color: AppTheme.themeColor,size: 24,),
              onPressed: () => {
                Navigator.pop(context)
              },
            ),
            backgroundColor: AppTheme.at_details_header,
            title:  Text(
              pageTitle,
              style: const TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            /* actions: [
             IconButton(onPressed: (){
               _showAlertDialog();
             }, icon: const Icon(Icons.logout, color: AppTheme.task_Reopen_text,size: 35,))] ,*/
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.all(15),
            child: ListView(
              children: [
                Text(widget.taskTitle,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: AppTheme.themeColor),),
                const SizedBox(height: 16),
                Text("Category: $categoryName",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.black),),
                const SizedBox(height: 16),

                const Text("Shift*",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                    )),
                const SizedBox(height: 4,),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE4E4E4)),
                    borderRadius: BorderRadius.circular(1.0),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      hint: const Text("Select Shift",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey,fontSize: 14),),
                      value: selectedShift,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: shiftList.map((String items) {
                        return DropdownMenuItem(value: items, child: Text(items));
                      }).toList(),
                      onChanged: (String? newValue){
                        selectedShift=newValue!;
                        setState(() {
                        });
                        _filterUserList();
                      },

                    ),
                  ),
                ),
                const SizedBox(height: 16),


                const Text("User*",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                    )),
                const SizedBox(height: 4,),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE4E4E4)),
                    borderRadius: BorderRadius.circular(1.0),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      hint: const Text("Select Shift",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey,fontSize: 14),),
                      value: selectedUser,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: userList.map((String items) {
                        return DropdownMenuItem(value: items, child: Text(items));
                      }).toList(),
                      onChanged: (String? newValue){
                        selectedUser=newValue!;
                        setState(() {
                        });
                        _selectUserId();
                      },

                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text("Building",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                    )),
                const SizedBox(height: 4,),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 13),

                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE4E4E4)),
                    borderRadius: BorderRadius.circular(1.0),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      hint: const Text("Select Building",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey,fontSize: 14),),
                      value: selectedBuilding,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: buildingList.map((String items) {
                        return DropdownMenuItem(value: items, child: Text(items));
                      }).toList(),
                      onChanged: (String? newValue){
                        selectedBuilding=newValue!;
                        setState(() {
                        });
                        _filterUnitList();
                      },

                    ),
                  ),
                ),

                const SizedBox(height: 16),
                selectedBuildingId.isNotEmpty?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Unit*",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black
                        )),
                    const SizedBox(height: 4,),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 13),

                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE4E4E4)),
                        borderRadius: BorderRadius.circular(1.0),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          hint: const Text("Select Unit",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey,fontSize: 14),),
                          value: selectedUnit,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: unitList.map((String items) {
                            return DropdownMenuItem(value: items, child: Text(items));
                          }).toList(),
                          onChanged: (String? newValue){
                            selectedUnit=newValue!;
                            setState(() {
                            });
                            _setUnitOnSelection();
                          },

                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ):Container(),


                const Text("Occasion",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                    )),
                const SizedBox(height: 4,),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 13),

                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE4E4E4)),
                    borderRadius: BorderRadius.circular(1.0),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      hint: const Text("Select Occasion",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey,fontSize: 14),),
                      value: selectedOccasion,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: occasionList.map((String items) {
                        return DropdownMenuItem(value: items, child: Text(items));
                      }).toList(),
                      onChanged: (String? newValue){
                        selectedOccasion=newValue!;
                        setState(() {
                        });
                        _setOccasionSelectionChanges();
                      },

                    ),
                  ),
                ),
                const SizedBox(height: 16),
                selectedOccasionId.isNotEmpty?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Set Frequency*",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black
                        )),
                    const SizedBox(height: 4,),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 13),

                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE4E4E4)),
                        borderRadius: BorderRadius.circular(1.0),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          hint: const Text("Select Task Frequency",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey,fontSize: 14),),
                          value: selectedFrequency,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: frequencyList.map((String items) {
                            return DropdownMenuItem(value: items, child: Text(items));
                          }).toList(),
                          onChanged: (String? newValue){
                            selectedFrequency=newValue!;
                            setState(() {
                            });
                            _setFrequencySelectionChanges();
                          },

                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ):Container(),

                const Text("Select Start Date & Time*",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                    )),
                const SizedBox(height: 4,),
                InkWell(
                  onTap: (){
                    _selectDateTime(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE4E4E4), // Border color
                          width: 2.0,         // Border width
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white

                    ),


                    child: Row(
                      children: [
                        Expanded(flex:1,child: Text(
                          "$selectedStartDate $selectedStartTime",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.black,fontSize: 13),

                        )),
                        SizedBox(),
                        const Icon(Icons.calendar_month_outlined,size: 24,color: Color(0xFFE4E4E4),)

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text("Select End Date & Time*",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                    )),
                const SizedBox(height: 4,),
                InkWell(
                  onTap: (){
                    if(selectedStartDate.isNotEmpty){
                      _selectEndDateTime(context);
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select start date and time first")));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE4E4E4), // Border color
                          width: 2.0,         // Border width
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white

                    ),


                    child: Row(
                      children: [
                        Expanded(flex:1,child: Text(
                          "$selectedEndDate $selectedEndTime",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.black,fontSize: 13),

                        )),
                        SizedBox(),
                        const Icon(Icons.calendar_month_outlined,size: 24,color: Color(0xFFE4E4E4),)

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),




                const Text("Set Priority*",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                    )),
                const SizedBox(height: 4,),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 13),

                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE4E4E4)),
                    borderRadius: BorderRadius.circular(1.0),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      hint: const Text("Select Priority",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey,fontSize: 14),),
                      value: selectedPriority,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: priorityList.map((String items) {
                        return DropdownMenuItem(value: items, child: Text(items));
                      }).toList(),
                      onChanged: (String? newValue){
                        selectedPriority=newValue!;
                        setState(() {
                        });
                      },

                    ),
                  ),
                ),
                const SizedBox(height: 16),

               /* const Text("Set Reminder*",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                    )),
                const SizedBox(height: 4,),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 13),

                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE4E4E4)),
                    borderRadius: BorderRadius.circular(1.0),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      hint: const Text("Select Reminder time",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey,fontSize: 14),),
                      value: selectedReminder,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: reminderList.map((String items) {
                        return DropdownMenuItem(value: items, child: Text(items));
                      }).toList(),
                      onChanged: (String? newValue){
                        selectedReminder=newValue!;
                        setState(() {
                        });
                        _setReminderSelectionChanges();
                      },

                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Task Duration*",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                    )),
                const SizedBox(height: 4,),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 13),

                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE4E4E4)),
                    borderRadius: BorderRadius.circular(1.0),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      hint: const Text("Select Task Duration",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey,fontSize: 14),),
                      value: selectedDuration,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: durationList.map((String items) {
                        return DropdownMenuItem(value: items, child: Text(items));
                      }).toList(),
                      onChanged: (String? newValue){
                        selectedDuration=newValue!;
                        setState(() {
                        });
                        _onDurationSelected();
                      },


                    ),
                  ),
                ),
                const SizedBox(height: 16),*/


                /*const Text("Add Audio Instructions",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                    )),
                const SizedBox(height: 4,),
                InkWell(
                  onTap: ()async{
                    print("Record button tapped");
                    int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
                    String fileNameCustom="${currentTimeMillis}Instruction";
                    _filePathRecording= await showDialog<String>(
                      context: context,
                      builder: (context)=>AudioRecordingDialog(fileNameCustom),
                    );
                    if (_filePathRecording != null) {
                      if(_filePathRecording!.isNotEmpty){

                        String filePath="";
                        filePath=_filePathRecording!;
                        recordingFileName=filePath.split("/").last;
                        print('Recorded file path: $_filePathRecording');
                        setState(() {

                        });
                        // uploadAudio();
                      }
                      // You can now use this path, e.g., save, upload, or play it.
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    // height: 56,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE4E4E4), // Border color
                          width: 2.0,         // Border width
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white

                    ),

                    child: Row(
                      children: [
                        Expanded(flex:1,child: Text(
                          recordingFileName,style: const TextStyle(fontWeight: FontWeight.w500,color: Colors.black,fontSize: 13),
                        )),
                        SizedBox(),
                        const Icon(
                          Icons.mic
                          ,size: 24,color: AppTheme.orangeColor,
                        )

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFieldWidgetMultiline(
                  "Remark",
                  "Enter Remark",
                  controller: remarkController,
                  validator: null,
                ),
                const SizedBox(height: 16,),*/

                recordingFileName.isNotEmpty?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Audio Remark",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black
                        )),
                    SizedBox(height: 7,),
                    Container(
                      padding: EdgeInsets.all(10),
                      // height: 56,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE4E4E4), // Border color
                            width: 2.0,         // Border width
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white

                      ),

                      child: Row(
                        children: [
                          Expanded(flex:1,child: Text(
                            recordingFileName,style: const TextStyle(fontWeight: FontWeight.w500,color: Colors.black,fontSize: 13),
                          )),
                          SizedBox(),
                        ],
                      ),
                    )
                  ],
                ):
                Container(),

                imageFile!=null?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Image Remark",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black
                        )),
                    SizedBox(height: 7,),
                    Container(
                      padding: EdgeInsets.all(10),
                      height: 200,
                      width: double.infinity,
                      // height: 56,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE4E4E4), // Border color
                            width: 2.0,         // Border width
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white

                      ),

                      child: Image.file(imageFile!),
                    )
                  ],
                ):
                Container(),

                const SizedBox(height: 16),
                const Text("Remark",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        //color: Colors.black
                        color: Color(0xFF9D9CA0)
                    )),
                const SizedBox(height: 7),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: const Color(0xFFE4E4E4),
                        width: 1.0
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex:1,child:
                      TextFormField(
                        controller: remarkController,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          border: InputBorder.none,           // Removes all borders (including the bottom line)
                          enabledBorder: InputBorder.none,    // Removes border when enabled
                          focusedBorder: InputBorder.none,    // Removes border when focused
                          hintText: 'Enter Remark',
                        ),
                        maxLines: null,
                        minLines: 3,
                      ),
                        /*TextFieldWidgetMultiline(
                        "Remark",
                        "Enter Remark",
                        controller: remarkController,
                        validator: null,
                      )*/
                      ),
                      SizedBox(width: 5,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: ()async{
                              print("Record button tapped");
                              int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
                              String fileNameCustom="${currentTimeMillis}Instruction";
                              _filePathRecording= await showDialog<String>(
                                context: context,
                                builder: (context)=>AudioRecordingDialog(fileNameCustom),
                              );
                              if (_filePathRecording != null) {
                                if(_filePathRecording!.isNotEmpty){

                                  String filePath="";
                                  filePath=_filePathRecording!;
                                  recordingFileName=filePath.split("/").last;
                                  print('Recorded file path: $_filePathRecording');
                                  setState(() {

                                  });
                                  // uploadAudio();
                                }
                                // You can now use this path, e.g., save, upload, or play it.
                              }
                            },
                            child: const Icon(
                              Icons.mic
                              ,size: 24,color: AppTheme.orangeColor,
                            ),
                          ),
                          SizedBox(height: 10,),
                          InkWell(
                            onTap: (){
                              _pickImage();
                            },
                            child: const Icon(
                              Icons.image_outlined
                              ,size: 24,color: AppTheme.orangeColor,
                            ),
                          ),

                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16,),


                InkWell(
                  onTap: (){
                    onCreateTaskButtonClick();
                  },
                  child: Container(
                    height: 58,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 13),
                    // padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [AppTheme.baseOrangeStart, AppTheme.baseOrange],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Assign Task",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ),
                  ),
                )

              ],
            ),
          ),

        )
    );
  }
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }
  Future<void> _selectEndDateTime(BuildContext context) async {

    final DateTime startDateTime = DateTime.parse("$selectedStartDate $selectedStartTime");

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDateTime,
      firstDate: startDateTime,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(startDateTime),
      );

      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        print("Selected DateTime: $fullDateTime");


        String year = pickedDate.year.toString();
        String month = pickedDate.month.toString().padLeft(2, '0'); // Add leading zero if needed
        String day = pickedDate.day.toString().padLeft(2, '0');
        String hour = pickedTime.hour.toString().padLeft(2, '0');
        String minute = pickedTime.minute.toString().padLeft(2, '0');

        if(fullDateTime.isBefore(startDateTime)){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("End time can't be earlier than start time($selectedStartDate $selectedStartTime)")));
          return;
        }

        selectedEndDate="$year-$month-$day";
        selectedEndTime="$hour:$minute:00";

        setState(() {

        });
        // Do something with fullDateTime (like update a controller)
      }
    }
  }
  _setOccasionSelectionChanges(){

    if(selectedOccasion=="Daily"){
      selectedOccasionId="daily";
    }else if(selectedOccasion=="Alternately"){
      selectedOccasionId="alternately";
    }else if(selectedOccasion=="Weekly"){
      selectedOccasionId="weekly";
    }

    frequencyList.clear();
    selectedFrequency=null;
    selectedFrequencyId="";

    if(selectedOccasionId=="1" ||  selectedOccasionId=="daily"){
      frequencyList.add("Hourly (every hour)");
      frequencyList.add("2 Hours (every 2 hour)");
      frequencyList.add("4 Hours (every 4 hour)");
      frequencyList.add("Once a day");
    }else if(selectedOccasionId=="2" || selectedOccasionId=="alternately"){
      frequencyList.add("After 1 day");
      frequencyList.add("After 2 day");
      frequencyList.add("After 3 day");
    }else if(selectedOccasionId=="3" || selectedOccasionId=="weekly"){
      frequencyList.add("Once in a week");
      frequencyList.add("After 2 weeks");
      frequencyList.add("After 3 weeks");
    }


    setState(() {

    });




  }
  _setFrequencySelectionChanges(){


    if(selectedFrequency=="Hourly (every hour)"){
      selectedFrequencyId="1 hour";
    }else if(selectedFrequency=="2 Hours (every 2 hour)"){
      selectedFrequencyId="2 hour";
    }else if(selectedFrequency=="4 Hours (every 4 hour)"){
      selectedFrequencyId="4 hour";
    }else if(selectedFrequency=="Once a day"){
      selectedFrequencyId="16 hour";
    } else if(selectedFrequency=="After 1 day"){
      selectedFrequencyId="1 Day";
    } else if(selectedFrequency=="After 2 day"){
      selectedFrequencyId="2 Day";
    } else if(selectedFrequency=="After 3 day"){
      selectedFrequencyId="3 Day";
    } else if(selectedFrequency=="Once in a week"){
      selectedFrequencyId="1 Week";
    } else if(selectedFrequency=="After 2 weeks"){
      selectedFrequencyId="2 Week";
    } else if(selectedFrequency=="After 3 weeks"){
      selectedFrequencyId="3 Week";
    }
    setState(() {

    });




  }
  _setReminderSelectionChanges(){
    if(selectedReminder=="05 Minutes"){
      selectedReminderId="5";
    }else if(selectedReminder=="10 Minutes"){
      selectedReminderId="10";
    }else if(selectedReminder=="15 Minutes"){
      selectedReminderId="15";
    }else if(selectedReminder=="20 Minutes"){
      selectedReminderId="20";
    } else if(selectedReminder=="30 Minutes"){
      selectedReminderId="30";
    } else if(selectedReminder=="45 Minutes"){
      selectedReminderId="45";
    }
    setState(() {

    });
  }
  @override
  void initState() {
    super.initState();
    _getUserData();
  }
  _getUserData() async {
    sMobileNumber=await MyUtils.getSharedPreferences("mobile_no")??"";
    sPersonName=await MyUtils.getSharedPreferences("name")??"";
    sRemeberToken=await MyUtils.getSharedPreferences("token")??"";
    sUserId=await MyUtils.getSharedPreferences("user_id")??"";
    sUserLanguage=await MyUtils.getSharedPreferences("language")??"";
    baseUrl=await MyUtils.getSharedPreferences("base_url")??"";
    empRoleId=await MyUtils.getSharedPreferences("emp_role_id")??"";
    empShiftId=await MyUtils.getSharedPreferences("emp_shift_id")??"";

    print("Employee Role Id $empRoleId");
    print("Employee empShiftId Id $empShiftId");
    print("UserId $sUserId");
    if(Platform.isAndroid){
      platform="Android";
    }else if(Platform.isIOS){
      platform="iOS";
    }else{
      platform="Other";
    }
    setState(() {
    });

    _getHomePageData(context);

  }
  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        print("Selected DateTime: $fullDateTime");


        String year = pickedDate.year.toString();
        String month = pickedDate.month.toString().padLeft(2, '0'); // Add leading zero if needed
        String day = pickedDate.day.toString().padLeft(2, '0');
        String hour = pickedTime.hour.toString().padLeft(2, '0');
        String minute = pickedTime.minute.toString().padLeft(2, '0');


        selectedStartDate="$year-$month-$day";
        selectedStartTime="$hour:$minute:00";

        setState(() {

        });
        // Do something with fullDateTime (like update a controller)
      }
    }
  }
  void onCreateTaskButtonClick(){
      if(checkAssignValidation()){
        _assignTaskToUser();
      }
  }
  bool checkBuildingValidation(){
    if(selectedBuildingId.isNotEmpty){
      if(selectedUnitId.isNotEmpty){
        return true;
      }else{
        Toast.show("Please Select Unit",
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.red);
        return false;
      }

    }else{
      return true;
    }
  }
  bool checkAssignValidation(){
    if(selectedShiftId.isNotEmpty){
      if(selectedUserId.isNotEmpty) {
          if (checkBuildingValidation()) {
                if (selectedStartDate.isNotEmpty) {
                  if (selectedStartTime.isNotEmpty) {
                    if(selectedEndDate.isNotEmpty) {
                      if(selectedEndTime.isNotEmpty) {
                        if (selectedPriority != null && selectedPriority!.isNotEmpty) {
                                  return true;
                        } else {
                          Toast.show("Please Select Task Priority",
                              duration: Toast.lengthLong,
                              gravity: Toast.bottom,
                              backgroundColor: Colors.red);
                          return false;
                        }
                      }else{
                        Toast.show("Please Select Task End Time",
                            duration: Toast.lengthLong,
                            gravity: Toast.bottom,
                            backgroundColor: Colors.red);
                        return false;
                      }
                    }else{
                      Toast.show("Please Select Task End Date",
                          duration: Toast.lengthLong,
                          gravity: Toast.bottom,
                          backgroundColor: Colors.red);
                      return false;
                    }
                  } else {
                    Toast.show("Please Select Task Start Time",
                        duration: Toast.lengthLong,
                        gravity: Toast.bottom,
                        backgroundColor: Colors.red);
                    return false;
                  }
                }
                else {
                  Toast.show("Please Select Task Start Date",
                      duration: Toast.lengthLong,
                      gravity: Toast.bottom,
                      backgroundColor: Colors.red);
                  return false;
                }
          } else {
            return false;
          }
      }else{
        Toast.show("Please Select User",
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.red);
        return false;
      }
    }else{
      Toast.show("Please Select Shift",
      duration: Toast.lengthLong,
      gravity: Toast.bottom,
      backgroundColor: Colors.red);
      return false;
      }
  }
  _getHomePageData(BuildContext context) async {
    APIDialog.showAlertDialog(context, 'Please Wait...');
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'get-masters', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      categoryList.clear();
      categoryList=responseJSON["data"]["categories"];
      for(int i=0;i<categoryList.length;i++){
        String id=categoryList[i]['role_id'].toString();
        if(id==widget.categoryId){
          categoryName=categoryList[i]['role'].toString();
          break;
        }
      }
      buildingMainList.clear();
      buildingMainList=responseJSON["data"]['buildings'];
      unitMainList.clear();
      unitMainList=responseJSON['data']['unit_list'];
      durationsMainList.clear();
      durationsMainList=responseJSON['data']['durations'];
      shiftsMainList.clear();
      shiftsMainList=responseJSON['data']['shifts'];
      _filterBuildingList();
    }
    else {
      Toast.show(responseJSON["message"].toString(),
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      _finishScreen();
    }


  }
  _finishScreen() {
    Navigator.of(context).pop();
  }
  _filterBuildingList(){
    buildingList.clear();
    for(int i=0;i<buildingMainList.length;i++){
      String buildingName=buildingMainList[i]['name'].toString();
      buildingList.add(buildingName);
    }
    durationList.clear();
    for(int i=0;i<durationsMainList.length;i++){
      String durationName=durationsMainList[i]['time'].toString();

      if(!durationList.contains(durationName)){
        durationList.add(durationName);
      }

    }
    shiftList.clear();
    for(int i=0;i<shiftsMainList.length;i++){
      String name=shiftsMainList[i]['name'].toString();
      if(!shiftList.contains(name)){
        shiftList.add(name);
      }
    }



    setState(() {

    });

  }
  _onDurationSelected(){
    for(int i=0;i<durationList.length;i++){
      String durationName=durationsMainList[i]['time'].toString();
      if(durationName==selectedDuration){
        selectedDurationId=durationsMainList[i]['id'].toString();
        break;
      }
    }
  }
  _filterUnitList(){
    for(int i=0;i<buildingMainList.length;i++){
      String maninName=buildingMainList[i]['name'].toString();
      if(maninName==selectedBuilding){
        selectedBuildingId=buildingMainList[i]['id'].toString();
        break;
      }
    }





    filteredUnitMainList.clear();
    unitList.clear();
    selectedUnit=null;
    selectedUnitId="";

    for(int i=0;i<unitMainList.length;i++){
      String buildID=unitMainList[i]['building_id'].toString();
      if(buildID==selectedBuildingId){
        String unitNumber=unitMainList[i]['unit_number'].toString();
        unitList.add(unitNumber);
        filteredUnitMainList.add(unitMainList[i]);
      }

    }

    setState(() {

    });


  }
  _setUnitOnSelection(){
    for(int i=0;i<filteredUnitMainList.length;i++){
      String name=filteredUnitMainList[i]['unit_number'].toString();
      if(name==selectedUnit){
        selectedUnitId=filteredUnitMainList[i]['id'].toString();
        break;
      }
    }

    setState(() {

    });
  }
  _assignTaskToUser(){
    if(_filePathRecording!=null && _filePathRecording!.isNotEmpty){
      _AssignTaskWithRecording(context);
    }else{
      _AssignTaskOnServer(context);
    }
  }
  _AssignTaskOnServer(BuildContext context)async{
    APIDialog.showAlertDialog(context, 'Please Wait...');
    var jsonArray=[];
    jsonArray.add(selectedUserId);
    var param={
      "auth_key":sRemeberToken,
      "task_id":widget.taskId,
      "user_ids":jsonArray,
      "shift_id":empShiftId,
      "building_id":selectedBuildingId,
      "unit_id":selectedUnitId,
      "priority":selectedPriority,
      "start_time":selectedStartTime,
      "start_date":selectedStartDate,
      "end_time":selectedEndTime,
      "end_date":selectedEndDate,
      /*"task_duration":selectedDuration,
      "reminder":selectedReminderId,*/
      "task_frequency":selectedOccasionId,
      "task_frequency_occasion":selectedFrequencyId,
      "remark":remarkController.text.toString(),

    };
    print(param);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'assign-task', param, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1 ||responseJSON["status"]==200)
    {
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.green);
      _finishScreen();
    }
    else {
      Toast.show(responseJSON["error"].toString(),
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }

  }
  _AssignTaskWithRecording(BuildContext context) async{
    APIDialog.showAlertDialog(context, 'Please wait.Assigning Task');
    String fileName="";
    String filePath="";
    String extension="";
    String imageFileName="";
    String imageFilePath="";
    String imageExtension="";
    bool isAudio=false;
    bool isImage=false;
    if(_filePathRecording!=null && _filePathRecording!.isNotEmpty){
      filePath=_filePathRecording!;
      fileName=filePath.split("/").last;
      extension = fileName.split('.').last;
      isAudio=true;
    }

    if(imageFile!=null){
      imageFilePath=imageFile!.path;
      imageFileName=imageFilePath.split("/").last;
      imageExtension=imageFilePath.split(".").last;
      isImage=true;

    }
    List<String> userssssList=[];
    userssssList.add(selectedUserId);

    FormData formData = FormData.fromMap({
      "auth_key":sRemeberToken,
      "task_id":widget.taskId,

      "shift_id":empShiftId,
      "building_id":selectedBuildingId,
      "unit_id":selectedUnitId,
      "priority":selectedPriority,
      "start_time":selectedStartTime,
      "start_date":selectedStartDate,
      "end_date":selectedEndDate,
      "end_time":selectedEndTime,
     /* "task_duration":selectedDuration,
      "reminder":selectedReminderId,*/
      "task_frequency":selectedOccasionId,
      "task_frequency_occasion":selectedFrequencyId,
      "remark":remarkController.text.toString(),
     /* "Orignal_Name":fileName,
      "ext":extension,
      "file": await MultipartFile.fromFile(filePath,
          filename: fileName),*/
    });
    for (String id in userssssList) {
      formData.fields.add(MapEntry("user_ids[]", id));
    }
    if(isAudio){
      formData.fields.add(MapEntry("Orignal_Name", fileName));
      formData.fields.add(MapEntry("ext", extension));
      formData.files.add(MapEntry("file", await MultipartFile.fromFile(filePath, filename: fileName)));
    }

    if(isImage){
      formData.fields.add(MapEntry("Orignal_Name_image", imageFileName));
      formData.fields.add(MapEntry("ext_image", imageExtension));
      formData.files.add(MapEntry("file_image", await MultipartFile.fromFile(imageFilePath, filename: imageFileName)));
    }
    String apiUrl="${baseUrl}assign-task-audio";
    print(apiUrl);
    Dio dio = Dio();
    dio.options.headers['Content-Type'] = 'multipart/form-data';
    try {
      var response = await dio.post(apiUrl, data: formData);
      print(response.data);
      Navigator.pop(context);
      var data=response.data;
      if (response.statusCode == 200) {


        int status=data['status'];
        String message=data['message'].toString();


        if(status==1 || status==200){
          Toast.show(message,
              duration: Toast.lengthLong,
              gravity: Toast.bottom,
              backgroundColor: Colors.green);
          _finishScreen();
        }else{
          Toast.show(message,
              duration: Toast.lengthLong,
              gravity: Toast.bottom,
              backgroundColor: Colors.red);
        }

      }else{
        Toast.show(data['message'].toString(),
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
            backgroundColor: Colors.red);
      }
    }on DioError catch(e){
      print(e);
      print(e.response.toString());
      Navigator.pop(context);
      Toast.show(e.toString(),
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }

  }
  _filterUserList(){
    for(int i=0;i<shiftsMainList.length;i++){
      String maninName=shiftsMainList[i]['name'].toString();
      if(maninName==selectedShift){
        selectedShiftId=shiftsMainList[i]['id'].toString();
        break;
      }
    }
    userList.clear();
    usersMainList.clear();
    selectedUser=null;
    selectedUserId="";
    _getUsersFromShift(context);
  }
  _selectUserId(){
    for(int i=0;i<usersMainList.length;i++){
      String maninName=usersMainList[i]['full_name'].toString();
      if(maninName==selectedUser){
        selectedUserId=usersMainList[i]['user_id'].toString();
        break;
      }
    }
  }
  _getUsersFromShift(BuildContext context) async {
    APIDialog.showAlertDialog(context, 'Please Wait...');
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
      "category_id": widget.categoryId,
      "shift_id": selectedShiftId,
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'get-users', data, context);
    Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      usersMainList.clear();
      usersMainList=responseJSON['data'];
      for(int i=0;i<usersMainList.length;i++){
        String name=usersMainList[i]['full_name'].toString();
        if(!userList.contains(name)){
          userList.add(name);
        }
      }
      setState(() {

      });

    }
    else {
      Toast.show(responseJSON["message"].toString(),
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      _finishScreen();
    }


  }




}