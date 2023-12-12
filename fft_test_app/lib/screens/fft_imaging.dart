  //import statements for all the packages/libraries
  import 'dart:math';
  import 'dart:async';
  import 'package:camera/camera.dart';
  import 'package:fl_chart/fl_chart.dart';
  import 'package:flutter/material.dart';
  import 'package:fftea/fftea.dart';
  import 'dart:typed_data';
  import 'package:usb_serial/transaction.dart';
  import 'package:usb_serial/usb_serial.dart';

  //Widget Class
  class FftImaging extends StatefulWidget {
    const FftImaging({super.key});

    @override
    State<FftImaging> createState() => _FftImagingState();
  }

  class _FftImagingState extends State<FftImaging> {

    //All the variables declared before the state initiates
    List<double> data = [];
    List<FlSpot> spots = [];
    UsbPort? _port;
    String _status = "Idle";
    List<Widget> _ports = [];
    String _serialData = "";
    List<double> numbers = [];
    List<FlSpot> prevSpots = [];

    StreamSubscription<String>? _subscription;
    Transaction<String>? _transaction;
    UsbDevice? _device;
    final TextEditingController _textController = TextEditingController();

      // Connect to USB device
    Future<bool> _connectTo(device) async {
      // Clean up existing connections and resources  
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
        // Disconnect if device is null
      if (device == null) {
        _device = null;
        setState(() {
          _status = "Disconnected";
        });
        return true;
      }
      // Create a new USB port
      _port = await device.create();
      if (await (_port!.open()) != true) {
        setState(() {
          _status = "Failed to open port";
        });
        return false;
      }
      _device = device;


      // Set USB port parameters
      await _port!.setDTR(true);
      await _port!.setRTS(true);
      await _port!.setPortParameters(
          38400, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
  // Set up USB transaction
      _transaction = Transaction.stringTerminated(
          _port!.inputStream as Stream<Uint8List>, Uint8List.fromList([0]));
    
      // Subscribe to USB data stream
      _subscription = _transaction!.stream.listen((String line) {
        _serialData += line;
        if (_serialData.length > 1000) {
          setState(() {});
        }
        // debugPrint(line);
      });

      setState(() {
        _status = "Connected";
      });

      return true;
    }

      // Get available USB ports
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
    // Initialize the state
    @override
    void initState() {
      // TODO: implement initState
      // Set up USB event stream and get available ports
      UsbSerial.usbEventStream!.listen((UsbEvent event) {
        _getPorts();
      });

      _getPorts();

      super.initState();
    }

      // Build the UI
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
                  
                      List<String> lines = _serialData.toString().split("\n");
                      numbers = [];
                      for (String line in lines) {
                        List<String> strings = line.trim().split(RegExp(r'\s+'));
                        _serialData += "$strings ";
                        for (String s in strings) {
                          if (double.tryParse(s) != null) {
                            try {
                              numbers.add(double.parse(s));
                            } catch (e) {}
                          }
                        }
                      }
                      if (_serialData.length > 25000) {
                        _serialData = "";
                      }
                      if (_status == "Connected") {
                        if (numbers.length > 100) {
                          FFT fft = FFT(numbers.length);
                          final fftResult = fft.realFft(numbers);
                          int N = fftResult.length;
                          int halfofN = (N / 2).round();
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


                          List<double> absvaluesMagnitude = magnitudeList
                              .map((value) =>
                                  value.x) // Assuming x and y are the same
                              .toList();
                          debugPrint(absvaluesMagnitude.join(" ").toString());
                          int lengthTime = numbers.length;
                          double Fs = 1024;
                          List<double> frequencies = List.generate(
                              lengthTime, (index) => index * Fs / lengthTime);
                          double middleDouble = frequencies.length / 2;
                          int middle;
                          middle = middleDouble.round();
                      

                          List<double> halfFreq = frequencies.sublist(0, middle);

                    
                          spots = halfFreq
                              .asMap()
                              .entries
                              .map((entry) => FlSpot(
                                  entry.value, absvaluesMagnitude[entry.key]))
                              .toList();
                          prevSpots = spots;
                        } else {
                          if (prevSpots.isNotEmpty) {
                            spots = prevSpots;
                          } else {
                            spots = [];
                          }
                        }

                      
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.9,
                              child: LineChart(
                                LineChartData(
                                  minX: 0, // Your min value for x-axis
                                  maxX: 50, // Your max value for x-axis
                                  minY: 0, // Your min value for y-axis
                                  maxY: 200, // Your max value for y-axis
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
                            ),
                          ],
                        );
                      } else {
                        return Center(
                            child: SingleChildScrollView(
                          child: Column(children: <Widget>[
                            Text(
                                _ports.isNotEmpty
                                    ? "Available Serial Ports"
                                    : "No serial devices available",
                                style: Theme.of(context).textTheme.titleLarge),
                            ..._ports,
                            Text('Status: $_status\n'),
                            Text('info: ${_port.toString()}\n'),
                        
                            Center(child: Text(numbers.join(" ").toString())),
                          ]),
                        ));
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
    