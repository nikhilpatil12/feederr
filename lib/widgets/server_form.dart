import 'package:feederr/models/server.dart';
import 'package:feederr/utils/api_utils.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ServerForm extends StatefulWidget {
  final VoidCallback refreshParent;
  final TextEditingController formUrlController;
  final TextEditingController formUsernameController;
  final TextEditingController formPasswordController;

  const ServerForm(
      {super.key,
      required this.refreshParent,
      required this.formUrlController,
      required this.formUsernameController,
      required this.formPasswordController});

  @override
  ServerFormState createState() => ServerFormState();
}

class ServerFormState extends State<ServerForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DatabaseService databaseService = DatabaseService();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    widget.formUrlController.dispose();
    widget.formUsernameController.dispose();
    widget.formPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        // autovalidateMode: AutovalidateMode.always,
        onChanged: () {
          Form.maybeOf(primaryFocus!.context!)?.save();
        },
        child: Column(children: [
          CupertinoFormSection.insetGrouped(
            header: const Text('LOGIN'),
            children: [
              CupertinoTextFormFieldRow(
                controller: widget.formUrlController,
                prefix: RichText(
                  text: const TextSpan(
                    text: 'Server URL',
                    style: TextStyle(
                      color: Color.fromARGB(255, 178, 178, 178),
                    ),
                  ),
                ),
                placeholder: 'http://yourserver.com',
                style: const TextStyle(color: Colors.white),
                validator: (String? value) {
                  if (value == null ||
                      value.isEmpty ||
                      !Uri.parse(value).isAbsolute) {
                    return 'Please enter valid URL with http://';
                  }
                  return null;
                },
              ),
              CupertinoTextFormFieldRow(
                controller: widget.formUsernameController,
                prefix: RichText(
                  text: const TextSpan(
                    text: 'Username',
                    style: TextStyle(
                      color: Color.fromARGB(255, 178, 178, 178),
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                placeholder: 'admin@domain.com',
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter valid username';
                  }
                  return null;
                },
              ),
              CupertinoTextFormFieldRow(
                controller: widget.formPasswordController,
                prefix: RichText(
                  text: const TextSpan(
                    text: 'Password',
                    style: TextStyle(
                      color: Color.fromARGB(255, 178, 178, 178),
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                placeholder: 'your_password',
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
            ],
          ),
          SizedBox(
            width: double.infinity - 500.0,
            child: CupertinoButton.filled(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Process data.
                  final baseUrl = widget.formUrlController.text;
                  final userName = widget.formUsernameController.text;
                  Server? s1 = await databaseService.serverByUrlAndUsername(
                      baseUrl, userName);
                  if (s1 != null) {
                    if (s1.auth == "") {
                      //TODO: Add auth
                    } else {
                      Fluttertoast.showToast(
                          msg:
                              "Server and user already exist. You can choose edit them instead",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 2,
                          backgroundColor: Color.fromRGBO(144, 36, 60, 1),
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  } else {
                    final encodedUsername = Uri.encodeComponent(userName);
                    final password = widget.formPasswordController.text;
                    final encodedPassword = Uri.encodeComponent(password);
                    final auth = await userLogin(
                        baseUrl, encodedUsername, encodedPassword);

                    if (auth != '404') {
                      Fluttertoast.showToast(
                          msg: "Server added",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Color.fromRGBO(76, 2, 232, 1),
                          textColor: Colors.white,
                          fontSize: 16.0);
                      databaseService.insertServer(
                        Server(
                            baseUrl: baseUrl,
                            userName: userName,
                            password: password,
                            auth: auth),
                      );
                      widget.refreshParent();
                    } else {
                      Fluttertoast.showToast(
                          msg: "Invalid credentials",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 2,
                          backgroundColor: Color.fromRGBO(144, 36, 60, 1),
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  }
                }
              },
              child: const Text('Login'),
            ),
          ),
        ]),
      ),
    );
  }
}
