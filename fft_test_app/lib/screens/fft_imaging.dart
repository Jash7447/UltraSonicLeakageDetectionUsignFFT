import 'dart:math';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fftea/fftea.dart';
import 'dart:typed_data';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class FftImaging extends StatefulWidget {
  const FftImaging({super.key});

  @override
  State<FftImaging> createState() => _FftImagingState();
}

class _FftImagingState extends State<FftImaging> {
  List<double> data = [];
  List<FlSpot> spots = [];
  UsbPort? _port;
  String _status = "Idle";
  List<Widget> _ports = [];
  String _serialData = "";
  List<double> numbers = [];

  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  UsbDevice? _device;
  final TextEditingController _textController = TextEditingController();

  Future<bool> _connectTo(device) async {
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    if (_transaction != null) {
      _transaction!.dispose();
      _transaction = null;
    }

    if (_port != null) {
      _port!.close();
      _port = null;
    }

    if (device == null) {
      _device = null;
      setState(() {
        _status = "Disconnected";
      });
      return true;
    }

    _port = await device.create();
    if (await (_port!.open()) != true) {
      setState(() {
        _status = "Failed to open port";
      });
      return false;
    }
    _device = device;

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(
        38400, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _subscription =
        (_port!.inputStream as Stream<Uint8List>).listen((Uint8List data) {
      setState(() {
        _serialData += "${String.fromCharCodes(data)} ";
        // print("Data: ${_serialData.length}");
      });
    }) as StreamSubscription<String>?;

    setState(() {
      _status = "Connected";
    });
    return true;
  }

  void _getPorts() async {
    _ports = [];
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (!devices.contains(_device)) {
      _connectTo(null);
    }
    print(devices);

    for (var device in devices) {
      _ports.add(ListTile(
          leading: const Icon(Icons.usb),
          title: Text(device.productName!),
          subtitle: Text(device.manufacturerName!),
          trailing: ElevatedButton(
            child: Text(_device == device ? "Disconnect" : "Connect"),
            onPressed: () {
              _connectTo(_device == device ? null : device).then((res) {
                _getPorts();
              });
            },
          )));
    }

    setState(() {
      print(_ports);
    });
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
    loadCamera();
    // print("This is a mock print");
    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      _getPorts();
    });

    _getPorts();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
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
                    // List<String> lines = generateRandomData(1000).split(' ');
                    List<String> lines = _serialData.toString().split(" ");
                    numbers = [];
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
                    if (_status == "Connected" && numbers.isNotEmpty) {
                      FFT fft = FFT(numbers.length);
                      final fftResult = fft.realFft(numbers);
                      int N = fftResult.length;
                      int halfofN = (fftResult.length / 2).round();
                      Float64x2List positiveFrequencies =
                          fftResult.sublist(0, halfofN);

                      List<Float64x2> magnitudeList =
                          List<Float64x2>.generate(halfofN, (int index) {
                        double real = positiveFrequencies[index].x;
                        double imag = positiveFrequencies[index].y;
                        double absValue = sqrt(real * real + imag * imag) / 500;
                        return Float64x2(absValue, absValue);
                      });

                      Float64x2List magnitude =
                          Float64x2List.fromList(magnitudeList);

                      List<double> absvaluesMagnitude = magnitudeList
                          .map((value) =>
                              value.x) // Assuming x and y are the same
                          .toList();

                      int lengthTime = numbers.length;
                      double Fs = 1 / 0.001;
                      List<double> frequencies = List.generate(
                          lengthTime, (index) => index * Fs / lengthTime);
                      int middle = (frequencies.length / 2).round();
                      List<double> halfFreq = frequencies.sublist(0, middle);

                      Float64x2List freqResult = fftResult;
                      // debugPrint("FFT: $fft_result");
                      // debugPrint("ABS: $absValues_magnitude");
                      spots = halfFreq
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                              entry.value, absvaluesMagnitude[entry.key]))
                          .toList();
                      //plot
                      return Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.4, //camera ration
                            child: controller == null
                                ? const Center(child: Text("Loading Camera..."))
                                : !controller!.value.isInitialized
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : AspectRatio(
                                        aspectRatio:
                                            controller!.value.aspectRatio,
                                        child: CameraPreview(controller!)),
                          ),
                          LineChart(
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
                          ),
                        ],
                      );
                    } else {
                      return Center(
                          child: Column(children: <Widget>[
                        Text(
                            _ports.isNotEmpty
                                ? "Available Serial Ports"
                                : "No serial devices available",
                            style: Theme.of(context).textTheme.titleLarge),
                        ..._ports,
                        Text('Status: $_status\n'),
                        Text('info: ${_port.toString()}\n'),
                        // ListTile(
                        //   title: TextField(
                        //     controller: _textController,
                        //     decoration: const InputDecoration(
                        //       border: OutlineInputBorder(),
                        //       labelText: 'Text To Send',
                        //     ),
                        //   ),
                        //   trailing: ElevatedButton(
                        //     onPressed: _port == null
                        //         ? null
                        //         : () async {
                        //             if (_port == null) {
                        //               return;
                        //             }
                        //             String data = "${_textController.text}\r\n";
                        //             await _port!.write(
                        //                 Uint8List.fromList(data.codeUnits));
                        //             _textController.text = "";
                        //           },
                        //     child: const Text("Send"),
                        //   ),
                        // ),
                        // Text("Result Data",
                        //     style: Theme.of(context).textTheme.titleLarge),
                        Center(child: Text(numbers.length.toString())),
                        Text(_serialData), //this is the data
                      ]));
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
