import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blazefeeds/models/app_theme.dart';
import 'package:blazefeeds/providers/theme_provider.dart';
import 'package:blazefeeds/utils/dbhelper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class BackupSettings extends StatelessWidget {
  BackupSettings({super.key});
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Appearance',
          overflow: TextOverflow.fade,
        ),
      ),
      body: ListView(scrollDirection: Axis.vertical, children: <Widget>[
        GestureDetector(
          child: ListTile(
            trailing: CircleAvatar(
              child: Icon(Icons.backup_outlined),
            ),
            title: Text("Backup"),
            subtitle: Text("Backup to local storage"),
          ),
          onTap: () async {
            String? userKey = await promptForKey(context, false);
            if (context.mounted) {
              exportData(context, userKey);
            }
          },
        ),
        GestureDetector(
          child: ListTile(
            selectedTileColor: Color(themeProvider.theme.primaryColor),
            trailing: CircleAvatar(
              child: Icon(Icons.restore_outlined),
            ),
            title: Text("Restore"),
            subtitle: Text("Restore previous backup"),
          ),
          onTap: () async {
            if (context.mounted) {
              restoreFromUserFile(context);
            }
          },
        ),
        // IconButton(
        //     onPressed: () => {
        //           exportData(),
        //         },
        //     icon: Icon(Icons.backup_outlined)),
        // IconButton(onPressed: () => {restoreFromUserFile()}, icon: Icon(Icons.restore))
      ]),
    );
  }

  Future<void> restoreFromUserFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      if (context.mounted) {
        String? userKey = await promptForKey(context, true);

        if (userKey == null) return;
        String backupFilePath = result.files.single.path!;
        await importData(context, userKey, backupFilePath);
      }
    }
  }

  Future<String> exportData(BuildContext context, String? userKey) async {
    if (userKey == null) return "";
    final prefs = await SharedPreferences.getInstance();
    final db = await _databaseService.database;
    // Step 1: Backup SharedPreferences
    final keys = prefs.getKeys();
    final Map<String, dynamic> preferencesBackup = {for (var key in keys) key: prefs.get(key)};
    // Step 2: Backup SQLite Database
    List<Map<String, dynamic>> tables =
        await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    Map<String, dynamic> databaseBackup = {};

    for (var table in tables) {
      String tableName = table['name'];
      if (tableName != 'android_metadata' && tableName != 'sqlite_sequence') {
        List<Map<String, dynamic>> rows = await db.query(tableName);
        databaseBackup[tableName] = rows;
      }
    }
    // Step 3: Create Backup JSON
    Map<String, dynamic> backupData = {
      'preferences': preferencesBackup,
      'database': databaseBackup,
    };
    String jsonString = jsonEncode(backupData);
    // Step 4: Save to File
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('MMddyyyyHHmmss').format(DateTime.now());
    final file = File('${directory.path}/backup$timestamp.fbf');
    final keyBytes = deriveKey(userKey, keyLength: 16);
    final key = encrypt.Key(keyBytes);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(jsonString, iv: iv);
    final String encryptedContent = '''
VERSION:1.0
TIMESTAMP:$timestamp
IV:${iv.base64}
DATA:${encrypted.base64}
''';
    await file.writeAsString(encryptedContent);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup saved at ${file.path}')),
      );
    }
    return file.path;
  }

  Future<void> importData(BuildContext context, userKey, String backupFilePath) async {
    AppTheme theme = Provider.of<ThemeProvider>(context, listen: false).theme;
    final prefs = await SharedPreferences.getInstance();
    final db = await _databaseService.database;
    // Step 1: Read Backup File
    final file = File(backupFilePath);
    if (!await file.exists()) throw Exception("Backup file not found");
    String content = await file.readAsString();
    // Extract values manually (parsing lines)
    final lines = content.split('\n');
    String? ivBase64, encryptedData;

    for (var line in lines) {
      if (line.startsWith('IV:')) {
        ivBase64 = line.substring(3).trim();
      } else if (line.startsWith('DATA:')) {
        encryptedData = line.substring(5).trim();
      }
    }

    if (ivBase64 == null || encryptedData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid backup format!')),
      );
      return;
    }
    final keyBytesForDecryption = deriveKey(userKey, keyLength: 16);
    final keyForDecryption = encrypt.Key(keyBytesForDecryption);

    // Use the same IV that was used during encryption.
    final decrypter = encrypt.Encrypter(
        encrypt.AES(keyForDecryption, mode: encrypt.AESMode.cbc, padding: "PKCS7"));
    final iv = encrypt.IV.fromBase64(ivBase64);

    try {
      final decrypted = decrypter.decrypt64(encryptedData, iv: iv);

      Map<String, dynamic> backupData = jsonDecode(decrypted);

      // Step 2: Restore SharedPreferences
      if (backupData.containsKey('preferences')) {
        Map<String, dynamic> preferencesBackup = backupData['preferences'];
        for (var key in preferencesBackup.keys) {
          var value = preferencesBackup[key];
          if (value is int) {
            await prefs.setInt(key, value);
          } else if (value is double) {
            await prefs.setDouble(key, value);
          } else if (value is bool) {
            await prefs.setBool(key, value);
          } else if (value is String) {
            await prefs.setString(key, value);
          } else if (value is List<String>) {
            await prefs.setStringList(key, value);
          }
        }
      }

      // Step 3: Restore SQLite Database
      if (backupData.containsKey('database')) {
        Map<String, dynamic> databaseBackup = backupData['database'];
        for (var table in databaseBackup.keys) {
          List<Map<String, dynamic>> rows = List<Map<String, dynamic>>.from(databaseBackup[table]);

          // Clear existing table data
          await db.delete(table);

          // Restore rows
          for (var row in rows) {
            await db.insert(table, row);
          }
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(theme.primaryColor),
          content: Text(
              "Backup successfully restored, please exit the app to properly load restored settings!"),
          action: SnackBarAction(
            backgroundColor: Color(theme.secondaryColor),
            textColor: Color(theme.textColor),
            label: "Okay",
            onPressed: () async {
              await SystemChannels.platform.invokeMethod<void>(
                'SystemNavigator.pop',
              );
            },
          ),
        ),
      );
      return;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Decryption failed! Incorrect key?')),
      );
      return null;
    }
  }

  Future<String?> promptForKey(BuildContext context, bool isRestoring) async {
    TextEditingController keyController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Encryption Key'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              decoration: InputDecoration(
                // labelStyle: TextStyle(color: Color(theme.textColor).withAlpha(150)),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                labelText: 'More than 8 characters',
              ),
              controller: keyController,
              obscureText: true, // Hide input for security
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 0),
              child: Text(isRestoring
                  ? "Provide the encryption key you used for the backup."
                  : "You will need this key during backup restoration. This backup can be used on any device running Blaze Feeds."),
            ),
          ]),
          actions: [
            TextButton(
              // color: Theme.of(context).primaryColor,
              onPressed: () => Navigator.pop(context, null), // Cancel
              child: Text(
                'Cancel',
              ),
            ),
            TextButton(
              // color: Theme.of(context).primaryColor,
              onPressed: () {
                String key = keyController.text;
                if (key.length >= 8) {
                  Navigator.pop(context, key);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Key must be greater than 8 characters!')),
                  );
                }
              },
              child: Text(
                'OK',
              ),
            ),
          ],
        );
      },
    );
  }

  Uint8List deriveKey(String passphrase, {int iterations = 10000, int keyLength = 16}) {
    final passphraseBytes = utf8.encode(passphrase);
    final saltBytes = utf8.encode("7pS*=0tBD)*If)gU");
    final params = Pbkdf2Parameters(Uint8List.fromList(saltBytes), iterations, keyLength);
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(params);
    return pbkdf2.process(Uint8List.fromList(passphraseBytes));
  }
}
