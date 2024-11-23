import 'package:flutter/material.dart';

class Helprtmethods {
  showaAlertDialog(BuildContext context,
      {required void Function()? onPressed,
      required String tital,
      required String subtital}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tital,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(subtital, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: onPressed, child: Text('Yes'))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'No',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  String convertGoogleDriveLink(String driveLink) {
    // Regular expression to extract the File ID from a Google Drive link
    final RegExp regExp = RegExp(r'd/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(driveLink);

    if (match != null) {
      // Extract the file ID
      final fileId = match.group(1);
      // Return the direct link
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    } else {
      throw FormatException('Invalid Google Drive link');
    }
  }
}
