import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:vista/network/Utils.dart';
import 'package:vista/network/api_dialog.dart';
import 'package:vista/network/api_helper.dart';
import '../utils/app_theme.dart';
class EscalatedDetailsScreen extends StatefulWidget {
  final Map<String,dynamic> escalation;
  const EscalatedDetailsScreen({
    super.key,
    required this.escalation
  });

  @override
  State<EscalatedDetailsScreen> createState() =>
      _EscalationListScreenState();
}

class _EscalationListScreenState extends State<EscalatedDetailsScreen> {

  final GlobalKey<FormState> formKey =
  GlobalKey<FormState>();

  final TextEditingController remarksController =
  TextEditingController();

  final TextEditingController fromDateController =
  TextEditingController();

  final TextEditingController toDateController =
  TextEditingController();

  DateTime? fromDate;

  DateTime? toDate;

  bool loading = false;

  String? selectedReason;

  final List<Map<String, String>> reasonList = [

    {
      "id": "leave",
      "name": "Leave",
    },

    {
      "id": "missed",
      "name": "Missed",
    }

  ];

  var sRemeberToken="";
  var platform="";
  var baseUrl="";
  var userRole="";
  String EmpRoleId="";

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    final item = widget.escalation;

    return Scaffold(

      backgroundColor: const Color(0xffF4F6F8),

      appBar: AppBar(

        backgroundColor: AppTheme.at_details_header,

        elevation: 0,

        title: const Text(
          "Missed Checklist Details",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(16),

          child: SizedBox(

            height: 52,

            child: ElevatedButton(

              style: ElevatedButton.styleFrom(

                backgroundColor:
                AppTheme.themeColor,

                shape: RoundedRectangleBorder(

                  borderRadius:
                  BorderRadius.circular(12),

                ),

              ),

              onPressed: loading
                  ? null
                  : submit,

              child: loading

                  ? const SizedBox(

                  height: 24,

                  width: 24,

                  child:
                  CircularProgressIndicator(
                    color: Colors.white,
                  ))

                  : SizedBox(

                height: 55,

                width: double.infinity,

                child: ElevatedButton.icon(

                  icon: loading

                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child:
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )

                      : const Icon(Icons.check_circle,color: Colors.white,),

                  label: Text(

                    loading
                        ? "Submitting..."
                        : "Submit",

                    style:  TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),

                  style: ElevatedButton.styleFrom(

                    elevation: 0,

                    backgroundColor:
                    AppTheme.themeColor,

                    shape: RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(14),

                    ),

                  ),

                  onPressed:
                  loading ? null : submit,

                ),

              ),

            ),

          ),

        ),

      ),

      body: Form(

        key: formKey,

        child: ListView(

          padding: const EdgeInsets.all(16),

          children: [

            buildDetailsCard(item),

            const SizedBox(height: 24),

            const Text(

              "Type",

              style: TextStyle(

                fontWeight: FontWeight.bold,

                fontSize: 15,

              ),

            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(

              value: selectedReason,

              decoration: InputDecoration(

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(12),

                ),

              ),

              items: reasonList.map((e) {
                return DropdownMenuItem(

                  value: e["id"],

                  child: Text(e["name"]!),

                );
              }).toList(),

              validator: (value) {
                if (value == null) {
                  return "Please select type";
                }

                return null;
              },

              onChanged: (value) {
                setState(() {
                  selectedReason = value;

                  if (value != "leave") {
                    fromDate = null;

                    toDate = null;

                    fromDateController.clear();

                    toDateController.clear();
                  }
                });
              },

            ),

            const SizedBox(height: 20),

            AnimatedSwitcher(

              duration:
              const Duration(milliseconds: 300),

              child: selectedReason == "leave"

                  ? Column(

                children: [

                  buildDateField(

                    "From Date",

                    fromDateController,

                    true,

                  ),

                  const SizedBox(height: 16),

                  buildDateField(

                    "To Date",

                    toDateController,

                    false,

                  ),

                  const SizedBox(height: 20),

                ],

              )

                  : const SizedBox(),

            ),

            /*TextFormField(

              controller: remarksController,

              maxLines: 4,

              maxLength: 250,

              textCapitalization:
              TextCapitalization.sentences,

              decoration: InputDecoration(

                labelText: "Remarks",

                hintText:
                "Enter remarks (optional)",

                filled: true,

                fillColor: Colors.white,

                prefixIcon: const Icon(
                  Icons.edit_note,
                  color: AppTheme.themeColor,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),

              ),
            )*/

          ],

        ),

      ),

    );
  }
  Widget buildDetailsCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xffFFF7F1),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            Row(
              children: [

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Text(
                    item["task_name"] ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )

              ],
            ),

            const SizedBox(height: 20),

            info(Icons.person, "Store Manager",
                item["sm_name"] ?? ""),

            info(Icons.store, "Store",
                item["store_name"] ?? ""),
            info(Icons.schedule,
                "Checklist scheduled time",
                formatDateTime( item['start_date_time']??"")),

            info(Icons.schedule,
                "Alert At",
                formatDateTime( EmpRoleId=="20"?item['arl_alert_at']??"":item['tl_alert_at']??"")),
          ],
        ),
      ),
    );
  }
  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) {
      return "";
    }

    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('dd MMM, yyyy hh:mm a').format(parsedDate);
    } catch (e) {
      return dateTime;
    }
  }
  String formatDateTimeymd(DateTime? dateTime) {
    if (dateTime ==null) {
      return "";
    }

    try {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      return "";
    }
  }

  Widget info(

      IconData icon,

      String title,

      String value){
    return Padding(

      padding:
      const EdgeInsets.only(top:14),

      child: Row(

        children:[

          Icon(icon,color: AppTheme.themeColor),

          const SizedBox(width:12),

          Expanded(

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children:[

                Text(title),

                Text(

                  value,

                  style: const TextStyle(

                    fontWeight: FontWeight.bold,

                  ),

                )

              ],

            ),

          )

        ],

      ),

    );
  }

  Widget buildDateField(
      String label,
      TextEditingController controller,
      bool isFromDate,
      ) {
    return TextFormField(

      controller: controller,

      readOnly: true,

      validator: (value) {

        if (selectedReason == "leave") {

          if (value == null || value.isEmpty) {
            return "Please select $label";
          }
        }

        return null;
      },

      decoration: InputDecoration(

        labelText: label,

        filled: true,

        fillColor: Colors.white,

        suffixIcon: const Icon(
          Icons.calendar_month_rounded,
          color: AppTheme.themeColor,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.themeColor,
            width: 2,
          ),
        ),
      ),

      onTap: () {

        if (isFromDate) {
          _selectFromDate();
        } else {
          _selectToDate();
        }

      },
    );
  }

  Future<void> _selectFromDate() async {
    DateTime today = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? today,
      firstDate: today,
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {

      fromDate = picked;

      fromDateController.text =
          DateFormat("dd MMM yyyy").format(picked);

      if (toDate != null &&
          toDate!.isBefore(fromDate!)) {

        toDate = null;

        toDateController.clear();

      }

    });

  }
  Future<void> _selectToDate() async {

    if (fromDate == null) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(
            "Please select From Date first",
          ),

        ),

      );

      return;

    }

    DateTime? picked = await showDatePicker(

      context: context,

      initialDate: toDate ?? fromDate!,

      firstDate: fromDate!,

      lastDate: DateTime(2100),

    );

    if (picked == null) return;

    setState(() {

      toDate = picked;

      toDateController.text =
          DateFormat("dd MMM yyyy").format(picked);

    });

  }
  Future<void> submit() async {

    if (!formKey.currentState!.validate()) {

      return;

    }

    if (selectedReason == "leave") {

      if (toDate!.isBefore(fromDate!)) {

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(

            content: Text(
              "To Date cannot be before From Date",
            ),

          ),

        );

        return;

      }

    }

    setState(() {

      loading = true;

    });

    await Future.delayed(
        const Duration(seconds: 2));

    _updateTicket(context);

  }
  @override
  void initState() {
    super.initState();
    _getUserData();
  }
  _getUserData() async {
    sRemeberToken=await MyUtils.getSharedPreferences("token")??"";
    baseUrl=await MyUtils.getSharedPreferences("base_url")??"";
    EmpRoleId= await MyUtils.getSharedPreferences("emp_role_id")??"";
    print(sRemeberToken);
    print(baseUrl);
    if(Platform.isAndroid){
      platform="Android";
    }else if(Platform.isIOS){
      platform="iOS";
    }else{
      platform="Other";
    }
    setState(() {
    });
  }

  _updateTicket(BuildContext context) async {
   APIDialog.showAlertDialog(context, "Please wait...");
    var data = {
      "auth_key": sRemeberToken,
      "task_assigned_user_id":widget.escalation['id']?.toString()??"",
      "type":selectedReason,
      "reason":"",
      "from_date":formatDateTimeymd(fromDate),
      "to_date" : formatDateTimeymd(toDate)
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'checklist/escalation-action', data, context);
    var responseJSON = json.decode(response.body);
    if(Navigator.canPop(context)){
      Navigator.of(context).pop();
    }
    print(responseJSON);
    setState(() {
      loading=false;
    });
    if(responseJSON["status"]==1)
    {
      Toast.show(responseJSON["message"]?.toString()??"Updated Successfully",duration: Toast.lengthLong,backgroundColor: Colors.green);
      if(Navigator.canPop(context)){
        Navigator.of(context).pop();
      }

    } else {
      setState(() {
        
      });
      APIDialog.showErrorDialog(responseJSON["message"]?.toString()??"Something went wrong. Please try again", context);
    }


  }
}