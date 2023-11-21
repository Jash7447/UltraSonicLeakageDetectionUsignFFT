import 'dart:math';
import 'package:camera/camera.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fftea/fftea.dart';
import 'dart:typed_data';

class FftImaging extends StatefulWidget {
  const FftImaging({super.key});

  @override
  State<FftImaging> createState() => _FftImagingState();
}

class _FftImagingState extends State<FftImaging> {
  List<double> data = [];
  List<FlSpot> spots = [];

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

  String generateRandomData(int n) {
    final random = Random();
    final buffer = StringBuffer();
    for (int i = 0; i < n; i++) {
      buffer.writeln('${random.nextInt(20) + random.nextDouble()} ');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            // SizedBox(
            //   height: MediaQuery.of(context).size.height * 0, //camera ration
            //   child: controller == null
            //       ? const Center(child: Text("Loading Camera..."))
            //       : !controller!.value.isInitialized
            //           ? const Center(
            //               child: CircularProgressIndicator(),
            //             )
            //           : AspectRatio(
            //               aspectRatio: controller!.value.aspectRatio,
            //               child: CameraPreview(controller!)),
            // ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 1,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: const BoxDecoration(
                    border: Border.symmetric(
                        horizontal: BorderSide(color: Colors.black, width: 2))),
                child: Builder(
                  builder: (context) {
                    // if (snapshot.connectionState == ConnectionState.done) {
                    List<String> lines = generateRandomData(1000).split('\n');
                    List<double> numbers = [];
                    // debugPrint(lines.toString());
                    for (String line in lines) {
                      List<String> strings = line.trim().split(RegExp(r'\s+'));
                      for (String s in strings) {
                        try {
                          numbers.add(double.parse(s));
                        } catch (e) {
                          print('Could not parse "$s" as a double.');
                        }
                      }
                    }

                    // print(numbers);
                    // print("length=" + numbers.length.toString());

                    double interval = 1;
                    double currentTime = 0.0;
                    int currentIndex = 0;

                    Future<void> myFunction() async {
                      while (currentTime < numbers.length) {
                        data.addAll(
                            numbers.sublist(currentIndex, currentIndex + 50));
                        currentIndex += 1;
                        currentTime += interval;
                        await Future.delayed(const Duration(seconds: 1), () {
                          // print("object printed");
                          // print(data);
                          FFT fft = FFT(data.length);
                          final fftResult = fft.realFft(data);
                          int N = fftResult.length;
                          int halfofN = (fftResult.length / 2).round();
                          Float64x2List positiveFrequencies =
                              fftResult.sublist(0, halfofN);

                          List<Float64x2> magnitudeList =
                              List<Float64x2>.generate(halfofN, (int index) {
                            double real = positiveFrequencies[index].x;
                            double imag = positiveFrequencies[index].y;
                            double absValue =
                                sqrt(real * real + imag * imag) / 500;
                            return Float64x2(absValue, absValue);
                          });

                          Float64x2List magnitude =
                              Float64x2List.fromList(magnitudeList);

                          List<double> absvaluesMagnitude = magnitudeList
                              .map((value) =>
                                  value.x) // Assuming x and y are the same
                              .toList();

                          int lengthTime = data.length;
                          double Fs = 1 / 0.001;
                          List<double> frequencies = List.generate(
                              lengthTime, (index) => index * Fs / lengthTime);
                          int middle = (frequencies.length / 2).round();
                          List<double> halfFreq =
                              frequencies.sublist(0, middle);

                          Float64x2List freqResult = fftResult;
                          // debugPrint("FFT: $fft_result");
                          // debugPrint("ABS: $absValues_magnitude");
                          spots = halfFreq
                              .asMap()
                              .entries
                              .map((entry) => FlSpot(
                                  entry.value, absvaluesMagnitude[entry.key]))
                              .toList();
                          setState(() {});
                        });
                      }
                      // currentTime = 0;
                      myFunction();
                      data = List.filled(data.length, 0);
                    }

                    myFunction();

                    // print("N");
                    // print(fftResult.length);
                    // print(halfofN);
                    // print("magnitude");
                    // print(magnitude);
                    // print("finish");
                    // Print the frequency
                    // print(fft_result);
                    // print("object\n");
                    // print(half_freq);
                    // print("abs magnitude");
                    // print(absValues_magnitude);
                    // print(absValues_magnitude.length);
                    // print("half freq");
                    // print(half_freq.length);

                    //plot
                    return LineChart(
                      LineChartData(
                        minX: 0, // Your min value for x-axis
                        maxX: 500, // Your max value for x-axis
                        minY: 0, // Your min value for y-axis
                        maxY: 30, // Your max value for y-axis
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: false,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          )
                        ],
                      ),
                    );
                    // } else {
                    //   return const Text('No data');
                    // }
                    // } else {
                    //   return const CircularProgressIndicator();
                    //   //   return LineChart(
                    //   //     LineChartData(
                    //   //       minX: 0, // Your min value for x-axis
                    //   //       maxX: 100, // Your max value for x-axis
                    //   //       minY: 0, // Your min value for y-axis
                    //   //       maxY: 30, // Your max value for y-axis
                    //   //       gridData: const FlGridData(show: false),
                    //   //       titlesData: const FlTitlesData(
                    //   //         bottomTitles: AxisTitles(
                    //   //           sideTitles: SideTitles(
                    //   //             showTitles: true,
                    //   //             reservedSize: 22,
                    //   //           ),
                    //   //         ),
                    //   //         leftTitles: AxisTitles(
                    //   //           sideTitles: SideTitles(
                    //   //             showTitles: true,
                    //   //             reservedSize: 28,
                    //   //           ),
                    //   //         ),
                    //   //       ),
                    //   //       borderData: FlBorderData(show: false),
                    //   //       lineBarsData: [
                    //   //         LineChartBarData(
                    //   //           spots: spots,
                    //   //           isCurved: false,
                    //   //           dotData: const FlDotData(show: false),
                    //   //           belowBarData: BarAreaData(show: false),
                    //   //         )
                    //   //       ],
                    //   //     ),
                    //   //   );
                    // }
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
