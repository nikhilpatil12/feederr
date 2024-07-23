import 'package:dio/dio.dart';
import 'package:feederr/models/server.dart';
import 'package:feederr/widgets/server_form.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ServerListItem extends StatelessWidget {
  const ServerListItem({
    super.key,
    required this.server,
  });
  final Server server;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: _ServerDetails(server: server),
          ),
        ],
      ),
    );
  }
}

class _ServerDetails extends StatelessWidget {
  const _ServerDetails({required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            server.baseUrl,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Text(
            server.userName,
            style: const TextStyle(
              fontSize: 12.0,
              color: Color.fromRGBO(76, 2, 232, 1),
            ),
          ),
        ],
      ),
    );
  }
}

class ServerList extends StatefulWidget {
  const ServerList({super.key});

  @override
  _ServerListState createState() => _ServerListState();
}

class _ServerListState extends State<ServerList> {
  List<Server> servers = [];

  bool isLoading = false;
  DatabaseService databaseService = DatabaseService();

  void refreshServers() async {
    servers = await databaseService.servers();
    setState(() {});
  }

  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  TextEditingController _controller3 = TextEditingController();

  void _editForm(String f1, String f2, String f3) {
    setState(() {
      _controller1.text = f1;
      _controller2.text = f2;
      _controller3.text = f3;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchServers();
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
      servers = await databaseService.servers();
    } on DioException catch (e) {
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
        body: Column(
      children: [
        ServerForm(
          refreshParent: refreshServers,
          formUrlController: _controller1,
          formUsernameController: _controller2,
          formPasswordController: _controller3,
        ),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : servers.isNotEmpty == true
                ? Center(
                    child: SizedBox(
                      height: 200.0,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: servers.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          // return Text(servers[index].baseUrl);
                          return Row(
                            children: [
                              Expanded(
                                flex: 8,
                                child: ListTile(
                                  title: Text(servers[index].baseUrl),
                                  subtitle: Text(servers[index].userName),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  highlightColor: Colors.transparent,
                                  onPressed: () => {
                                    _editForm(
                                        servers[index].baseUrl,
                                        servers[index].userName,
                                        servers[index].password),
                                  },
                                  icon: const Icon(CupertinoIcons.pencil),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  highlightColor: Colors.transparent,
                                  onPressed: () async => {
                                    databaseService.deleteServerByUrlAndUser(
                                        servers[index].baseUrl,
                                        servers[index].userName),
                                    servers = await databaseService.servers(),
                                    Fluttertoast.showToast(
                                        msg: "Server deleted",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor:
                                            Color.fromRGBO(144, 36, 60, 1),
                                        textColor: Colors.white,
                                        fontSize: 16.0),
                                    setState(() {})
                                  },
                                  icon: const Icon(CupertinoIcons.trash),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  )
                : const Text('No servers configured yet'),
      ],
    ));
  }
}
