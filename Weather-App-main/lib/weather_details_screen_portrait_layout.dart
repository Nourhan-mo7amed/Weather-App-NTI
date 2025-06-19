import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/weather_model.dart';

class WeatherDetailsPortrait extends StatefulWidget {
  const WeatherDetailsPortrait({
    super.key,
    required this.weather,
  });

  final WeatherModel? weather;

  @override
  State<WeatherDetailsPortrait> createState() => _WeatherDetailsPortraitState();
}

class _WeatherDetailsPortraitState extends State<WeatherDetailsPortrait>
    with SingleTickerProviderStateMixin {
  late WeatherModel currentWeather;
  DateTime? dateTime;
  String searchQuery = '';
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  final String apiKey = 'YOUR_API_KEY_HERE'; 

  @override
  void initState() {
    super.initState();
    currentWeather = widget.weather!;
    dateTime = convertTimeStampsToHumanDateTime(currentWeather);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  DateTime convertTimeStampsToHumanDateTime(WeatherModel weather) {
    return DateTime.fromMillisecondsSinceEpoch(
      weather.list[0].timeStamps! * 1000,
    );
  }

  Future<WeatherModel> fetchWeatherByCity(String cityName) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast/daily?q=$cityName&cnt=7&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeatherModel.fromJson(data);
    } else {
      throw Exception('City not found');
    }
  }

  void _searchCity() async {
    if (searchQuery.trim().isEmpty) return;

    try {
      final newWeather = await fetchWeatherByCity(searchQuery.trim());

      setState(() {
        currentWeather = newWeather;
        dateTime = convertTimeStampsToHumanDateTime(newWeather);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('City not found or error fetching data'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _offsetAnimation,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => searchQuery = value,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter city name...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _searchCity,
                  child: const Icon(Icons.send),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            /// Date
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Date: ${dateTime!.year}/${dateTime!.month}/${dateTime!.day}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// Main Weather Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              color: const Color.fromARGB(255, 49, 37, 74).withOpacity(0.85),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    Text(
                      currentWeather.cityName!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/${currentWeather.list[0].icon}@2x.png',
                          height: 70,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${currentWeather.list[0].temp!.day!.toStringAsFixed(1)} °C',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: const [
                            Icon(Icons.water_drop, color: Colors.cyanAccent),
                            SizedBox(height: 4),
                            Text(
                              'Humidity',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        Column(
                          children: const [
                            Icon(Icons.air, color: Colors.lightBlueAccent),
                            SizedBox(height: 4),
                            Text(
                              'Wind',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          '${currentWeather.list[0].humidity}%',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          '${currentWeather.list[0].speed} km/h',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// Forecast
            Text(
              'Upcoming Forecast:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(currentWeather.list.length, (index) {
              final weather = currentWeather.list[index];
              final DateTime localDateTime =
                  DateTime.fromMillisecondsSinceEpoch(
                      weather.timeStamps! * 1000);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: const Color.fromARGB(255, 84, 63, 136).withOpacity(0.7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Image.asset(
                    'assets/images/${weather.icon}@2x.png',
                    height: 50,
                  ),
                  title: Text(
                    '${localDateTime.day}/${localDateTime.month}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Min: ${weather.temp!.min!.toStringAsFixed(0)}°C  •  Max: ${weather.temp!.max!.toStringAsFixed(0)}°C',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing:
                      const Icon(Icons.chevron_right, color: Colors.white),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
