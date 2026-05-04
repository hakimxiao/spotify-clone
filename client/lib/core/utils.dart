import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message.toString())));

Future<File?> pickAudio() async {
  try {
    final filePickerRes = await FilePicker.pickFiles(type: FileType.audio);

    final path = filePickerRes?.files.first.path;
    if (path != null) {
      return File(path);
    }
    return null;
  } catch (err) {
    return null;
  }
}

Future<File?> pickImage() async {
  try {
    final filePickerRes = await FilePicker.pickFiles(type: FileType.image);

    final path = filePickerRes?.files.first.path;
    if (path != null) {
      return File(path);
    }
    return null;
  } catch (err) {
    return null;
  }
}
