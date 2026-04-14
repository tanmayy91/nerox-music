// ignore_for_file: constant_identifier_names

import 'dart:ui';
import 'package:flutter/material.dart';

enum SanckBarSize { BIG, MEDIUM, SMALL }

SnackBar snackbar(BuildContext context, String text,
    {SanckBarSize size = SanckBarSize.MEDIUM,
    Duration duration = const Duration(seconds: 1),
    bool top = false}) {
  final scrWidth = MediaQuery.of(context).size.width;
  final hrMargin = size == SanckBarSize.BIG
      ? (scrWidth - 320) / 2
      : size == SanckBarSize.MEDIUM
          ? (scrWidth - 220) / 2
          : (scrWidth - 120) / 2;
  return SnackBar(
    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
    content: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 13),
        ),
      ),
    ),
    margin: EdgeInsets.only(
        bottom: top ? MediaQuery.of(context).size.height * 0.8 : 100,
        left: hrMargin,
        right: hrMargin),
    behavior: SnackBarBehavior.floating,
    duration: duration,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  );
}
