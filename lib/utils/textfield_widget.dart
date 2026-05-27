import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';

class TextFieldWidget extends StatelessWidget
{
  final String title;
  final String hintText;
  var controller;
  final String? Function(String?)? validator;
  TextFieldWidget(this.title,this.hintText,{this.validator,this.controller});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                //color: Colors.black
                color: Color(0xFF9D9CA0)
            )),
        const SizedBox(height: 7),
        Container(
          // height: 56,

          child: TextFormField(
            validator: validator!=null?validator:null,
            controller: controller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(0xFFE4E4E4),

                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(0xFFE4E4E4),

                ),
              ),


              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(
                  width: 1,
                  color: AppTheme.themeColor,

                ),
              ),
              filled: true,
              hintStyle: const TextStyle(color: Color(0xFF9D9CA0),fontSize: 13),
              hintText: hintText,
              fillColor: Colors.white,
            ),
          ),
        ),



      ],
    );
  }

}

class TextFieldWidgetMultiline extends StatelessWidget
{
  final String title;
  final String hintText;
  var controller;
  final String? Function(String?)? validator;
  TextFieldWidgetMultiline(this.title,this.hintText,{this.validator,this.controller});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                //color: Colors.black
                color: Color(0xFF9D9CA0)
            )),
        const SizedBox(height: 7),
        Container(
          // height: 56,

          child: TextFormField(
            validator: validator!=null?validator:null,
            controller: controller,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(0xFFE4E4E4),

                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(0xFFE4E4E4),

                ),
              ),


              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(
                  width: 1,
                  color: AppTheme.themeColor,

                ),
              ),
              filled: true,
              hintStyle: const TextStyle(color: Color(0xFF9D9CA0),fontSize: 13),
              hintText: hintText,
              fillColor: Colors.white,
            ),
            maxLines: null,
            minLines: 3,
          ),
        ),



      ],
    );
  }

}