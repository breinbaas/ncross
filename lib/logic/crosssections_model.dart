import 'package:flutter/cupertino.dart';
import 'package:ncross/objects/crosssection.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:math';

class WeightedCrosssection {
  final int chainage;
  final double weight;

  const WeightedCrosssection({required this.chainage, required this.weight});
}

class CrosssectionsModel extends ChangeNotifier {
  final List<Crosssection> crosssections = [];
  List<WeightedCrosssection> normativeChainages = [];

  int _limitLeft = 0;
  int _limitRight = 30;
  int _startChainage = 0;
  int _endChainage = 10000;
  int _numNormatives = 3;

  int get startChainage {
    return _startChainage;
  }

  int get endChainage {
    return _endChainage;
  }

  int get numNormatives {
    return _numNormatives;
  }

  set numNormatives(int newNum) {
    _numNormatives = newNum;
    notifyListeners();
  }

  set startChainage(int newChainage) {
    _startChainage = newChainage;
    normativeChainages = [];
    notifyListeners();
  }

  set endChainage(int newChainage) {
    _endChainage = newChainage;
    normativeChainages = [];
    notifyListeners();
  }

  int get limitLeft {
    return _limitLeft;
  }

  int get limitRight {
    return _limitRight;
  }

  set limitLeft(int newLimit) {
    if (newLimit < left + 1) {
      newLimit = left.toInt() + 1;
    }
    if (newLimit >= _limitRight - 1) {
      newLimit = limitRight - 1;
    }

    _limitLeft = newLimit;

    normativeChainages = [];
    notifyListeners();
  }

  set limitRight(int newLimit) {
    if (newLimit < _limitLeft + 1) {
      newLimit = _limitLeft + 1;
    }
    if (newLimit > right - 1) {
      newLimit = right.toInt() - 1;
    }

    _limitRight = newLimit;
    normativeChainages = [];
    notifyListeners();
  }

  double get left {
    if (crosssections.isEmpty) return 0.0;
    return crosssections.map((e) => e.left).reduce(min);
  }

  double get right {
    if (crosssections.isEmpty) return 0.0;
    return crosssections.map((e) => e.right).reduce(max);
  }

  double get top {
    if (crosssections.isEmpty) return 0.0;
    return crosssections.map((e) => e.top).reduce(max);
  }

  double get bottom {
    if (crosssections.isEmpty) return 0.0;
    return crosssections.map((e) => e.bottom).reduce(min);
  }

  void reset() {
    crosssections.clear();
    notifyListeners();
  }

  void calculateNormative() async {
    normativeChainages.clear();
    for (Crosssection crosssection in crosssections) {
      if (crosssection.chainage < _startChainage ||
          crosssection.chainage > _endChainage) {
        continue;
      }

      normativeChainages.add(WeightedCrosssection(
          chainage: crosssection.chainage,
          weight: crosssection.weight(_limitLeft, _limitRight, bottom - 1.0)));
    }
    normativeChainages.sort((a, b) => a.weight.compareTo(b.weight));

    notifyListeners();
  }

  Future<void> uploadCrosssections() async {
    crosssections.clear();
    normativeChainages = [];

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['csv'],
    );

    if (result == null) return;

    final files = result.files;
    for (final file in files) {
      if (file.size > 50000) {
        // max 50K per csv
        continue;
      }

      final String fileContent =
          utf8.decode(List.from(file.bytes!), allowMalformed: true);

      try {
        int chainage = int.parse(file.name.split('_')[1].split('.')[0]);
        Crosssection crosssection =
            Crosssection.fromCsvString(fileContent, chainage);
        if (crosssection.points.isNotEmpty) {
          crosssections.add(crosssection);
        }
      } catch (e) {
        continue;
      }
    }

    if (crosssections.isNotEmpty) {
      notifyListeners();
    }
  }
}
