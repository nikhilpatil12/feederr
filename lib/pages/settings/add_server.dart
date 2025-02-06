import 'package:dio/dio.dart';
import 'package:blazefeeds/models/server.dart';
import 'package:blazefeeds/utils/apiservice.dart';
import 'package:blazefeeds/widgets/server_form.dart';
import 'package:blazefeeds/utils/dbhelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ServerList extends StatefulWidget {
  const ServerList({
    super.key,
    // required this.databaseService,
    // required this.api,
  });
  // final DatabaseService databaseService;
  // final APIService api;
  @override
  ServerListState createState() => ServerListState();
}

class ServerListState extends State<ServerList> {
  List<Server> servers = [];

  bool isLoading = false;
  late final DatabaseService _databaseService;
  late final APIService _api;

  void refreshServers() async {
    servers = await _databaseService.servers();
    setState(() {});
  }

  late final TextEditingController _controller0;
  late final TextEditingController _controller1;
  late final TextEditingController _controller2;
  late final TextEditingController _controller3;

  void _editForm(String f0, String f1, String f2, String f3) {
    setState(() {
      _controller0.text = f0;
      _controller1.text = f1;
      _controller2.text = f2;
      _controller3.text = f3;
    });
  }

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _api = APIService();
    _fetchServers();
    _controller0 = TextEditingController();
    _controller1 = TextEditingController();
    _controller2 = TextEditingController();
    _controller3 = TextEditingController();
  }

  @override
  void dispose() {
    // _controller1.dispose();
    // _controller2.dispose();
    // _controller3.dispose();
    super.dispose();
  }

  Future<void> _fetchServers() async {
    setState(() {
      isLoading = true;
    });
    try {
      // articles = await fetchServers();
      // for (Article article in articles) {
      //   DatabaseService databaseService = DatabaseService();
      //   databaseService.insertArticle(article);
      // }
      servers = await _databaseService.servers();
    } on DioException {
      // Handle error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ServerForm(
              refreshParent: refreshServers,
              formNameController: _controller0,
              formUrlController: _controller1,
              formUsernameController: _controller2,
              formPasswordController: _controller3,
              databaseService: _databaseService,
              api: _api,
            ),
            // SizedBox(
            //   height: 10,
            // ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 40),
              child: Text(
                  "Blaze Feeds works with FreshRSS version 1.11 and higher. You need to enable API access and enter the greader.php API URL."),
            ),
            SizedBox(
              height: 50,
            ),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : servers.length > 1
                    ? Column(
                        children: List.generate(servers.length, (index) {
                          if (servers[index].baseUrl != "localhost") {
                            return ListTile(
                              leading: CircleAvatar(child: Icon(Icons.computer)),
                              // iconColor: Color(textColor),
                              // textColor: Color(textColor),
                              title: Text(servers[index].name),
                              subtitle: Text(servers[index].userName),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    // color: Color(textColor),
                                    highlightColor: Colors.transparent,
                                    onPressed: () => {
                                      _editForm(servers[index].name, servers[index].baseUrl,
                                          servers[index].userName, servers[index].password),
                                    },
                                    icon: const Icon(CupertinoIcons.pencil),
                                  ),
                                  IconButton(
                                    // color: Color(textColor),
                                    highlightColor: Colors.transparent,
                                    onPressed: () async => {
                                      _databaseService.deleteServerByUrlAndUser(
                                          servers[index].baseUrl, servers[index].userName),
                                      servers = await _databaseService.servers(),
                                      if (context.mounted)
                                        {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Server deleted'),
                                              backgroundColor: Colors.redAccent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                          setState(() {})
                                        }
                                    },
                                    icon: const Icon(CupertinoIcons.trash),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }),
                      )
                    : const Text('No servers configured yet'),
          ],
        ),
      ),
    );
  }
}
