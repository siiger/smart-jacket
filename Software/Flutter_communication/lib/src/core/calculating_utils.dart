import 'package:smart_arrays_peaks/smart_arrays_peaks.dart';
import 'dart:typed_data';

class CalculatingUtil {
  CalculatingUtil._();
  //double frq = 9, irreg = 8, amp = 7;
  static double vAL0 = 100.0, nOISE = 0.01 * vAL0;

  static double findFreq(List<double> p0, List<DateTime> t0) {
    List<int> outFq = [1];
    Float64List p1 = new Float64List.fromList(p0);

    List<int> out = PeakPicker1D.detectPeaks(
        p1, 0, p1.length, 2 * nOISE, 0.001, PeakPicker1D.PICK_POSNEG, 0);

    double fq = 0;
    int j = 0, i = 0, n = t0.length;
    int dT = 60000; //millisecond
    DateTime tN = t0[n - 1];
    DateTime t00 = t0[0];

    while ((tN.difference(t00)).inMilliseconds >= dT) {
      j = i + 1;
      outFq.add(int.parse("0", radix: 10));

      while (((t0[j].difference(t00)).inMilliseconds <= dT) && (j + 1 < n)) {
        j++;
        for (int ii = 0; ii < out.length; ii++) {
          if (j == out[ii]) {
            outFq[i]++;
          }
        }
      }
      i++;
      t00 = t0[i];
    }

    double vSum = 0;
    for (int id = 0; id < i; id++) {
      vSum = vSum + outFq[id];
    }
    if (i != 0) {
      fq = (10 * vSum / (i)).floor() / 10.0;
    }

    return fq;
  }

  static double findIrregBr(List<double> p0, List<DateTime> t0) {
    //vector<int> outIr;
    Float64List p1 = new Float64List.fromList(p0);
    List<int> out = PeakPicker1D.detectPeaks(
        p1, 0, p1.length, 2 * nOISE, 0.001, PeakPicker1D.PICK_POSNEG, 0);
    double irreg = 0;
    int i = 0, n = out.length - 2;
    double vSum = 0;

    for (i = 0; i < n; i++) {
      vSum = vSum +
          ((t0[out[i + 1]].difference(t0[out[i]]).inMilliseconds +
                          t0[out[i + 1]]
                              .difference(t0[out[i + 2]])
                              .inMilliseconds)
                      .abs() /
                  (t0[out[i + 1]].difference(t0[out[i]]).inMilliseconds +
                      t0[out[i + 2]].difference(t0[out[i + 1]]).inMilliseconds))
              .toDouble();
    }

    if (i != 0) {
      irreg = (10 * (100 * vSum / (n - 1))).floor() / 10.0;
    }

    return irreg;
  }

  static double findAmp(List<double> p0) {
    double amp;
    Float64List p1 = new Float64List.fromList(p0);
    List<int> out = PeakPicker1D.detectPeaks(
        p1, 0, p1.length, 2 * nOISE, 0.001, PeakPicker1D.PICK_POSNEG, 0);

    int i = 0, n = out.length;
    double vSum = 0;

    for (i = 0; i < n; i++) {
      vSum = vSum + out[i];
    }

    if (i != 0) {
      amp = (10 * (vSum / (n))).floor() / 10.0;
    }

    return amp;
  }
}
