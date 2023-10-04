import 'dart:convert';
// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/secret.dart';
// import 'package:weather_app/secret.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  @override
  void initState() {
    super.initState();
    weatherApi();
  }

  Future<Map<String, dynamic>> weatherApi() async {
    try {
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=London,uk&APPID=$secretKEY'),
      );

      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw data['message'];
      }
      return data;
      // data['list'][0]['main']['temp'];
    } catch (e) {
      throw '$e.message';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
          const SizedBox(
            width: 16,
          )
        ],
      ),
      body: FutureBuilder(
        future: weatherApi(),
        builder: (contaxt, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          final data = snapshot.data!;

          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                children: [
                  Center(
                    child: Container(
                      height: 200,
                      width: 300,
                      color: const Color.fromARGB(255, 92, 91, 91),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$currentTemp K',
                              style: const TextStyle(
                                  fontSize: 27, fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              currentSky == 'Clouds' || currentSky == 'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                              size: 80,
                            ),
                            Text('$currentSky'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        Text(
                          'Hourly forcast',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    // child: SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: Row(
                    //     children: [
                    //       for (int i = 0; i < 5; i++)
                    //         Weather_forcast_Widget(
                    //           icon: data['list'][i + 1]['weather'][0]['main'] ==
                    //                       'Clouds' ||
                    //                   data['list'][i + 1]['weather'][0]
                    //                           ['main'] ==
                    //                       'Rain'
                    //               ? Icons.cloud
                    //               : Icons.sunny,
                    //           label: data['list'][i + 1]['dt'].toString(),
                    //           temp: data['list'][i + 1]['main']['temp']
                    //               .toString(),
                    //         ),
                    //     ],
                    //   ),
                    // ),

                    child: SizedBox(
                      height: 80,
                      child: ListView.builder(
                        //used here listViewBuilder to make lazyLoading for good performance of app,
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (contaxt, index) {
                          final hourlyForcast = data['list'][index + 1];
                          final hourlySky =
                              data['list'][index + 1]['weather'][0]['main'];
                          final hourlyTemp =
                              hourlyForcast['main']['temp'].toString();
                          final time = DateTime.parse(hourlyForcast['dt_txt']);
                          return Weather_forcast_Widget(
                              icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,

                              //time
                              label: DateFormat.j().format(time),

                              //temperature in kelvin
                              temp: hourlyTemp);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        Text(
                          'Additional Information',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Info_Widget(
                            icon: Icons.cloud,
                            temp: '$currentHumidity',
                            label: 'Humidity'),
                        Info_Widget(
                            icon: Icons.sunny,
                            temp: '$currentWindSpeed',
                            label: 'Wind Speed'),
                        Info_Widget(
                            icon: Icons.beach_access,
                            temp: '$currentPressure',
                            label: 'Pressure'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ignore: camel_case_types
class Info_Widget extends StatelessWidget {
  final String label;
  final IconData icon;
  final String temp;
  const Info_Widget({
    super.key,
    required this.icon,
    required this.temp,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 100,
      child: Card(
        color: Colors.white30,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            Text(label),
            Text(
              temp,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: camel_case_types
class Weather_forcast_Widget extends StatelessWidget {
  final String label;
  final String temp;
  final IconData icon;
  const Weather_forcast_Widget({
    super.key,
    required this.icon,
    required this.label,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 100,
      child: Card(
        color: Colors.white30,
        child: Column(
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // style: TextStyle(
              //   overflow: TextOverflow.ellipsis,
              // ),
            ),
            Icon(icon),
            Text(temp),
          ],
        ),
      ),
    );
  }
}
