import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vista/network/Utils.dart';
import 'package:vista/network/api_helper.dart';

class AppVersionChecker {

  static Future<bool> checkForUpdate(BuildContext context) async {
    try {

      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      String currentVersion = packageInfo.version;
      int currentBuildNumber =
          int.tryParse(packageInfo.buildNumber) ?? 0;

      String platform = Platform.isAndroid ? "android" : "ios";

      var data = {
        "platform": platform,
      };
     String baseUrl=await MyUtils.getSharedPreferences("base_url")??"";

      ApiBaseHelper helper = ApiBaseHelper();

      var response = await helper.postAPI(
        baseUrl,
        'app-version',
        data,
        context,
      );

      var responseJSON = json.decode(response.body);

      if (responseJSON['status'] != 1) return false;

      final apiData = responseJSON['data'];

      String latestVersion =
      apiData['version'].toString();

      int latestBuildNumber =
          int.tryParse(apiData['version_code'].toString()) ?? 0;

      String updateNote =
      apiData['update_note'].toString();

      bool forceUpdate =
          apiData['force_update'].toString() == "1";

      bool updateAvailable =
          latestBuildNumber > currentBuildNumber;

      if (updateAvailable && context.mounted) {
        _showUpdateDialog(
          context,
          latestVersion,
          updateNote,
          forceUpdate,
        );
        return true;
      }
      return false;

    } catch (e) {
      debugPrint("Version Check Error : $e");
      return false;
    }
  }

  static Future<void> _launchStore() async {

    final Uri url = Platform.isAndroid
        ? Uri.parse(
        "https://play.google.com/store/apps/details?id=com.qdegrees.vista.vista")
        : Uri.parse(
        "https://apps.apple.com/us/app/vista-store-audit/id6773718506");

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  static void _showUpdateDialog(
      BuildContext context,
      String version,
      String note,
      bool forceUpdate,
      ) {

    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (context) {

        return PopScope(
          canPop: !forceUpdate,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.system_update_alt_rounded,
                      size: 40,
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Update Available",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Version $version is now available.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      note,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [

                      if (!forceUpdate)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Later"),
                          ),
                        ),

                      if (!forceUpdate)
                        const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _launchStore,
                          child: const Text(
                            "Update Now",
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}