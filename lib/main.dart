
import 'package:flutter/material.dart';
import 'package:flutter_agenda_contato/ui/contact_page.dart';

import 'package:flutter_agenda_contato/ui/home_page.dart';

void main (){
  runApp(
    MaterialApp(
      home: HomePage(),
      // home: ContactPage(),
      debugShowCheckedModeBanner: false,
    )
  );
}