import 'dart:ffi';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fftea/fftea.dart';

class FftImaging extends StatefulWidget {
  const FftImaging({super.key});

  @override
  State<FftImaging> createState() => _FftImagingState();
}

class _FftImagingState extends State<FftImaging> {
  Future<List<List<dynamic>>>? _csvData;
  Future<List<List<dynamic>>> readCSV() async {
    String timeCSVData =
        await rootBundle.loadString("assets/sine_wave_time.csv");
    String amplitudeCSVData =
        await rootBundle.loadString("assets/sine_wave_amplitude.csv");
    List<List<dynamic>> timeCSVTable =
        const CsvToListConverter().convert(timeCSVData);
    List<List<dynamic>> amplitudeCSVTable =
        const CsvToListConverter().convert(amplitudeCSVData);
    List<List<dynamic>> dataList = [];
    for (int i = 0; i < timeCSVTable.length; i++) {
      double time = double.parse(timeCSVTable[i][0].toString());
      double amplitude = double.parse(amplitudeCSVTable[i][0].toString());
      dataList.add([time, amplitude]);
    }

    return dataList;
  }

  Future<List<dynamic>> mockRead() async {
    String csvData = await rootBundle.loadString('assets/sine_wave_time.csv');
    List<dynamic> csvTable = const CsvToListConverter().convert(csvData);
    print(csvTable[1]);
    return csvTable;
  }

  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  XFile? image; //f
  loadCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras![0], ResolutionPreset.max);
      //cameras[0] = first camera, change to 1 to another camera

      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {
      print("NO any camera found");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    // mockRead();
    // _csvData = readCSV();
    loadCamera();
    print("This is a mock print");
    // mockRead();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: controller == null
                  ? const Center(child: Text("Loading Camera..."))
                  : !controller!.value.isInitialized
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : AspectRatio(
                          aspectRatio: controller!.value.aspectRatio,
                          child: CameraPreview(controller!)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: const BoxDecoration(
                    border: Border.symmetric(
                        horizontal: BorderSide(color: Colors.black, width: 2))),
                child: FutureBuilder<List<List<dynamic>>>(
                  future: readCSV(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<List<dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      List<double> time = [
                        0,
                        0.001,
                        0.002,
                        0.003,
                        0.004,
                        0.005,
                        0.006,
                        0.007,
                        0.008,
                        0.009,
                        0.01,
                        0.011,
                        0.012,
                        0.013,
                        0.014,
                        0.015,
                        0.016,
                        0.017,
                        0.018,
                        0.019,
                        0.02,
                        0.021,
                        0.022,
                        0.023,
                        0.024,
                        0.025,
                        0.026,
                        0.027,
                        0.028,
                        0.029,
                        0.03,
                        0.031,
                        0.032,
                        0.033,
                        0.034,
                        0.035,
                        0.036,
                        0.037,
                        0.038,
                        0.039,
                        0.04,
                        0.041,
                        0.042,
                        0.043,
                        0.044,
                        0.045,
                        0.046,
                        0.047,
                        0.048,
                        0.049,
                        0.05,
                        0.051,
                        0.052,
                        0.053,
                        0.054,
                        0.055,
                        0.056,
                        0.057,
                        0.058,
                        0.059,
                        0.06,
                        0.061,
                        0.062,
                        0.063,
                        0.064,
                        0.065,
                        0.066,
                        0.067,
                        0.068,
                        0.069,
                        0.07,
                        0.071,
                        0.072,
                        0.073,
                        0.074,
                        0.075,
                        0.076,
                        0.077,
                        0.078,
                        0.079,
                        0.08,
                        0.081,
                        0.082,
                        0.083,
                        0.084,
                        0.085,
                        0.086,
                        0.087,
                        0.088,
                        0.089,
                        0.09,
                        0.091,
                        0.092,
                        0.093,
                        0.094,
                        0.095,
                        0.096,
                        0.097,
                        0.098,
                        0.099,
                        0.1,
                        0.101,
                        0.102,
                        0.103,
                        0.104,
                        0.105,
                        0.106,
                        0.107,
                        0.108,
                        0.109,
                        0.11,
                        0.111,
                        0.112,
                        0.113,
                        0.114,
                        0.115,
                        0.116,
                        0.117,
                        0.118,
                        0.119,
                        0.12,
                        0.121,
                        0.122,
                        0.123,
                        0.124,
                        0.125,
                        0.126,
                        0.127,
                        0.128,
                        0.129,
                        0.13,
                        0.131,
                        0.132,
                        0.133,
                        0.134,
                        0.135,
                        0.136,
                        0.137,
                        0.138,
                        0.139,
                        0.14,
                        0.141,
                        0.142,
                        0.143,
                        0.144,
                        0.145,
                        0.146
                      ];
                      List<double> amplitude = [
                        0,
                        0.296794316,
                        0.583752504,
                        0.851560576,
                        1.091917487,
                        1.297965208,
                        1.464632442,
                        1.58887173,
                        1.669776282,
                        1.708570333,
                        1.708474634,
                        1.674456407,
                        1.612880174,
                        1.531081948,
                        1.436893912,
                        1.33814964,
                        1.242200942,
                        1.155476523,
                        1.083109810,
                        1.028658808,
                        0.993934873,
                        0.978950292,
                        0.981986984,
                        0.999780848,
                        1.027808949,
                        1.060660172,
                        1.092464651,
                        1.117353554,
                        1.129918864,
                        1.125642807,
                        1.101268497,
                        1.055087120,
                        0.987122271,
                        0.899198641,
                        0.794889589,
                        0.679345896,
                        0.559015604,
                        0.441271827,
                        0.333971384,
                        0.244971626,
                        0.181635632,
                        0.150356855,
                        0.15613329,
                        0.202218275,
                        0.289870406,
                        0.418219,
                        0.584254415,
                        0.782944841,
                        1.007473368,
                        1.249581663,
                        1.5,
                        1.748938018,
                        1.986606817,
                        2.203741053,
                        2.392089689,
                        2.544846021,
                        2.656991346,
                        2.725532011,
                        2.749616193,
                        2.730524202,
                        2.671533917,
                        2.577670681,
                        2.455358074,
                        2.311992050,
                        2.155465553,
                        1.993673676,
                        1.834030451,
                        1.683027440,
                        1.545861506,
                        1.426154603,
                        1.325782486,
                        1.244822230,
                        1.181620864,
                        1.132979655,
                        1.094441231,
                        1.060660172,
                        1.025832369,
                        0.984154748,
                        0.930284985,
                        0.859770869,
                        0.769420884,
                        0.657591325,
                        0.524370575,
                        0.371647724,
                        0.203060080,
                        0.023821859,
                        -0.159556037,
                        -0.339638276,
                        -0.508506516,
                        -0.658242647,
                        -0.781423651,
                        -0.871597015,
                        -0.923706621,
                        -0.934442006,
                        -0.902488498,
                        -0.828661813,
                        -0.715917787,
                        -0.569235636,
                        -0.395380945,
                        -0.202562039,
                        -7.96E-16,
                        0.202562039,
                        0.395380945,
                        0.569235636,
                        0.715917787,
                        0.828661813,
                        0.902488498,
                        0.934442006,
                        0.923706621,
                        0.871597015,
                        0.781423651,
                        0.658242647,
                        0.508506516,
                        0.339638276,
                        0.159556037,
                        -0.023821859,
                        -0.203060080,
                        -0.371647724,
                        -0.524370575,
                        -0.657591325,
                        -0.769420884,
                        -0.859770869,
                        -0.930284985,
                        -0.984154748,
                        -1.025832369,
                        -1.060660172,
                        -1.094441231,
                        -1.132979655,
                        -1.181620864,
                        -1.244822230,
                        -1.325782486,
                        -1.426154603,
                        -1.545861506,
                        -1.683027440,
                        -1.834030451,
                        -1.993673676,
                        -2.155465553,
                        -2.311992050,
                        -2.455358074,
                        -2.577670681,
                        -2.671533917,
                        -2.730524202,
                        -2.749616193,
                        -2.725532011,
                        -2.656991346,
                        -2.544846021,
                        -2.392089689
                      ];
                      // print(snapshot.data);
                      // if (snapshot.data != null) {
                      // for (var row in snapshot.data!) {
                      //   time.add(double.parse(row[0]
                      //       .toString())); // Assuming 'Time' is the first column
                      //   amplitude.add(double.parse(row[1]
                      //       .toString())); // Assuming 'Amplitude' is the second column
                      // }

                      // Perform the FFT
                      FFT fft = FFT(amplitude.length);
                      final freq = fft.realFft(amplitude);

                      // Convert the FFT output to a format suitable for fl_chart
                      List<FlSpot> spots = freq
                          .map((value) => FlSpot(value.x, value.y))
                          .toList();

                      // Plot the waveform and FFT result side by side
                      return LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                            )
                          ],
                        ),
                      );
                      // } else {
                      //   return const Text('No data');
                      // }
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
