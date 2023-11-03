import 'dart:io';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fftea/fftea.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<List<List<dynamic>>> readCSV() async {
    String csvData =
        await rootBundle.loadString('assets/sine_wave_samples.csv');
    List<List<dynamic>> csvTable = CsvToListConverter().convert(csvData);
    print(csvTable);
    return csvTable;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('FFT Plot'),
        ),
        body: FutureBuilder<List<List<dynamic>>>(
          future: readCSV(),
          builder: (BuildContext context,
              AsyncSnapshot<List<List<dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<dynamic> time = [];
              List<dynamic> amplitude = [];
              if (snapshot.data != null) {
                for (var row in snapshot.data!) {
                  time.add(row[0]); // Assuming 'Time' is the first column
                  amplitude
                      .add(row[1]); // Assuming 'Amplitude' is the second column
                }
              } else {
                return Text('No data');
              }

              // Perform the FFT
              int N = time.length; // Number of data points
              double Fs = 1 / (time[1] - time[0]); // Sampling frequency

              // Create an FFT object
              final fft = FFT(N);

              // Perform the FFT on the amplitude data
              final freq =
                  fft.realFft(amplitude.map((x) => x as double).toList());

              // Convert the FFT result into a list of charts.Series
              List<charts.Series<dynamic, num>> seriesList = [
                charts.Series<dynamic, num>(
                  id: 'Freq',
                  colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                  domainFn: (item, _) => item.real,
                  measureFn: (item, _) => item.imaginary,
                  data: freq,
                )
              ];

              // Plot the waveform and FFT result side by side
              return charts.LineChart(seriesList);
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
