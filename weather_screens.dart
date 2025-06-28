// ╭───────────────────────────────────────────────────────────────╮
// │   lib/screens/weather/weather_screens.dart                   │
// │   Dynamic Weather Screens (Pick, GPS, Settings)              │
// ╰───────────────────────────────────────────────────────────────╯
//  Features
//  • PickLocationScreen — live auto‑complete from OpenWeather Geo API
//  • CurrentLocationScreen — GPS weather
//  • WeatherSettingsScreen — dummy toggles
//  Requirements: http, geolocator, google_fonts, lottie

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'weather_ui.dart';  
 // kCard, kBgTop, kBgBottom, kPrimary, kApiKey, getWeatherIcon, CurrentWeather

// ───────── helpers ─────────────────────────────────────────────
TextStyle txt(double s, [FontWeight w = FontWeight.w600]) =>
    GoogleFonts.poppins(fontSize: s, color: Colors.white, fontWeight: w);

class CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const CircleBtn({required this.icon, this.onTap, super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: kCard, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white),
        ),
      );
}

String getWeatherIcon(String iconCode) {
  if (iconCode.contains('11') || iconCode.contains('13')) return 'assets/lottie/thunderstorm.json';
  if (iconCode.contains('09') || iconCode.contains('10')) return 'assets/lottie/cloud_rain.json';
  return 'assets/lottie/sun_cloud.json';
}

// ╭────────────────────────── PickLocationScreen ─────────────────────────╮
class PickLocationScreen extends StatefulWidget {
  const PickLocationScreen({super.key});
  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  final TextEditingController _c = TextEditingController();
  List<_GeoCity> _cities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNearby();
  }

  Future<void> _loadNearby() async {
    setState(() => _loading = true);
    try {
      final pos = await Geolocator.getCurrentPosition();
      final url =
          'https://api.openweathermap.org/geo/1.0/reverse?lat=${pos.latitude}&lon=${pos.longitude}&limit=8&appid=$kApiKey';
      final r = await http.get(Uri.parse(url));
      if (r.statusCode == 200) {
        final List data = json.decode(r.body);
        _cities = data.map((e) => _GeoCity.fromJson(e)).toList();
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _search(String q) async {
    if (q.isEmpty) return _loadNearby();
    setState(() => _loading = true);
    final url =
        'https://api.openweathermap.org/geo/1.0/direct?q=$q&limit=20&appid=$kApiKey';
    final r = await http.get(Uri.parse(url));
    if (r.statusCode == 200) {
      final List data = json.decode(r.body);
      _cities = data.map((e) => _GeoCity.fromJson(e)).toList();
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBgTop,
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [kBgTop, kBgBottom])),
          child: SafeArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  CircleBtn(icon: Icons.arrow_back_ios_new, onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 16),
                  Text('स्थान चुनें', style: txt(20)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _c,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: kCard,
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    hintText: 'City / Village खोजें...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                  onChanged: _search,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: kPrimary))
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 3 / 4,
                        ),
                        itemCount: _cities.length,
                        itemBuilder: (_, i) => _CityBox(city: _cities[i], onSelect: (name) => Navigator.pop(context, name)),
                      ),
              ),
            ]),
          ),
        ),
      );
}

class _CityBox extends StatelessWidget {
  final _GeoCity city;
  final ValueChanged<String> onSelect;
  const _CityBox({required this.city, required this.onSelect});

  Future<_CityWeather> _fetchWeather() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=${city.lat}&lon=${city.lon}&appid=$kApiKey&units=metric';
    final r = await http.get(Uri.parse(url));
    if (r.statusCode != 200) throw Exception('err');
    final j = json.decode(r.body);
    return _CityWeather(temp: (j['main']['temp'] as num).toDouble(), icon: j['weather'][0]['icon']);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_CityWeather>(
        future: _fetchWeather(),
        builder: (ctx, s) {
          if (!s.hasData) {
            return Container(
              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(24)),
              child: const Center(child: CircularProgressIndicator(color: kPrimary, strokeWidth: 1.5)),
            );
          }
          final w = s.data!;
          return GestureDetector(
            onTap: () => onSelect(city.name),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(24)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Lottie.asset(getWeatherIcon(w.icon), height: 48),
                  Text('${w.temp.round()}°', style: txt(28)),
                  Text(city.name, style: txt(12, FontWeight.normal)),
                  Text(city.country, style: txt(10, FontWeight.normal).copyWith(color: Colors.white54)),
                ],
              ),
            ),
          );
        },
      );
}

class _GeoCity {
  final String name;
  final String country;
  final String? state;
  final double lat;
  final double lon;
  _GeoCity({required this.name, required this.country, this.state, required this.lat, required this.lon});
  factory _GeoCity.fromJson(Map<String, dynamic> j) => _GeoCity(
        name: j['name'],
        country: j['country'],
        state: j['state'],
        lat: (j['lat'] as num).toDouble(),
        lon: (j['lon'] as num).toDouble(),
      );
}

class _CityWeather {
  final double temp;
  final String icon;
  _CityWeather({required this.temp, required this.icon});
}

// ╭──────────────────────── CurrentLocationScreen ───────────────╮
class CurrentLocationScreen extends StatelessWidget {
  const CurrentLocationScreen({super.key});
  Future<CurrentWeather> _getWeatherFromLocation() async {
    final position = await Geolocator.getCurrentPosition();
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$kApiKey&units=metric';
    final r = await http.get(Uri.parse(url));
    if (r.statusCode != 200) throw Exception('Failed to load weather');
    return CurrentWeather.fromJson(json.decode(r.body));
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBgTop,
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [kBgTop, kBgBottom])),
          child: FutureBuilder<CurrentWeather>(
            future: _getWeatherFromLocation(),
            builder: (ctx, s) {
              if (s.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator(color: kPrimary));
              }
              if (s.hasError) return Center(child: Text(s.error.toString(), style: txt(14)));
              final w = s.data!;
              return Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Lottie.asset(getWeatherIcon(w.icon), height: 200),
                  const SizedBox(height: 12),
                  Text(w.city, style: txt(26)),
                  Text('${w.temp.round()}°C', style: txt(48)),
                ]),
              );
            },
          ),
        ),
      );
}

// ╭──────────────────────── WeatherSettingsScreen ───────────────╮
class WeatherSettingsScreen extends StatelessWidget {
  const WeatherSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBgTop,
        appBar: AppBar(title: const Text('Weather Settings'), backgroundColor: kBgTop, elevation: 0),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Units', style: txt(18)),
            const SizedBox(height: 12),
            SwitchListTile(
              value: true,
              onChanged: (_) {},
              title: Text('Use Metric Units (°C)', style: txt(14)),
              activeColor: kPrimary,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            Text('Notifications', style: txt(18)),
            const SizedBox(height: 12),
            SwitchListTile(
              value: false,
              onChanged: (_) {},
              title: Text('Daily Forecast Reminder', style: txt(14)),
              activeColor: kPrimary,
              contentPadding: EdgeInsets.zero,
            ),
          ]),
        ),
      );
}
