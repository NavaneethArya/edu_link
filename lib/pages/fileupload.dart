import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UploadFile(),
    );
  }
}

class UploadFile extends StatefulWidget {
  const UploadFile({super.key});

  @override
  State<UploadFile> createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  File? file;
  String? url;
  var name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              height: 60,
              color: Colors.blue,
              onPressed: getFile,
              child: const Text(
                "Upload File",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc'],
    );

    if (result != null) {
      File c = File(result.files.single.path!);
      setState(() {
        file = c;
        name = result.names.first;
      });
      uploadFile();
    }
  }

  uploadFile() async {
    try {
      var storageReference = FirebaseStorage.instance
          .ref()
          .child("users")
          .child(name);
      UploadTask task = storageReference.putFile(file!);
      TaskSnapshot snapshot = await task;
      url = await snapshot.ref.getDownloadURL();
      print(url);
      if (url != null && file != null) {
        Fluttertoast.showToast(
          msg: 'Uploaded successfully',
          textColor: Colors.white,
          backgroundColor: Colors.green,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } on FirebaseException catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: e.message ?? 'Error occurred',
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  }
}
