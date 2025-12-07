import 'package:flutter/material.dart';

mixin HasAppBarTitle {
  Widget get appBarTitle;
}

mixin HasAppBarActions {
  // ← Change from Widget → List<Widget>
  List<Widget> appBarActions(BuildContext context);
}