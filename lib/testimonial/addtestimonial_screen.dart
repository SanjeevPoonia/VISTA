import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:vista/network/Utils.dart';
import 'package:vista/utils/app_theme.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../network/api_dialog.dart';
import '../vista/MarkAttendanceScreen.dart';
import 'package:pro_image_editor/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import 'package:pro_image_editor/features/main_editor/main_editor.dart';

class AddTestimonial_Screen extends StatefulWidget{
  _addTestimonial createState()=>_addTestimonial();
}
class _addTestimonial extends State<AddTestimonial_Screen> {
  //---------------------------------------------------------
  // Controllers
  //---------------------------------------------------------

  final _formKey = GlobalKey<FormState>();

  final TextEditingController customerController =
  TextEditingController();

  final TextEditingController mobileController =
  TextEditingController();

  final TextEditingController remarkController =
  TextEditingController();
  final TextEditingController reasonController =
  TextEditingController();

  //---------------------------------------------------------
  // Variables
  //---------------------------------------------------------

  String selectedReason = "";

  bool isLoading = false;

  File? capturedImage;

  File? capturedVideo;

  //---------------------------------------------------------
  // Reason List
  //---------------------------------------------------------

  final List<String> reasonList = [

    "Product Quality",

    "Excellent Service",

    "Happy Customer",

    "Customer Satisfaction",

    "Suggestion",

    "Other"

  ];

  XFile? capturedImageFile;

  XFile? videoFile;

  String imageName = "";

  String videoName = "";


  //---------------------------------------------------------
  @override
  //---------------------------------------------------------

  Widget build(BuildContext context) {
    ToastContext().init(context);

    return Scaffold(

      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(

        elevation: 0,

        centerTitle: true,

        backgroundColor: AppTheme.at_details_header,

        title: const Text(

          "Customer Testimonial",

          style: TextStyle(

            color: Colors.black,

            fontWeight: FontWeight.bold,

          ),

        ),

      ),

      body: SafeArea(

        child: Form(

          key: _formKey,

          child: ListView(

            padding: const EdgeInsets.all(18),

            children: [

              _customerInformationCard(),

              const SizedBox(height: 18),

              _mediaCard(),

              const SizedBox(height: 25),

              SizedBox(

                height: 55,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: AppTheme.orangeColor,

                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(12),

                    ),

                  ),

                  onPressed: () {
                    _validateForm();
                  },

                  child: const Text(

                    "SUBMIT TESTIMONIAL",

                    style: TextStyle(

                      fontSize: 16,

                      fontWeight: FontWeight.bold,

                      color: Colors.white,

                    ),

                  ),

                ),

              ),

              const SizedBox(height: 20)

            ],

          ),

        ),

      ),

    );
  }
  Widget _customerInformationCard() {

    return Card(

      elevation: 3,

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(18),

      ),

      child: Padding(

        padding: const EdgeInsets.all(18),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(

              "Customer Information",

              style: TextStyle(

                fontSize: 18,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 20),

            _buildTextField(

              controller: customerController,

              label: "Customer Name",

              icon: Icons.person,

              keyboard: TextInputType.name,

            ),

            const SizedBox(height: 18),

            _buildTextField(

              controller: mobileController,

              label: "Mobile Number",

              icon: Icons.phone,

              keyboard: TextInputType.phone,

              inputFormatters: [

                FilteringTextInputFormatter.digitsOnly,

                LengthLimitingTextInputFormatter(10),

              ],

            ),

            const SizedBox(height: 18),

            //_reasonDropdown(),
            _reasonField(),

            const SizedBox(height: 18),

            _remarkField(),

          ],

        ),

      ),

    );

  }
  Widget _reasonDropdown() {

    return DropdownButtonFormField<String>(

      value: selectedReason.isEmpty ? null : selectedReason,

      decoration: InputDecoration(

        labelText: "Reason",

        prefixIcon: const Icon(Icons.list_alt),

        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(12),

        ),

      ),

      items: reasonList

          .map(

            (e) => DropdownMenuItem(

          value: e,

          child: Text(e),

        ),

      )

          .toList(),

      onChanged: (value) {

        selectedReason = value!;

        setState(() {});

      },

      validator: (value) {

        if (value == null) {

          return "Please select reason";

        }

        return null;

      },

    );

  }
  Widget _reasonField() {

    return TextFormField(

      controller: reasonController,

      maxLines: 2,

      decoration: InputDecoration(

        labelText: "Reason",

        alignLabelWithHint: true,

        prefixIcon: const Padding(

          padding: EdgeInsets.only(bottom: 20),

          child: Icon(Icons.list_alt),

        ),

        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(12),

        ),

      ),

      validator: (value) {

        if (value!.trim().isEmpty) {

          return "Please enter Reason";

        }

        return null;

      },

    );

  }
  Widget _remarkField() {

    return TextFormField(

      controller: remarkController,

      maxLines: 5,

      decoration: InputDecoration(

        labelText: "Other Remark / Description",

        alignLabelWithHint: true,

        prefixIcon: const Padding(

          padding: EdgeInsets.only(bottom: 80),

          child: Icon(Icons.description),

        ),

        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(12),

        ),

      ),

      validator: (value) {

        if (value!.trim().isEmpty) {

          return "Please enter description";

        }

        return null;

      },

    );

  }
  Widget _mediaCard() {

    return Card(

      elevation: 3,

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(18),

      ),

      child: Padding(

        padding: const EdgeInsets.all(18),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(

              "Media Attachment",

              style: TextStyle(

                fontSize: 18,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 20),

            Row(

              children: [

                Expanded(

                  child: _mediaButton(

                    title: "Capture Image",

                    icon: Icons.camera_alt,

                    color: Colors.blue,

                    onTap: () {

                      // Part 2

                    },

                  ),

                ),

                const SizedBox(width: 15),

                Expanded(

                  child: _mediaButton(

                    title: "Record Video",

                    icon: Icons.videocam,

                    color: Colors.red,

                    onTap: () {

                      // Part 2

                    },

                  ),

                ),

              ],

            ),

            const SizedBox(height: 25),

            if (capturedImage != null)

              _imagePreview(),

            if (capturedVideo != null)

              _videoPreview(),

          ],

        ),

      ),

    );

  }
  Widget _mediaButton({

    required String title,

    required IconData icon,

    required Color color,

    required VoidCallback onTap,

  }) {
    return InkWell(

      onTap: onTap,

      child: Container(

        height: 130,

        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(15),

          color: color.withOpacity(.08),

          border: Border.all(

            color: color.withOpacity(.3),

          ),

        ),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(

              icon,

              size: 42,

              color: color,

            ),

            const SizedBox(height: 12),

            Text(

              title,

              textAlign: TextAlign.center,

              style: const TextStyle(

                fontWeight: FontWeight.w600,

              ),

            ),

          ],

        ),

      ),

    );
  }
  Widget _imagePreview() {

    return Container(

      margin:

      const EdgeInsets.only(top: 15),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:

        BorderRadius.circular(15),

        border: Border.all(

          color: Colors.grey.shade300,

        ),

      ),

      child: Column(

        children: [

          ClipRRect(

            borderRadius:

            const BorderRadius.only(

              topLeft:

              Radius.circular(15),

              topRight:

              Radius.circular(15),

            ),

            child: Image.file(

              capturedImage!,

              width: double.infinity,

              height: 180,

              fit: BoxFit.cover,

            ),

          ),

          Padding(

            padding:

            const EdgeInsets.all(12),

            child: Row(

              children: [

                const Icon(

                  Icons.check_circle,

                  color: Colors.green,

                ),

                const SizedBox(width: 10),

                const Expanded(

                  child: Text(

                    "Image Captured Successfully",

                    style: TextStyle(

                      fontWeight:

                      FontWeight.w600,

                    ),

                  ),

                ),

                IconButton(

                  icon: const Icon(

                    Icons.delete,

                    color: Colors.red,

                  ),

                  onPressed: () {

                    capturedImage = null;

                    imageName = "";

                    setState(() {});

                  },

                )

              ],

            ),

          )

        ],

      ),

    );

  }
  Widget _videoPreview() {

    return Container(

      margin:

      const EdgeInsets.only(top: 15),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:

        BorderRadius.circular(15),

        border: Border.all(

          color: Colors.grey.shade300,

        ),

      ),

      child: ListTile(

        leading: CircleAvatar(

          backgroundColor:

          Colors.red.shade100,

          child: const Icon(

            Icons.videocam,

            color: Colors.red,

          ),

        ),

        title: const Text(

          "Video Recorded",

          style: TextStyle(

            fontWeight: FontWeight.bold,

          ),

        ),

        subtitle: Text(videoName),

        trailing: IconButton(

          icon: const Icon(

            Icons.delete,

            color: Colors.red,

          ),

          onPressed: () {

            capturedVideo = null;

            videoName = "";

            setState(() {});

          },

        ),

      ),

    );

  }
  Widget _buildTextField({

    required TextEditingController controller,

    required String label,

    required IconData icon,

    required TextInputType keyboard,

    List<TextInputFormatter>? inputFormatters,

  }) {
    return TextFormField(

      controller: controller,

      keyboardType: keyboard,

      inputFormatters: inputFormatters,

      decoration: InputDecoration(

        labelText: label,

        prefixIcon: Icon(icon),

        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(12),

        ),

      ),

      validator: (value) {

        if (value == null || value.trim().isEmpty) {

          return "Required";

        }

        return null;

      },

    );
  }
  void _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (capturedImage == null) {
      Toast.show("Please capture image", duration: Toast.lengthLong,
          backgroundColor: Colors.red);

      return;
    }

    if (capturedVideo == null) {
      Toast.show("Please record video", duration: Toast.lengthLong,
          backgroundColor: Colors.red);


      // API in Part 3

    }
  }
  Future<void> _prepareCamera() async {

    final imageData = await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => MarkAttendanceScreen(0),

      ),

    );

    if (imageData != null) {

      capturedImageFile = imageData;

      capturedImage = File(capturedImageFile!.path);

      await _openImageEditor(capturedImage!);

    } else {

      APIDialog.showErrorDialog(

        "Unable to capture image. Please try again.",

        context,

      );

    }

  }
  Future<void> _openImageEditor(
      File imageFile,
      ) async {
    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (editorContext) =>

            ProImageEditor.file(

              imageFile,

              callbacks: ProImageEditorCallbacks(

                onImageEditingComplete:

                    (Uint8List bytes) async {

                  final tempDir =
                  await getTemporaryDirectory();

                  final editedFile = File(

                    "${tempDir.path}/customer_${DateTime.now().millisecondsSinceEpoch}.jpg",

                  );

                  await editedFile.writeAsBytes(bytes);

                  capturedImage = editedFile;

                  imageName =

                      editedFile.path.split("/").last;

                  Navigator.pop(editorContext);

                  await Future.delayed(

                    const Duration(milliseconds: 200),

                  );

                  if (mounted) {

                    setState(() {});

                  }

                },

              ),

            ),

      ),

    );
  }
  Future<void> _recordVideo() async {

    videoFile =

    await ImagePicker().pickVideo(

      source: ImageSource.camera,

      preferredCameraDevice:

      CameraDevice.rear,

      maxDuration:

      const Duration(seconds: 60),

    );

    if (videoFile != null) {

      capturedVideo =

          File(videoFile!.path);

      videoName =

          capturedVideo!.path.split("/").last;

      setState(() {});

    } else {

      APIDialog.showErrorDialog(

        "Unable to record video.",

        context,

      );

    }

  }
}