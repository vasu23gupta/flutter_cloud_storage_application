import 'dart:io';

import 'package:internship_application/models/customUser.dart';
import 'package:internship_application/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:internship_application/shared/loading.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  final CustomUser user;
  Home({this.user});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Reference> list;
  int n;
  bool loading = true;

  Future<void> updateList() async {
    var temp =
        await FirebaseStorage.instance.ref().child(widget.user.uid).listAll();
    setState(() {
      list = temp.items;
      for (var item in list) {
        print(item.name);
      }
      n = list.length;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    updateList();
  }

  final AuthService _auth = AuthService();
  PlatformFile pFile;
  var fsfs = FirebaseStorage.instance.ref().listAll().then((value) {
    for (var item in value.items) {
      print(item.name);
    }
  });
  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Container(
            child: Scaffold(
              body: ListView.builder(
                itemCount: n,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(list[index].name),
                      onTap: () async {
                        String url = await FirebaseStorage.instance
                            .ref()
                            .child(widget.user.uid)
                            .child(list[index].name)
                            .getDownloadURL();
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                  );
                },
              ),
              appBar: AppBar(
                //rotate screen to see uid
                title: Text(widget.user.displayName.toString()),
                elevation: 0.0,
                actions: <Widget>[
                  FlatButton.icon(
                    icon: Icon(Icons.person),
                    label: Text('logout'),
                    onPressed: () async {
                      await _auth.signOut();
                    },
                  ),
                ],
              ),
              floatingActionButton: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: _pickFile,
                ),
              ),
            ),
          );
  }

  Future<void> _pickFile() async {
    FilePickerResult pickedFile = await FilePicker.platform.pickFiles();
    if (pickedFile != null) {
      setState(() {
        pFile = pickedFile.files.first;
        File file = File(pFile.path);
        var firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child(widget.user.uid)
            .child(pFile.name);
        var task = firebaseStorageRef.putFile(file);
        updateList();
      });
    }
  }
}
