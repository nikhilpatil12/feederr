import 'package:dio/dio.dart';
import 'package:feederr/models/app_theme.dart';
import 'package:feederr/models/server.dart';
import 'package:feederr/utils/apiservice.dart';
import 'package:feederr/utils/providers/themeprovider.dart';
import 'package:feederr/widgets/server_form.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

// class ServerListItem extends StatelessWidget {
//   const ServerListItem({
//     super.key,
//     required this.server,
//   });
//   final Server server;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Expanded(
//             flex: 3,
//             child: _ServerDetails(server: server),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ServerDetails extends StatelessWidget {
//   const _ServerDetails({required this.server});

//   final Server server;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             server.baseUrl,
//             style: TextStyle(
//               fontWeight: FontWeight.w500,
//               fontSize: 14.0,
//               // color: Color(widge)
//             ),
//           ),
//           const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
//           Text(
//             server.userName,
//             style: const TextStyle(
//               fontSize: 12.0,
//               color: Color.fromRGBO(76, 2, 232, 1),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class ServerList extends StatefulWidget {
  const ServerList({
    super.key,
    required this.databaseService,
    required this.api,
  });
  final DatabaseService databaseService;
  final APIService api;
  @override
  ServerListState createState() => ServerListState();
}

class ServerListState extends State<ServerList> {
  List<Server> servers = [];

  bool isLoading = false;
  // DatabaseService databaseService = DatabaseService();

  void refreshServers() async {
    servers = await widget.databaseService.servers();
    setState(() {});
  }

  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();

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
      servers = await widget.databaseService.servers();
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
        body: Column(
      children: [
        ServerForm(
          refreshParent: refreshServers,
          formUrlController: _controller1,
          formUsernameController: _controller2,
          formPasswordController: _controller3,
          databaseService: widget.databaseService,
          api: widget.api,
        ),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : servers.isNotEmpty == true
                ? Center(
                    child: SizedBox(
                      height: 200.0,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: servers.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          // return Text(servers[index].baseUrl);
                          if (servers[index].baseUrl != "localhost") {
                            return Selector<ThemeProvider, int>(
                                selector: (_, themeProvider) =>
                                    themeProvider.theme.textColor,
                                builder: (context, textColor, child) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        flex: 8,
                                        child: ListTile(
                                          iconColor: Color(textColor),
                                          textColor: Color(textColor),
                                          title: Text(servers[index].baseUrl),
                                          subtitle:
                                              Text(servers[index].userName),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          color: Color(textColor),
                                          highlightColor: Colors.transparent,
                                          onPressed: () => {
                                            _editForm(
                                                servers[index].baseUrl,
                                                servers[index].userName,
                                                servers[index].password),
                                          },
                                          icon:
                                              const Icon(CupertinoIcons.pencil),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          color: Color(textColor),
                                          highlightColor: Colors.transparent,
                                          onPressed: () async => {
                                            widget.databaseService
                                                .deleteServerByUrlAndUser(
                                                    servers[index].baseUrl,
                                                    servers[index].userName),
                                            servers = await widget
                                                .databaseService
                                                .servers(),
                                            Fluttertoast.showToast(
                                                msg: "Server deleted",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor:
                                                    const Color.fromRGBO(
                                                        144, 36, 60, 1),
                                                textColor: Colors.white,
                                                fontSize: 16.0),
                                            setState(() {})
                                          },
                                          icon:
                                              const Icon(CupertinoIcons.trash),
                                        ),
                                      )
                                    ],
                                  );
                                });
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                  )
                : const Text('No servers configured yet'),
      ],
    ));
  }
}
