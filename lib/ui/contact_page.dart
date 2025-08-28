import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_agenda_contato/helpers/contact_helper.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  final Contact? contact;

  ContactPage({this.contact});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  bool _userEditing = false;

  Contact? _editedContect;
  
  @override
  void initState() {
    //
    super.initState();
    if(widget.contact == null){
      _editedContect = Contact();
    }else{
      _editedContect = Contact.fromMap(widget.contact!.toMap());
      _nameController.text = _editedContect!.name ?? "";
      _emailController.text = _editedContect!.email ?? "";
      _phoneController.text = _editedContect!.phone ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked:  (bool didPop) async {
        // Se o pop já aconteceu, não faça nada.
        if (didPop) return;

        final bool shouldPop = await _requestPop();

        if (shouldPop) {
          // Se o resultado for verdadeiro, permita o pop da página
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _editedContect?.name ?? "Novo Contato",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.red,
          iconTheme: IconThemeData(
            color: Colors.white
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: (){
              if(_editedContect!.name != null  && _editedContect!.name!.isNotEmpty){
                Navigator.pop(context, _editedContect);
              }else{
                FocusScope.of(context).requestFocus(_nameFocus);
              }

            },
            child: Icon(
                Icons.save,
                color: Colors.white,
            ),
            backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(

              children: <Widget>[
                GestureDetector(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: (_editedContect?.img == 'imgTeste2' || _editedContect?.img == 'imgTeste' || _editedContect?.img == null) ?
                            AssetImage("images/person.png") :
                            FileImage(File(_editedContect!.img!)),
                            fit: BoxFit.cover
                        ),

                    ),
                  ),
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.camera);

                    if (pickedFile != null) {
                      setState(() {
                        _editedContect!.img = pickedFile.path;
                        _userEditing = true;
                      });
                    }
                  },
                ),
                TextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  decoration: InputDecoration(
                    labelText: "Nome"
                  ),
                  onChanged: (text){
                    _userEditing = true;
                    setState(() {
                      _editedContect!.name = text;
                    });
                  },
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      labelText: "EMail"
                  ),
                  onChanged: (text){
                    _userEditing = true;
                      _editedContect!.email = text;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                      labelText: "Phone"
                  ),
                  onChanged: (text){
                    _userEditing = true;
                    _editedContect!.phone = text;
                  },
                  keyboardType: TextInputType.phone,
                )
              ],
          ),
        ),
      ),
    );
  }


  Future<bool> _requestPop() async{
    if(_userEditing){
      final result = await showDialog<bool>(
          context: context, 
          builder: (context){
            return AlertDialog(
              title: Text("Descartar Alterações?"),
              content: Text("Se sair as alterações serão perdidas."),
              actions: <Widget>[
                TextButton(
                    onPressed: (){
                      Navigator.of(context).pop(false);
                    },
                    child: Text("Cancelar"),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.of(context).pop(true);
                  },
                  child: Text("Sim"),
                )
              ],
            );
          }
      );
      return result ?? false;
    } else {
      return true;
    }
  }


}

