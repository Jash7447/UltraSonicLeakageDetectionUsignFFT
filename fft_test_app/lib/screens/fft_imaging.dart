import 'dart:math';
import 'package:camera/camera.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fftea/fftea.dart';
import 'dart:typed_data';

class FftImaging extends StatefulWidget {
  const FftImaging({super.key});

  @override
  State<FftImaging> createState() => _FftImagingState();
}

class _FftImagingState extends State<FftImaging> {
  Future<List<List<dynamic>>>? _csvData;
  List<double> data = [];
  List<FlSpot> spots = [];
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

  String generateRandomData(int n) {
    final random = Random();
    final buffer = StringBuffer();
    for (int i = 0; i < n; i++) {
      buffer.writeln('${random.nextInt(10) + random.nextDouble()} ');
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
                child: FutureBuilder<List<List<dynamic>>>(
                  future: readCSV(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<List<dynamic>>> snapshot) {
                    // if (snapshot.connectionState == ConnectionState.done) {

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

                    List<String> lines = generateRandomData(10000).split('\n');
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

                    double interval = 50;
                    double currentTime = 0.0;
                    int currentIndex = 0;

                    Future<void> myFunction() async {
                      while (currentTime < numbers.length) {
                        data.addAll(
                            numbers.sublist(currentIndex, currentIndex + 50));
                        currentIndex += 1;
                        currentTime += interval;
                        await Future.delayed(const Duration(seconds: 2), () {
                          // print("object printed");
                          // print(data);
                          FFT fft = FFT(data.length);
                          final fft_result = fft.realFft(data);
                          Float64x2List fftResult = fft_result;
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

                          List<double> absValues_magnitude = magnitudeList
                              .map((value) =>
                                  value.x) // Assuming x and y are the same
                              .toList();

                          int length_time = data.length;
                          double Fs = 1 / 0.001;
                          List<double> frequencies = List.generate(
                              length_time, (index) => index * Fs / length_time);
                          int middle = (frequencies.length / 2).round();
                          List<double> half_freq =
                              frequencies.sublist(0, middle);

                          Float64x2List freq_result = fft_result;
                          // debugPrint("FFT: $fft_result");
                          // debugPrint("ABS: $absValues_magnitude");
                          spots = half_freq
                              .asMap()
                              .entries
                              .map((entry) => FlSpot(
                                  entry.value, absValues_magnitude[entry.key]))
                              .toList();
                          setState(() {});
                        });
                      }
                      // currentTime = 0;
                      // myFunction();
                      // data = List.filled(data.length, 0);
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
                        maxX: 10000, // Your max value for x-axis
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
