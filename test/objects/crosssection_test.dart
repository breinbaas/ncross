import 'dart:io';

import 'package:ncross/objects/crosssection.dart';
import 'package:test/test.dart';
import 'package:path/path.dart';

void main() {
  group('Crosssection', () {
    final testDirectory = join(
      Directory.current.path,
      Directory.current.path.endsWith('test') ? '' : 'test',
    );

    test('fromCsvString generates a crosssection object', () async {
      final file = File(join(testDirectory, 'testdata/P1022/P1022_0400.csv'));
      String filename = basename(file.path);
      int chainage = int.parse(filename.split('_')[1].split('.')[0]);

      final data = await file.readAsString();

      Crosssection crosssection = Crosssection.fromCsvString(data, chainage);
      expect(crosssection.points.length, 76);
      expect(crosssection.chainage, 400);
    });
  });
}
