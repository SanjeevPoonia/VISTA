
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:toast/toast.dart';
import 'package:vista/issue_admin/store_performance_screen.dart';
import 'package:vista/issue_admin/storewise_ticket_screen.dart';
import 'package:vista/network/loader.dart';
import 'package:vista/utils/app_theme.dart';
import 'package:vista/views/notification_screen.dart';
import '../network/Utils.dart';
import '../network/api_helper.dart';
import 'list_offissues_page.dart';
import 'dart:io';

class IssueAdminDashboard extends StatefulWidget{
  _issueAdminState createState()=>_issueAdminState();
}
class _issueAdminState extends State<IssueAdminDashboard>{
  var sMobileNumber="";
  var sPersonName="";
  var sUserLanguage="";
  var sRemeberToken="";
  var sUserId="";
  var platform="";
  var baseUrl="";
  var userRole="";

  Map<String,int> pieChartData={
    "Open Issues": 0,
    "Resolved Issues": 0,
    "In Progress Issue": 0,
    "Rejected Issues": 0,
  };

  final Map<String, Color> pieissueColors = const {
    "Open Issues": Color(0xFF4A90E2),     // Muted Blue
    "Resolved Issues": Color(0xFF50B873), // Elegant Green
    "In Progress Issue": Color(0xFFF5A623), // Warm Amber
    "Rejected Issues": Color(0xFFD64545), // Soft Red
  };

  Map<String, int> peratoIssueCounts ={
    "Open": 0,
    "Resolved": 0,
    "WIP": 0,
    "Rejected": 0,
  };

    Map<String, int> issueCounts ={
     "Open Issues": 0,
     "Resolved Issues": 0,
     "In Progress\nIssue": 0,
     "Rejected Issues": 0,
   };
  final Map<String, IconData> issueIcons = const {
    "Open Issues": Icons.report_problem,
    "Resolved Issues": Icons.check_circle,
    "In Progress\nIssue": Icons.timelapse,
    "Rejected Issues": Icons.cancel,
  };
  final Map<String, Color> issueColors = const {
    "Open Issues": Color(0xFF4A90E2),     // Muted Blue
    "Resolved Issues": Color(0xFF50B873), // Elegant Green
    "In Progress\nIssue": Color(0xFFF5A623), // Warm Amber
    "Rejected Issues": Color(0xFFD64545), // Soft Red
  };
   List<Map<String, dynamic>> monthlyData =  [];

  bool isTicketLoading=false;
  bool isStoreLoading=false;
  bool isParetoLoading=false;
  final List<Map<String, dynamic>> storeData = [];

  final List<Map<String,dynamic>> paretoChartData=[];

  late List<MonthFilter> filters;
  MonthFilter? selectedFilter;
  String selectedStartDate="";
  String selectedEndDate="";
  String reportWebUrl="";
  String inTatResolved="0";
  String outTatResolved="0";



  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Light professional background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Color(0xFF4A90E2), size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFD64545), size: 26),
            onPressed: _showAlertDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // ------------------ User Card ------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF4A90E2),
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Welcome Back,",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(sPersonName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(userRole,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold,color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ------------------ Month Filter ------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Select Month Filter",
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Spacer(),
                  _buildMonthFilter()
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ------------------ Count Cards ------------------
            isTicketLoading?Center(child: Loader(),):
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.75,
              children: issueCounts.entries.map((entry) {
                final color = issueColors[entry.key] ?? Colors.grey;
                final icon = issueIcons[entry.key] ?? Icons.error;

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListOfIssuesPage(title: entry.key),
                      ),
                    ).then((value) => _getUserData());
                  },
                  child: Container(

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.85), color],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(2, 3))
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(padding: EdgeInsets.only(left: 10),child:  Icon(icon, color: Colors.white, size: 34),),
                          SizedBox(width: 16,),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.value.toString(),
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              Text(entry.key,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              entry.key=="Resolved Issues"?
                              Text("TAT  IN:$inTatResolved | OUT:$outTatResolved",
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)):Container(),

                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // ---------------Report Card--------------------


            isTicketLoading?Center(child: Loader(),):
            reportWebUrl.isNotEmpty?
            _buildReportCard("assets/stats_anim.json", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoreReportScreen(reportUrl: reportWebUrl,),
                ),
              );
            }):Container(),
            const SizedBox(height: 20),
            // ------------------ Pie Chart ------------------
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Issue Distribution",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 38,
                          sections: issueCounts.entries.map((entry) {
                            final color = issueColors[entry.key] ?? Colors.grey;
                            return PieChartSectionData(
                              value: entry.value.toDouble(),
                              title: "${entry.value}",
                              color: color,
                              radius: 58,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: pieChartData.keys.map((key) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 6,
                              backgroundColor: pieissueColors[key],
                            ),
                            const SizedBox(width: 6),
                            Text(key, style: const TextStyle(fontSize: 14)),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ------------------ Issues Pareto Data --------------------
            isTicketLoading?Center(child: Loader(),):
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Issues Pareto analysis",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 400,
                      child:  _buildPeratoChart(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ------------------ Store Tabular Data --------------------
            isStoreLoading? Center(child: Loader(),):
            buildStoreSummaryTable(context),
            const SizedBox(height: 20),
            // ------------------ Bar Chart ------------------
            isTicketLoading?Center(child: Loader(),):
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Monthly Issues Trend",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value < 0 || value >= monthlyData.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(
                                    monthlyData[value.toInt()]["month"],
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          barGroups: monthlyData
                              .asMap()
                              .entries
                              .map((e) => BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value["count"].toDouble(),
                                color: const Color(0xFF4A90E2),
                                width: 16,
                                borderRadius: BorderRadius.circular(6),
                              )
                            ],
                          ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),


            const SizedBox(height: 20),


          ],
        ),
      ),
    );
  }
  _logOut(BuildContext context)  {
    MyUtils.logoutUser(context);
  }

  @override
  void initState() {
    super.initState();
    filters = getMonthFilters();
    selectedFilter = filters.first;
    selectedStartDate = formatMonthDate(selectedFilter!.startDate);
    selectedEndDate = formatMonthDate(selectedFilter!.endDate);
    print("Start Date: $selectedStartDate &&& End Date: $selectedEndDate");
    _getUserData();
  }
  _showAlertDialog(){
    showDialog(context: context, builder: (ctx)=> AlertDialog(
      title: const Text("Logout",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 18),),
      content: const Text("Are you sure you want to Logout ?",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 16,color: Colors.black),),
      actions: <Widget>[
        TextButton(
            onPressed: (){
              Navigator.of(ctx).pop();
              _logOut(context);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppTheme.themeColor,
              ),
              height: 45,
              padding: const EdgeInsets.all(10),
              child: const Center(child: Text("Logout",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.white),),),
            )
        ),
        TextButton(
            onPressed: (){
              Navigator.of(ctx).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppTheme.greyColor,
              ),
              height: 45,
              padding: const EdgeInsets.all(10),
              child: const Center(child: Text("Cancel",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.white),),),
            )
        )
      ],
    ));
  }
  _getUserData() async {
    sMobileNumber=await MyUtils.getSharedPreferences("mobile_no")??"";
    sPersonName=await MyUtils.getSharedPreferences("name")??"";
    sRemeberToken=await MyUtils.getSharedPreferences("token")??"";
    sUserId=await MyUtils.getSharedPreferences("user_id")??"";
    sUserLanguage=await MyUtils.getSharedPreferences("language")??"";
    baseUrl=await MyUtils.getSharedPreferences("base_url")??"";

    String uRole=await MyUtils.getSharedPreferences("user_role")??"";
    userRole=_getUserRoleName(uRole);

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
    _getDataFromSerVer();
  }
  String _getUserRoleName(String uRole){
    if(uRole=="state_head"){
      return "State Head";
    }else if(uRole=="circle_head" || uRole=="circle-head"){
      return "Circle Head";
    }else if(uRole=="city_head"){
      return "City Head";
    }else if(uRole=="area_manager"){
      return "Area Manager";
    }else if(uRole=="store_manager"){
      return "Store Manager";
    }else if(uRole=="receptionist"){
      return "Receptionist";
    }else if(uRole=="project_head"){
      return "Project Head";
    }else{
        return uRole;
      }
  }
  _getDataFromSerVer(){
    _getTickets(context);
    _getParetoData(context);
    _getStoreWiseData(context);
  }
  _getStoreWiseData(BuildContext context) async {
    setState(() {
      isStoreLoading=true;
    });
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
      "start_date":selectedStartDate,
      "end_date":selectedEndDate
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'get-store-tickets', data, context);
    //Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      storeData.clear();
      List<dynamic> tempList=responseJSON['data']??[];
      for(int i=0;i<tempList.length;i++){
        String id=tempList[i]['id']?.toString()??"";
        String store_name=tempList[i]['store_name']?.toString()??"";
        String ticket_count=tempList[i]['all_ticket_count']?.toString()??"0";
        String resolved=tempList[i]['completed_ticket_count']?.toString()??"0";
        String pending=tempList[i]['pending_ticket_count']?.toString()??"0";
        String inprogress=tempList[i]['work_in_progress_count']?.toString()??"0";
        String rejected=tempList[i]['rejected_ticket_count']?.toString()??"0";
        Map<String, dynamic> map= {
                                    "id": id,
                                    "store_name": store_name,
                                    "ticket_count": ticket_count,
                                    "resolved_count": resolved,
                                    "work_in_progress": inprogress,
                                    "pending_count": pending,
                                    "rejected_count": rejected
                                  };
        storeData.add(map);

      }



      setState(() {
        isStoreLoading=false;
      });

    }else if(responseJSON["status"]==3){

      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      setState(() {
        isStoreLoading=false;
      });

      MyUtils.logoutUser(context);

    } else {
      setState(() {
        isStoreLoading=false;
      });
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }


  }
  _getTickets(BuildContext context) async {
    setState(() {
      isTicketLoading=true;
    });
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
      "start_date":selectedStartDate,
      "end_date":selectedEndDate
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'tickets_dashboard', data, context);
    //Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {


      reportWebUrl = responseJSON['data']['report_url']?.toString()??"";
      int openIssues=responseJSON['data']['pending_issues']??0;
      int resolvedIssues=responseJSON['data']['resolved_issues']??0;
      int rejected_issues=responseJSON['data']['rejected_issues']??0;
      int work_in_progress=responseJSON['data']['work_in_progress_issues']??0;

      inTatResolved=responseJSON['data']['inside_tat']?.toString()??"0";
      outTatResolved=responseJSON['data']['outside_tat']?.toString()??"0";

      if(inTatResolved=="0" && outTatResolved=="0"){
        inTatResolved=resolvedIssues.toString();
      }



      issueCounts['Open Issues']=openIssues;
      issueCounts['Resolved Issues']=resolvedIssues;
      issueCounts['In Progress\nIssue']=work_in_progress;
      issueCounts['Rejected Issues']=rejected_issues;

      peratoIssueCounts['Open']=openIssues;
      peratoIssueCounts['Resolved']=resolvedIssues;
      peratoIssueCounts['WIP']=work_in_progress;
      peratoIssueCounts['Rejected']=rejected_issues;


      List<dynamic> monthDay=responseJSON['data']['monthly_trend']??[];
      monthlyData.clear();
      for(int i=0;i<monthDay.length;i++){
        String monthName=monthDay[i]['month']?.toString()??"2025-08";
        int totalCount = monthDay[i]['total']??0;
        String mnConverted=_formatMonth(monthName);
        Map<String,dynamic> map={
          "month":mnConverted,
          "count":totalCount
        };
        monthlyData.add(map);
      }

      setState(() {
        isTicketLoading=false;
      });

    }else if(responseJSON["status"]==3){

      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      setState(() {
        isTicketLoading=false;
      });

      MyUtils.logoutUser(context);

    } else {
      setState(() {
        isTicketLoading=false;
      });
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }


  }
  Widget buildStoreSummaryTable(BuildContext context) {
    if (storeData.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store_mall_directory_outlined,
                  size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text("No store data available",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54)),
              SizedBox(height: 6),
              Text("Please check back later or refresh the page.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Store Issue Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
                border: TableBorder(
                  horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                columns: const [
                  DataColumn(label: Text("Store")),
                  DataColumn(label: Text("Total")),
                  DataColumn(label: Text("Resolved")),
                  DataColumn(label: Text("In Progress")),
                  DataColumn(label: Text("Pending")),
                  DataColumn(label: Text("Rejected")),
                ],
                rows: storeData.map((store) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(store["store_name"],
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoreTicketsPage(storeId: store["id"],storeName: store["store_name"], ),
                            ),
                          );
                        },
                      ),
                      DataCell(Text(store["ticket_count"].toString(),
                          style: const TextStyle(color: Colors.black87))),
                      DataCell(Text(store["resolved_count"].toString(),
                          style: const TextStyle(color: Color(0xFF50B873)))),
                      DataCell(Text(store["work_in_progress"].toString(),
                          style: const TextStyle(color: Color(0xFFF5A623)))),
                      DataCell(Text(store["pending_count"].toString(),
                          style: const TextStyle(color: Color(0xFF4A90E2)))),
                      DataCell(Text(store["rejected_count"].toString(),
                          style: const TextStyle(color: Color(0xFFD64545)))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _formatMonth(String input){
    try{
      DateTime date = DateTime.parse("$input-01"); // day add किया
      String formatted = DateFormat("MMM").format(date) + DateFormat("yy").format(date);
      return formatted;
    }catch(e){
      return "";
    }
  }
  Widget _buildPeratoChart(){
    var data = paretoChartData
        .map((e) => _IssueData(e["issue"], e["totalCount"]))
        .toList();
    data.sort((a, b) => b.count.compareTo(a.count));
    int total = data.fold(0, (sum, item) => sum + item.count);
    // Pareto calculation
    double cumulative = 0;
    List<_ParetoData> paretoData = [];
    for (var item in data) {
      cumulative += item.count;
      double percent = total == 0 ? 0 : (cumulative / total) * 100;
      paretoData.add(_ParetoData(item.category, item.count, percent));
    }
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelPlacement: LabelPlacement.onTicks,
        interval: 1,
        labelRotation: -90,  // long names के लिए
      ),
      primaryYAxis: NumericAxis(title: AxisTitle(text: 'Issue Count')),
      axes:  <ChartAxis>[
        NumericAxis(
            name: 'percentage',
            opposedPosition: true,
            interval: 20,
            minimum: 0,
            maximum: 100,
            title: AxisTitle(text: 'Cumulative %')),
      ],
      series:  <CartesianSeries<_ParetoData, String>>[
      ColumnSeries<_ParetoData, String>(
        dataSource: paretoData,
        xValueMapper: (_ParetoData data, _) => data.category,
        yValueMapper: (_ParetoData data, _) => data.count,
        name: 'Issues',
        pointColorMapper: (data, _) {
          if (data.count >= 5) {
            return const Color(0xFFD64545);
          } else if (data.count >= 2) {
            return const Color(0xFFF5A623);
          } else {
            return const Color(0xFF4A90E2); // कम issues वाले हरे
          }
        },
      ),
      LineSeries<_ParetoData, String>(
        dataSource: paretoData,
        xValueMapper: (_ParetoData data, _) => data.category,
        yValueMapper: (_ParetoData data, _) => data.percent,
        yAxisName: 'percentage',
        markerSettings: MarkerSettings(isVisible: true),
        name: 'Cumulative %',
      )
    ],
    );
  }
  Widget _buildMonthFilter(){
    return DropdownButton<MonthFilter>(
      value: selectedFilter,
      items: filters.map((filter) {
        return DropdownMenuItem<MonthFilter>(
          value: filter,
          child: Text(filter.label),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedFilter = value;
        });
        selectedStartDate = formatMonthDate(selectedFilter!.startDate);
        selectedEndDate = formatMonthDate(selectedFilter!.endDate);
        _getDataFromSerVer();
      },
    );
  }
  _getParetoData(BuildContext context) async {
    setState(() {
      isParetoLoading=true;
    });
    var data = {
      "auth_key": sRemeberToken,
      "user_id": sUserId,
      "start_date":selectedStartDate,
      "end_date":selectedEndDate
    };
    print(data);
    ApiBaseHelper helper = ApiBaseHelper();
    var response = await helper.postAPI(baseUrl,'issue-wise-pareto', data, context);
    //Navigator.pop(context);
    var responseJSON = json.decode(response.body);
    print(responseJSON);
    if(responseJSON["status"]==1)
    {
      paretoChartData.clear();
      List<dynamic> tempList=responseJSON['data']??[];
      for(int i=0;i<tempList.length;i++){
        String id=tempList[i]['id']?.toString()??"";
        String issue=tempList[i]['issue']?.toString()??"";
        int totalCount=tempList[i]['total_count']??0;
        int pendingIssue=tempList[i]['pendingIssues']??0;
        int resolvedIssue=tempList[i]['resolvedIssues']??0;
        int rejectedIssues=tempList[i]['rejectedIssues']??0;
        int totalClosed=resolvedIssue+rejectedIssues;


        Map<String, dynamic> map= {
          "id": id,
          "issue": issue,
          "totalCount": totalCount,
          "pendingIssue": pendingIssue,
          "totalClosed": totalClosed,
        };
        paretoChartData.add(map);

      }


      print(paretoChartData);


      setState(() {
        isParetoLoading=false;
      });

    }else if(responseJSON["status"]==3){

      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
      setState(() {
        isParetoLoading=false;
      });

      MyUtils.logoutUser(context);

    } else {
      setState(() {
        isParetoLoading=false;
      });
      Toast.show(responseJSON["message"],
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }


  }
  List<MonthFilter> getMonthFilters() {
    final now = DateTime.now();

    // Current month start
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final mtd = MonthFilter(
      "${_getMonthName(currentMonthStart.month)}-${currentMonthStart.year}",
      currentMonthStart,
      now,
    );

    // Last month
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);
    final lastMonth = MonthFilter(
      "${_getMonthName(lastMonthStart.month)}-${lastMonthStart.year}",
      lastMonthStart,
      lastMonthEnd,
    );

    // Second last month
    final secondLastMonthStart = DateTime(now.year, now.month - 2, 1);
    final secondLastMonthEnd = DateTime(now.year, now.month - 1, 0);
    final secondLastMonth = MonthFilter(
      "${_getMonthName(secondLastMonthStart.month)}-${secondLastMonthStart.year}",
      secondLastMonthStart,
      secondLastMonthEnd,
    );

    return [mtd, lastMonth, secondLastMonth];
  }
  String _getMonthName(int month) {
    const monthNames = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return monthNames[month - 1];
  }
  String formatMonthDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  Widget _buildReportCard(String svg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width) - 22,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 6, offset: Offset(2, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Performance\nReport", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: AppTheme.orangeColor)),
            Spacer(),
            Lottie.asset(
                svg,
                repeat: true,
                fit: BoxFit.contain,
                width: 150,
                height: 150
            )
          ],
        ),
      ),
    );
  }

}
class _IssueData {
  final String category;
  final int count;
  _IssueData(this.category, this.count);
}

class _ParetoData {
  final String category;
  final int count;
  final double percent;
  _ParetoData(this.category, this.count, this.percent);
}

class MonthFilter {
  final String label;
  final DateTime startDate;
  final DateTime endDate;

  MonthFilter(this.label, this.startDate, this.endDate);

  @override
  String toString() => label;
}

