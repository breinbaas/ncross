import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ncross/logic/crosssections_model.dart';
import 'package:ncross/objects/crosssection.dart';

const margin = 40.0;
const maxDisplayNumber = 100;

class CrosssectionsPainter extends CustomPainter {
  final CrosssectionsModel crosssectionsModel;

  CrosssectionsPainter(this.crosssectionsModel) : super();

  @override
  void paint(Canvas canvas, Size size) {
    if (crosssectionsModel.crosssections.isEmpty) {
      return;
    }

    final penWhite = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final penYellow = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final penBlue = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final penRed = Paint()
      ..color = Colors.red
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final penFatRed = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;

    final double left = crosssectionsModel.left - 5.0;
    final double right = crosssectionsModel.right + 5.0;
    final double bottom = crosssectionsModel.bottom - 2.0;
    final double top = crosssectionsModel.top + 2.0;

    // draw limits
    double xLeftLimit =
        margin + (crosssectionsModel.limitLeft - left) / (right - left) * w;
    double xRightLimit =
        margin + (crosssectionsModel.limitRight - left) / (right - left) * w;
    canvas.drawLine(
        Offset(xLeftLimit, margin), Offset(xLeftLimit, h - margin), penWhite);
    canvas.drawLine(Offset(xRightLimit, margin),
        Offset(xRightLimit, h - margin), penYellow);

    // draw crosssections
    int counter = 0;

    String normativeText = "";
    List<int> normativeChainages = [];
    if (crosssectionsModel.normativeChainages.isNotEmpty) {
      if (crosssectionsModel.normativeChainages.length <
          crosssectionsModel.numNormatives) {
        normativeChainages = crosssectionsModel.normativeChainages
            .take(crosssectionsModel.normativeChainages.length)
            .map((e) => e.chainage)
            .toList();
      } else {
        normativeChainages = crosssectionsModel.normativeChainages
            .take(crosssectionsModel.numNormatives)
            .map((e) => e.chainage)
            .toList();
      }

      normativeText = "normative crosssections:\n";
      for (int i = 0;
          i <
              (min(crosssectionsModel.numNormatives,
                  crosssectionsModel.normativeChainages.length));
          i++) {
        normativeText +=
            "${crosssectionsModel.normativeChainages[i].chainage} (${crosssectionsModel.normativeChainages[i].weight.toStringAsFixed(2)})\n";
      }
    }

    const textStyle = TextStyle(
      color: Colors.red,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    var textSpan = TextSpan(
      text: normativeText,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    textPainter.paint(canvas, const Offset(margin, margin));

    for (Crosssection crosssection in crosssectionsModel.crosssections) {
      if (crosssection.chainage < crosssectionsModel.startChainage ||
          crosssection.chainage > crosssectionsModel.endChainage) continue;

      counter += 1;
      if (counter > maxDisplayNumber) {
        var textSpan = const TextSpan(
          text:
              'Showing the maximum of $maxDisplayNumber crosssections. Adjust selection criteria to decrease the number of selected crosssections.',
          style: textStyle,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(
          minWidth: 0,
          maxWidth: size.width,
        );
        textPainter.paint(canvas, Offset(margin, h - margin));
        return;
      }

      for (int i = 1; i < crosssection.points.length; i++) {
        double x1 =
            margin + (crosssection.points[i - 1].l - left) / (right - left) * w;
        double y1 = margin +
            h -
            (crosssection.points[i - 1].z - bottom) / (top - bottom) * h;
        double x2 =
            margin + (crosssection.points[i].l - left) / (right - left) * w;
        double y2 = margin +
            h -
            (crosssection.points[i].z - bottom) / (top - bottom) * h;

        if (normativeChainages.contains(crosssection.chainage)) {
          if (crosssection.chainage == normativeChainages[0]) {
            canvas.drawLine(Offset(x1, y1), Offset(x2, y2), penFatRed);
          } else {
            canvas.drawLine(Offset(x1, y1), Offset(x2, y2), penRed);
          }
        } else {
          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), penBlue);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
