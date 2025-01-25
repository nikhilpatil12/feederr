import 'dart:developer';

import 'package:xml/xml.dart';
import 'package:intl/intl.dart';

String timeAgo(int timestampInMs) {
  final now = DateTime.now();
  final then = DateTime.fromMillisecondsSinceEpoch(timestampInMs * 1000);
  final difference = now.difference(then);

  final inMinutes =
      difference.inMinutes % 60; // Use max to avoid negative values
  final inHours = difference.inHours % 24;
  final inDays = difference.inDays;

  if (inDays > 0) {
    return inDays == 1 ? "$inDays day ago" : "$inDays days ago";
  } else if (inHours > 0) {
    return inHours == 1 ? "$inHours hour ago" : "$inHours hours ago";
  } else {
    return inMinutes == 1 ? "$inMinutes minute ago" : "$inMinutes minutes ago";
  }
}

String getTag(String rawTag) {
  List<String> splitted = rawTag.split("/");
  return splitted.last;
}

List<String> castToListOfStrings(dynamic list) {
  if (list is List) {
    return list.cast<String>();
  } else {
    // Handle the case where the object is not a list
    throw ArgumentError('Expected a List of Strings');
  }
}

bool isWithin24Hours(int timestampInMs) {
  final now = DateTime.now();
  final then = DateTime.fromMillisecondsSinceEpoch(timestampInMs * 1000);
  final difference = now.difference(then);

  final inHours = difference.inHours;
  if (inHours <= 24) {
    return true;
  } else {
    return false;
  }
}

String detectFeedFormat(String feedContent) {
  try {
    final document = XmlDocument.parse(feedContent);
    final root = document.rootElement;

    // Check for RSS 2.0
    if (root.name.local == 'rss' && root.getAttribute('version') == '2.0') {
      return 'RSS 2.0';
    }

    // Check for RSS 1.0 (RDF-based)
    if (root.name.local == 'RDF' && root.getAttribute('xmlns:rdf') != null) {
      return 'RSS 1.0';
    }

    // Check for Atom
    if (root.name.local == 'feed' &&
        root.getAttribute('xmlns') == 'http://www.w3.org/2005/Atom') {
      return 'Atom';
    }
  } catch (e) {
    return 'Unknown format';
  }

  return 'Unknown format';
}

/// Converts a date string to a Unix timestamp based on the known format.
// int convertDateToGReader(String? dateString, String format) {
//   if (dateString == null || dateString.trim().isEmpty) {
//     print("Warning: Date string is empty or null.");
//     return DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
//   }

//   try {
//     // Parse the date based on the provided format
//     if (format == 'rfc822') {
//       final rfc822Format =
//           DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US');
//       final dateTime = rfc822Format.parseUtc(dateString);
//       return dateTime.millisecondsSinceEpoch ~/ 1000;
//     } else if (format == 'iso8601') {
//       final dateTime = DateTime.parse(dateString);
//       return dateTime.toUtc().millisecondsSinceEpoch ~/ 1000;
//     } else {
//       print("Unsupported format: $format");
//       return DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
//     }
//   } catch (e) {
//     print("Error parsing date string: $dateString. Exception: $e");
//     return DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
//   }
// }

int convertDateToGReader(String dateString) {
  // List of known date formats
  final List<String> dateFormats = [
    "EEE, dd MMM yyyy HH:mm:ss Z", // RFC 822/2822 (e.g., Sun, 19 Jan 2025 22:39:57 +0000)
    "EEE, dd MMM yyyy HH:mm:ss 'GMT'", // RFC 822/2822 without offset
    "yyyy-MM-dd'T'HH:mm:ss'Z'", // ISO 8601 UTC (e.g., 2025-01-19T22:39:57Z)
    "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", // ISO 8601 with milliseconds
    "yyyy-MM-dd'T'HH:mm:ssXXXXX", // ISO 8601 with time zone offset
    "yyyy-MM-dd HH:mm:ss", // Generic format without time zone
  ];

  for (String format in dateFormats) {
    try {
      final dateFormat = DateFormat(format, 'en_US');
      final dateTime = dateFormat.parseUtc(dateString);
      return dateTime.millisecondsSinceEpoch ~/
          1000; // Convert to Unix timestamp
    } catch (_) {
      // Ignore and try the next format
    }
  }
  try {
    final dateTime = DateTime.parse(dateString);
    return dateTime.toUtc().millisecondsSinceEpoch ~/ 1000;
  } catch (_) {
    // Ignore and try the next format
  }

  // If all parsing fails, return null
  log("Failed to parse date: $dateString");
  return DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
}

int getId2(String id) {
  // Extract the part after the last '/'
  final regex = RegExp(r'.*/([0-9a-f]+)$');
  final match = regex.firstMatch(id);

  if (match == null) {
    throw FormatException('Invalid ID format: $id');
  }

  // Extract the hexadecimal number as a string
  final hexPart = match.group(1)!;

  // Convert the hexadecimal string to an integer
  return int.parse(hexPart, radix: 16);
}
