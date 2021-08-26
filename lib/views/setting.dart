import 'package:chat/helperfunctions/sharepref.dart';
import 'package:chat/services/database.dart';
import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  String? url;
  String? name;
  String? displayName;
  String? email;

  TextEditingController nameController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  Future<void> getPersonalInfo() async {
    url = await Prefs().getPhotoUrl();
    name = await Prefs().getUsername();
    displayName = await Prefs().getDisplayName();
    email = await Prefs().getEmail();
    setState(() {});
  }

  doThisOnLaunch() async {
    await getPersonalInfo();
    setState(() {});
    nameController.text = name!;
    displayNameController.text = displayName!;
    emailController.text = email!;

    print(nameController.text);
    print(displayNameController.text);
    print(emailController.text);
  }

  Future updateDisplayName() async {
    if (displayNameController.text.trim().length != 0 &&
        displayName != displayNameController.text) {
      Map<String, dynamic> newInfo = {
        'displayName': displayNameController.text
      };
      await Database().updateUserDisplayName(newInfo);
      await Prefs().saveDisplayName(displayNameController.text);
      setState(() {});
      displayName = await Prefs().getDisplayName();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            padding: EdgeInsets.symmetric(horizontal: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            content: Text(
              'Name changed!',
              style: TextStyle(fontSize: 20),
            )),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    doThisOnLaunch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Setting'),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: url != null &&
                  name != null &&
                  displayName != null &&
                  email != null
              ? Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ClipRRect(
                          child: Image.network(
                            url!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        // email
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Column(
                            children: [
                              TextField(
                                controller: emailController,
                                enabled: false,
                                style: TextStyle(fontSize: 25),
                              ),
                              TextField(
                                controller: nameController,
                                enabled: false,
                                style: TextStyle(fontSize: 25),
                              ),
                              TextField(
                                controller: displayNameController,
                                enabled: true,
                                style: TextStyle(fontSize: 25),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 20),
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.white60,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18))),
                              child: Text(
                                'Change',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                ),
                              ),
                              onPressed: () {
                                updateDisplayName();
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ));
  }
}
