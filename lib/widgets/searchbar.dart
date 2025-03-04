import 'package:flutter/cupertino.dart';

class NavigationBarSearchField extends StatelessWidget implements PreferredSizeWidget {
  const NavigationBarSearchField({super.key});

  static const double padding = 8.0;
  static const double searchFieldHeight = 35.0;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
      child: SizedBox(
        height: searchFieldHeight,
        child: CupertinoSearchTextField(
          placeholder: 'Search',
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(searchFieldHeight + padding * 2);
}
