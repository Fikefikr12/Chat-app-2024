import 'package:chatapp1/pages/settings_page.dart';
import 'package:chatapp1/service/auth/auth_service.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});
void logout(){
  final _auth = AuthService();
  _auth.signOut();
}
  @override
  Widget build(BuildContext context) {
    return Drawer (
      backgroundColor: Theme.of(context).colorScheme.background,
       child: Column(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
          Column(
            children: [
              DrawerHeader(child:
              Center(child:
              Icon(Icons.message,
                color:  Theme.of(context).colorScheme.primary,
                size:70 ,
              )
                ,)
                ,),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ListTile(
                  title: Text("H O M E"),
                  leading: Icon(Icons.home),
                  onTap: (){
                    Navigator.pop(context);
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ListTile(
                  title: Text("S E T T I N G S "),
                  leading: Icon(Icons.settings),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context)=>SettingsPage()));
                  },
                ),
              ),

            ],
          ),
           Padding(
             padding: const EdgeInsets.only(left: 8.0,bottom: 25),
             child: ListTile(
               title: Text("L O G O U T"),
               leading: Icon(Icons.logout),
               onTap: logout,
             ),
           )
         ],
       ),
    );
  }
}
