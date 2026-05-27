import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';


class _customAppBar{

  PreferredSizeWidget _appBar(String pageTitle, BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_outlined,
            color: AppTheme.themeColor, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: AppTheme.at_details_header,
      title: Text(
        pageTitle,
        style: const TextStyle(
            fontSize: 18.5, fontWeight: FontWeight.bold, color:AppTheme.themeColor),
      ),
      centerTitle: true,
    );
  }
}

