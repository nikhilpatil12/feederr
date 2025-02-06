import 'dart:developer';

import 'package:blazefeeds/models/app_theme.dart';
import 'package:blazefeeds/models/server.dart';
import 'package:blazefeeds/utils/apiservice.dart';
import 'package:blazefeeds/utils/dbhelper.dart';
import 'package:blazefeeds/providers/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServerForm extends StatefulWidget {
  final VoidCallback refreshParent;
  final TextEditingController formNameController;
  final TextEditingController formUrlController;
  final TextEditingController formUsernameController;
  final TextEditingController formPasswordController;
  final DatabaseService databaseService;
  final APIService api;
  const ServerForm({
    super.key,
    required this.refreshParent,
    required this.formNameController,
    required this.formUrlController,
    required this.formUsernameController,
    required this.formPasswordController,
    required this.databaseService,
    required this.api,
  });

  @override
  ServerFormState createState() => ServerFormState();
}

class ServerFormState extends State<ServerForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // DatabaseService databaseService = DatabaseService();

  @override
  void dispose() {
    super.dispose();
    // Clean up the controller when the widget is disposed.
    widget.formUrlController.dispose();
    widget.formUsernameController.dispose();
    widget.formPasswordController.dispose();
    // log("Form disposed");
  }

  @override
  Widget build(BuildContext context) {
    bool isPassWordHidden = true;
    return Selector<ThemeProvider, AppTheme>(
        selector: (_, themeProvider) => themeProvider.theme,
        builder: (_, theme, __) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width * 0.1),
              child: Form(
                key: _formKey,
                // autovalidateMode: AutovalidateMode.always,
                onChanged: () {
                  Form.maybeOf(primaryFocus!.context!)?.save();
                },
                child: Column(spacing: 10, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'LOGIN',
                    style: TextStyle(
                      color: Color(theme.textColor),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Name",
                      textAlign: TextAlign.left,
                    ),
                  ),
                  TextField(
                    controller: widget.formNameController,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Color(theme.textColor).withAlpha(150)),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'default',
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Server Login",
                      textAlign: TextAlign.left,
                    ),
                  ),
                  TextField(
                    controller: widget.formUrlController,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Color(theme.textColor).withAlpha(150)),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'http://yourserver.com/api/greader.php',
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Username",
                      textAlign: TextAlign.left,
                    ),
                  ),
                  TextField(
                    controller: widget.formUsernameController,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Color(theme.textColor).withAlpha(150)),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'Username',
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Password",
                      textAlign: TextAlign.left,
                    ),
                  ),
                  TextField(
                    controller: widget.formPasswordController,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Color(theme.textColor).withAlpha(150)),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'Password',
                    ),
                    // style: const TextStyle(color: Colors.white),
                    obscureText: isPassWordHidden,
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: CupertinoButton.filled(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Process data.
                          final name = widget.formNameController.text;
                          final baseUrl = widget.formUrlController.text;
                          final userName = widget.formUsernameController.text;
                          Server? s1 = await widget.databaseService
                              .serverByUrlAndUsername(baseUrl, userName);
                          if (s1 != null) {
                            if (s1.auth != "") {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Server and user already exist. You can edit them instead'),
                                    backgroundColor: Color(theme.primaryColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                );
                              }
                              //   Fluttertoast.showToast(
                              //       msg: "Server and user already exist. You can edit them instead",
                              //       toastLength: Toast.LENGTH_SHORT,
                              //       gravity: ToastGravity.BOTTOM,
                              //       timeInSecForIosWeb: 2,
                              //       backgroundColor: const Color.fromRGBO(144, 36, 60, 1),
                              //       textColor: Colors.white,
                              //       fontSize: 16.0);
                            }
                          } else {
                            final password = widget.formPasswordController.text;
                            // final APIService api = APIService();
                            final auth = await widget.api.userLogin(baseUrl, userName, password);

                            if (auth != '404') {
                              if (mounted) {
                                widget.formNameController.clear();
                                widget.formUrlController.clear();
                                widget.formUsernameController.clear();
                                widget.formPasswordController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Server added'),
                                    backgroundColor: Colors.greenAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                );
                              }
                              widget.databaseService.insertServer(
                                Server(
                                    name: name,
                                    type: 'freshrss',
                                    baseUrl: baseUrl,
                                    userName: userName,
                                    password: password,
                                    auth: auth),
                              );
                              widget.refreshParent();
                            } else {
                              log(auth);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Invalid credentials'),
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        }
                      },
                      child: const Text('Login'),
                    ),
                  ),
                ]),
              ),
            ),
          );
        });
  }
}
