import 'package:flutter_test/flutter_test.dart';
import 'package:stitch_and_soul/data/models.dart';
import 'package:stitch_and_soul/features/measurements/measurement_screen.dart';

void main() {
  group('validateMeasurement', () {
    test('null is allowed (field is optional)', () {
      expect(
        validateMeasurement(
          field: 'bust',
          rawValue: null,
          units: UnitSystem.cm,
        ),
        isNull,
      );
    });

    test('value within cm bounds is allowed', () {
      expect(
        validateMeasurement(field: 'bust', rawValue: 90, units: UnitSystem.cm),
        isNull,
      );
    });

    test('value below cm bound is rejected', () {
      expect(
        validateMeasurement(field: 'bust', rawValue: 30, units: UnitSystem.cm),
        isNotNull,
      );
    });

    test('value above cm bound is rejected', () {
      expect(
        validateMeasurement(field: 'bust', rawValue: 200, units: UnitSystem.cm),
        isNotNull,
      );
    });

    test('inches are converted to cm before bounds check', () {
      // 60 in = 152.4 cm, which is within bust bounds (60-160).
      expect(
        validateMeasurement(
          field: 'bust',
          rawValue: 60,
          units: UnitSystem.inches,
        ),
        isNull,
      );
      // 80 in = 203.2 cm, above the upper bound.
      expect(
        validateMeasurement(
          field: 'bust',
          rawValue: 80,
          units: UnitSystem.inches,
        ),
        isNotNull,
      );
    });

    test('unknown field is permissive (no bounds to check)', () {
      expect(
        validateMeasurement(
          field: 'madeUp',
          rawValue: 999,
          units: UnitSystem.cm,
        ),
        isNull,
      );
    });
  });

  group('MeasurementProfile.displayString', () {
    test('formats in the chosen unit', () {
      const p = MeasurementProfile(units: UnitSystem.cm, bustCm: 90);
      expect(p.displayString(p.bustCm), '90.0 cm');
    });

    test('formats inches with two decimals', () {
      const p = MeasurementProfile(units: UnitSystem.inches, bustCm: 90);
      // 90 / 2.54 ≈ 35.43
      final s = p.displayString(p.bustCm);
      expect(s, contains('in'));
      expect(s, contains('35.4'));
    });

    test('returns null for null input', () {
      const p = MeasurementProfile(units: UnitSystem.cm);
      expect(p.displayString(null), isNull);
    });
  });
}
