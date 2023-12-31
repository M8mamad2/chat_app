

import 'dart:convert';
import 'dart:math' as math;

List<double> loadParseJson(String jsonBody){
  final data = jsonDecode(jsonBody);
  final List<int> points = List.castFrom(data['data']);
  List<int> filteredData = [];

  const int samples= 256;
  final double blockSize = points.length / samples;

  for (int i = 0; i < samples; i++) {
    final double blockStart = blockSize * i; // the location of the first sample in the block
    int sum = 0;
    for (int j = 0; j < blockSize; j++) {
      sum = sum + points[(blockStart + j).toInt()].toInt(); // find the sum of all the samples in the block
    }
    filteredData.add((sum / blockSize)
        .round() // take the average of the block and add it to the filtered data
        .toInt()); // divide the sum by the block size to get the average
  }

  final maxNum = filteredData.reduce((a, b) => math.max(a.abs(), b.abs()));

  final double multiplier = math.pow(maxNum, -1).toDouble();
 
  return filteredData.map<double>((e) => (e * multiplier)).toList();


}