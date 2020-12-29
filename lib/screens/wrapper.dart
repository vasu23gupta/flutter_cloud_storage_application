import 'package:internship_application/models/customUser.dart';
import 'package:internship_application/screens/authenticate/authenticate.dart';
import 'package:internship_application/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    print(user);

    // return either the Home or Authenticate widget
    if (user == null) {
      return Authenticate();
    } else {
      return Home(user: user);
    }
  }
}
