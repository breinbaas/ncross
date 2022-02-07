import 'dart:math';

class Point2D {
  final double l;
  final double z;

  const Point2D({required this.l, required this.z});
}

class CrosssectionCalculationException implements Exception {
  final String _message;

  CrosssectionCalculationException(this._message);

  @override
  String toString() {
    return _message;
  }
}

class Crosssection {
  final int chainage;
  final List<Point2D> points;

  const Crosssection({required this.chainage, required this.points});

  factory Crosssection.empty() {
    return const Crosssection(chainage: 0, points: []);
  }

  double get left {
    if (points.isEmpty) return 0.0;
    return points.map((e) => e.l).reduce(min);
  }

  double get right {
    if (points.isEmpty) return 0.0;
    return points.map((e) => e.l).reduce(max);
  }

  double get top {
    if (points.isEmpty) return 0.0;
    return points.map((e) => e.z).reduce(max);
  }

  double get bottom {
    if (points.isEmpty) return 0.0;
    return points.map((e) => e.z).reduce(min);
  }

  double weight(int lLeft, int lRight, double bottom) {
    double l = lLeft.toDouble();
    double weight = 0.0;
    while (l < lRight) {
      double l1 = l;
      double l2 = l + 0.1;
      double z1 = zAtl(l1.toDouble());
      double z2 = zAtl(l2.toDouble());
      double area = (l2 - l1) * ((z1 + z2) / 2 - bottom);
      weight += pow(area, 3);
      l += 0.1;
    }

    return weight;
  }

  double zAtl(double l) {
    for (int i = 1; i < points.length; i++) {
      Point2D p1 = points[i - 1];
      Point2D p2 = points[i];

      if ((p1.l <= l) & (l <= p2.l)) {
        return p1.z + (l - p1.l) / (p2.l - p1.l) * (p2.z - p1.z);
      }
    }

    throw CrosssectionCalculationException(
        "Could not calculate z at the given length ($l), check the limits [$left-$right]");
  }

  factory Crosssection.fromCsvString(String data, int chainage) {
    List<Point2D> points = [];
    List<String> lines = data.split('\n');
    for (int i = 0; i < lines.length; i++) {
      List<String> args = lines[i].split(',');
      if (args.length == 2) {
        try {
          points.add(Point2D(
              l: double.parse(args[0]), z: double.parse(args[1].trim())));
        } catch (_) {}
      }
    }

    if (points.isNotEmpty) {
      return Crosssection(chainage: chainage, points: points);
    } else {
      return Crosssection.empty();
    }
  }
}
