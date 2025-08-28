import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_agenda_contato/helpers/contact_helper.dart';
import 'package:flutter_agenda_contato/ui/contact_page.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<Contact> contacts = [];


  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  /*
  Utilizado para teste de gravação de dados.
  @override
  void initState() {
    //
    super.initState();

    Contact c = Contact();
    c.name = 'Regiane Maraschiello';
    c.email = 'regianemaraschiello@gmail.com';
    c.phone = '1132233223';
    c.img = 'imgTeste2';

    helper.saveContact(c);

    helper.getAllContact().then((list){
      print(list);
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Contatos",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.white
            ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        actions: [
          PopupMenuButton <OrderOptions>(
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                const PopupMenuItem<OrderOptions>(
                    child: Text("Order A-Z"),
                  value: OrderOptions.orderaz,
                ),
                const PopupMenuItem<OrderOptions>(
                  child: Text("Order Z-A"),
                  value: OrderOptions.orderza,
                )
              ],
              onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            _showContactPage();
          },
          child: Icon(
              Icons.add,
              color: Colors.white,
          ),
          backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: contacts.length,
          itemBuilder: (context, index){
              // print(contacts[index].name);
              // return null;
              return _contactCard(context, index);
          }
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index){
    return GestureDetector(
      onTap: (){
        _showOptions(context, index);
      },
      child: Card(
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: (contacts[index].img == 'imgTeste2' || contacts[index].img == 'imgTeste' || contacts[index].img == null) ?
                            AssetImage("images/person.png") :
                            FileImage(File(contacts[index].img!)),
                        fit: BoxFit.cover
                    )
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            contacts[index].name ?? "",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            contacts[index].email ?? "",
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            contacts[index].phone ?? "",
                            style: TextStyle(fontSize: 18),
                          )

                        ],
                      ),
                  ),
                )
              ],
            ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, int index){
      showModalBottomSheet(
          context: context,
          builder: (context){
            return BottomSheet(
                onClosing: (){},

                builder: (context){
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                            Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  contacts[index].name ?? "Nome não disponível",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 30
                                  ),
                                ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                  onPressed: (){
                                    launchUrl(Uri.parse("tel:${contacts[index].phone}"));
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                      "Ligar",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20,
                                      ),
                                  )
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                    _showContactPage(contact: contacts[index]);
                                  },
                                  child: Text(
                                    "Editar",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 20,
                                    ),
                                  )
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                  onPressed: (){
                                    helper.deleteContact(contacts[index].id!);
                                    setState(() {
                                      contacts.removeAt(index);
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: Text(
                                    "Excluir",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 20,
                                    ),
                                  )
                              ),
                            )
                        ],
                      ),
                    );
                }
            );
          }
      );
  }

  void _showContactPage({Contact? contact}) async{
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact,))
    );
    if(recContact != null){
      print("recContact $recContact");
      if(contact != null){
        print("update");
        await helper.updateContact(recContact);
      }else{
        print("save");
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts(){
    helper.getAllContact().then((list){
      // print(list);
      setState(() {
        contacts = list;
      });
    });
  }

  void _orderList(OrderOptions result){
      switch(result){
        case OrderOptions.orderaz:
          contacts.sort((a, b) {
            return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
          });
          break;
        case OrderOptions.orderza:
          contacts.sort((a, b) {
            return b.name!.toLowerCase().compareTo(a.name!.toLowerCase());
          });
          break;
      }
      setState(() {

      });
  }

}
