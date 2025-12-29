import 'package:flutter/material.dart';
import 'app_bar_mixins.dart';

class NavPaged extends StatelessWidget
    with HasAppBarTitle, HasAppBarActions {
  final Widget child;
  @override
  final Widget appBarTitle;
  @override
  final List<Widget> Function(BuildContext context) appBarActions;

  const NavPaged({
    required this.child,
    required this.appBarTitle,
    List<Widget> Function(BuildContext context)? appBarActions,
    super.key,
  }) : appBarActions = appBarActions ?? _defaultActions;

  static List<Widget> _defaultActions(BuildContext context) => [];

  @override
  Widget build(BuildContext context) => child;
}