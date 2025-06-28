// ╭──────────────────────────────────────────────────────────────────────────────╮
// │  lib/screens/weather/weather_ui.dart                                        │
// │  Weather Module v3 – GPS, 5‑day, i18n, day/night, share                     │
// ╰──────────────────────────────────────────────────────────────────────────────╯
//  Requires : http, google_fonts, lottie, intl, geolocator, share_plus
//  Assets   : assets/lottie/*.json  (sun_cloud.json, clouds.json, cloud_rain.json …)
//  API Key  : 26743f98a998988ffc214afb422739e6

// ignore_for_file: use_build_context_synchronously, unused_import

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';              // ← add to pubspec
// Give alias to weather_screens
import 'weather_screens.dart' as screens;
import 'pick_location_screen.dart'; // Keep this clean





// ─── Theme ────────────────────────────────────────────────────────────────────
const kBgTop = Color(0xFF161A44);
const kBgBottom = Color(0xFF301566);
const kCard = Color(0xFF231D4F);
const kPrimary = Color(0xFF8F7CFF);
const kApiKey = '26743f98a998988ffc214afb422739e6';

TextStyle txt(double s, [FontWeight w = FontWeight.w600]) =>
    GoogleFonts.poppins(fontSize: s, color: Colors.white, fontWeight: w);

// ─── Simple i18n ─────────────────────────────────────────────────────────────
enum Lang { en, hi, gu }
ValueNotifier<Lang> kLang = ValueNotifier(Lang.en);

const _t = {
  'Humidity': {'en': 'Humidity', 'hi': 'नमी', 'gu': 'ભેજ'},
  'Wind': {'en': 'Wind', 'hi': 'हवा', 'gu': 'પવન'},
  'Forecast Report': {
    'en': 'Forecast Report',
    'hi': 'मौसम पूर्वानुमान',
    'gu': 'આગાહી રિપોર્ટ'
  },
  'Now': {'en': 'Now', 'hi': 'अभी', 'gu': 'હમણાં'},
  'Sunrise': {'en': 'Sunrise', 'hi': 'सूर्योदय', 'gu': 'સૂર્યોદય'},
  'Sunset': {'en': 'Sunset', 'hi': 'सूर्यास्त', 'gu': 'સૂર્યાસ્ત'},
  'Updated': {'en': 'Updated', 'hi': 'अपडेट', 'gu': 'અપડેટ'},
  'My Location': {'en': 'My Location', 'hi': 'मेरा स्थान', 'gu': 'મારું સ્થાન'},
};
String t(String key) => _t[key]?[kLang.value.name] ?? key;

// ─── Helpers ─────────────────────────────────────────────────────────────────
String getIcon(String code) {
  if (code.contains('11') || code.contains('13')) return 'assets/lottie/thunderstorm.json';
  if (code.contains('09') || code.contains('10')) return 'assets/lottie/cloud_rain.json';
  if (code.contains('50')) return 'assets/lottie/fog.json';
  if (code.contains('04') || code.contains('03') || code.contains('02')) return 'assets/lottie/clouds.json';
  return 'assets/lottie/sun_cloud.json';
}

// ─── Models ──────────────────────────────────────────────────────────────────
class CurrentWeather {
  final String city;
  final double temp;
  final String icon;
  final String desc;
  final int humidity;
  final double wind;
  final int sunrise, sunset;
  final double lat, lon;
  CurrentWeather({
    required this.city,
    required this.temp,
    required this.icon,
    required this.desc,
    required this.humidity,
    required this.wind,
    required this.sunrise,
    required this.sunset,
    required this.lat,
    required this.lon,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> j) => CurrentWeather(
        city: j['name'],
        temp: (j['main']['temp'] as num).toDouble(),
        icon: j['weather'][0]['icon'],
        desc: j['weather'][0]['description'],
        humidity: j['main']['humidity'],
        wind: (j['wind']['speed'] as num).toDouble(),
        sunrise: j['sys']['sunrise'],
        sunset: j['sys']['sunset'],
        lat: (j['coord']['lat'] as num).toDouble(),
        lon: (j['coord']['lon'] as num).toDouble(),
      );
}

class HourlyWeather {
  final DateTime time;
  final double temp;
  final String icon;
  HourlyWeather({required this.time, required this.temp, required this.icon});
  factory HourlyWeather.fromJson(Map<String, dynamic> j) => HourlyWeather(
        time: DateTime.parse(j['dt_txt']),
        temp: (j['main']['temp'] as num).toDouble(),
        icon: j['weather'][0]['icon'],
      );
}

class DailyForecast {
  final String day;
  final double temp;
  final String icon;
  DailyForecast({required this.day, required this.temp, required this.icon});
}

// ─── Service ─────────────────────────────────────────────────────────────────
class WeatherService {
  static Future<CurrentWeather> current(String city) async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$kApiKey&units=metric&lang=${kLang.value.name}';
    final r = await http.get(Uri.parse(url));
    if (r.statusCode != 200) throw 'Error ${r.statusCode}';
    return CurrentWeather.fromJson(json.decode(r.body));
  }

  static Future<CurrentWeather> currentByCoords(double lat, double lon) async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$kApiKey&units=metric&lang=${kLang.value.name}';
    final r = await http.get(Uri.parse(url));
    if (r.statusCode != 200) throw 'Error ${r.statusCode}';
    return CurrentWeather.fromJson(json.decode(r.body));
  }

  static Future<List<HourlyWeather>> forecast(double lat, double lon) async {
    final url = 'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$kApiKey&units=metric&lang=${kLang.value.name}';
    final r = await http.get(Uri.parse(url));
    if (r.statusCode != 200) throw 'Error';
    return (json.decode(r.body)['list'] as List).take(8).map((e) => HourlyWeather.fromJson(e)).toList();
  }

  static Future<List<DailyForecast>> forecast5Days(double lat, double lon) async {
    final url = 'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$kApiKey&units=metric&lang=${kLang.value.name}';
    final r = await http.get(Uri.parse(url));
    if (r.statusCode != 200) throw 'Error';
    final data = json.decode(r.body)['list'] as List;
    final Map<String, List<HourlyWeather>> dailyMap = {};
    for (var e in data) {
      final h = HourlyWeather.fromJson(e);
      final day = DateFormat('yyyy-MM-dd').format(h.time);
      dailyMap.putIfAbsent(day, () => []).add(h);
    }
    return dailyMap.entries.take(5).map((e) {
      final avgTemp = e.value.map((h) => h.temp).reduce((a, b) => a + b) / e.value.length;
      final iconMid = e.value[e.value.length ~/ 2].icon;
      final dayName = DateFormat('EEE').format(DateTime.parse(e.key));
      return DailyForecast(day: dayName, temp: avgTemp, icon: iconMid);
    }).toList();
  }
}

// ─── Location Service ────────────────────────────────────────────────────────
class LocationService {
  static Future<Position> getCurrent() async {
    bool ok = await Geolocator.isLocationServiceEnabled();
    if (!ok) throw 'Location services disabled';
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    if (p == LocationPermission.denied || p == LocationPermission.deniedForever) {
      throw 'Permission denied';
    }
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}

// ─── Widgets ────────────────────────────────────────────────────────────────
class CircleBtn extends StatelessWidget {
  final IconData icon; final VoidCallback? onTap;
  const CircleBtn({super.key, required this.icon, this.onTap});
  @override
  Widget build(BuildContext c) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: kCard, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}

class HourCard extends StatelessWidget {
  final HourlyWeather h; const HourCard(this.h, {super.key});
  @override
  Widget build(BuildContext c) {
    final label = h.time.hour == DateTime.now().hour ? t('Now') : DateFormat('h a').format(h.time);
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(24)),
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: txt(11, FontWeight.normal)),
        Lottie.asset(getIcon(h.icon), height: 34),
        Text('${h.temp.round()}°', style: txt(12)),
      ]),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value; final IconData icon;
  const _StatTile({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext c) => Column(children:[
    Icon(icon, color: Colors.white60, size: 20), const SizedBox(height:4),
    Text(value, style: txt(14)),
    Text(label, style: txt(12, FontWeight.normal).copyWith(color: Colors.white38)),
  ]);
}

// ─── Main Home Screen ────────────────────────────────────────────────────────
class WeatherHomeScreen extends StatefulWidget {
  final String defaultCity; const WeatherHomeScreen({super.key, this.defaultCity='Ahmedabad'});
  @override State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  final List<String> _cities = [];
  late PageController _pg;
  @override void initState(){super.initState(); _cities.add(widget.defaultCity); _pg = PageController();}

  @override
  Widget build(BuildContext ctx) {
    // Day / Night gradient
    final hour = DateTime.now().hour;
    final bool night = hour < 6 || hour > 18;
    final Color bg1 = night ? Colors.black : kBgTop;
    final Color bg2 = night ? const Color(0xFF0D0D2B) : kBgBottom;

    return Scaffold(
      backgroundColor:bg1,
      appBar: AppBar(
        backgroundColor:Colors.transparent,elevation:0,
        leading:IconButton(icon:const Icon(Icons.arrow_back,color:Colors.white70),onPressed:()=>Navigator.pop(ctx)),
        actions:[
         IconButton(
                icon: const Icon(Icons.share, color: Colors.white70),
                onPressed: () {
                Share.share('Check out the weather with my Jarvis Weather app!');
            },
          ),
          IconButton(  // GPS current location
            tooltip:t('My Location'),
            icon:const Icon(Icons.gps_fixed,color:Colors.white70),
            onPressed:() async {
              try{
                final pos=await LocationService.getCurrent();
                final cw=await WeatherService.currentByCoords(pos.latitude,pos.longitude);
                if(!_cities.contains(cw.city)){
                  setState((){_cities.add(cw.city); _pg.jumpToPage(_cities.length-1);});
                }
              }catch(e){
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content:Text(e.toString())));
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[bg1,bg2])),
        child:ValueListenableBuilder(
          valueListenable:kLang,
          builder:(_, __, ___)=>PageView.builder(
            controller:_pg,
            itemCount:_cities.length,
            itemBuilder:(_,i)=>_CityPage(city:_cities[i]),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:kPrimary,
        child:const Icon(Icons.add),
        onPressed:() async {
        final sel = await pickCity(ctx);
          if(sel!=null && sel.isNotEmpty && !_cities.contains(sel)){
            setState((){_cities.add(sel); _pg.jumpToPage(_cities.length-1);});
          }
        },
      ),
    );
  }
}


// ─── Single City Page ────────────────────────────────────────────────────────
class _CityPage extends StatelessWidget {
  final String city; const _CityPage({required this.city});
  @override Widget build(BuildContext ctx) => FutureBuilder<CurrentWeather>(
    future:WeatherService.current(city),
    builder:(_,s){
      if(!s.hasData){
        if(s.hasError) return Center(child:Text(s.error.toString(),style:txt(14)));
        return const Center(child:CircularProgressIndicator(color:kPrimary));
      }
      final cw=s.data!;
      final updated=DateFormat('h:mm a').format(DateTime.now());

      return Column(children:[
        const SizedBox(height:16),
        Text(cw.city,style:txt(28)),
        Text('${cw.temp.round()}°',style:txt(60)),
        Text(cw.desc,style:txt(14,FontWeight.normal).copyWith(color:Colors.white70)),
        Text('${t('Updated')}: $updated',style:txt(11,FontWeight.normal).copyWith(color:Colors.white38)),
        Expanded(child:Lottie.asset(getIcon(cw.icon),height:300,fit:BoxFit.contain)),
        FutureBuilder<List<HourlyWeather>>(
          future:WeatherService.forecast(cw.lat,cw.lon),
          builder:(_,h){
            if(!h.hasData) return const SizedBox(height:110);
            return SizedBox(
              height:110,
              child:ListView.separated(
                padding:const EdgeInsets.symmetric(horizontal:24),scrollDirection:Axis.horizontal,
                itemCount:h.data!.length,
                separatorBuilder:(_,__)=>const SizedBox(width:16),
                itemBuilder:(_,i)=>HourCard(h.data![i]),
              ),
            );
          },
        ),
        Padding(
          padding:const EdgeInsets.symmetric(vertical:16),
          child:Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[
            _StatTile(label:t('Humidity'),value:'${cw.humidity}%',icon:Icons.water_drop),
            _StatTile(label:t('Wind'),value:'${cw.wind} km/h',icon:Icons.air),
          ]),
        ),
        // Sunrise / Sunset
        Padding(
          padding:const EdgeInsets.symmetric(horizontal:16),
          child:Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[
            _StatTile(label:t('Sunrise'),value:DateFormat('h:mm a').format(DateTime.fromMillisecondsSinceEpoch(cw.sunrise*1000)),icon:Icons.wb_twilight),
            _StatTile(label:t('Sunset'),value:DateFormat('h:mm a').format(DateTime.fromMillisecondsSinceEpoch(cw.sunset*1000)),icon:Icons.nights_stay),
          ]),
        ),
        const SizedBox(height:12),
        CircleBtn(
          icon:Icons.show_chart,
          onTap:() async {
            final forecast=await WeatherService.forecast5Days(cw.lat,cw.lon);
            if(ctx.mounted){
              Navigator.push(ctx,MaterialPageRoute(builder:(_)=>ForecastReportScreen(current:cw,forecast:forecast)));
            }
          },
        ),
        const SizedBox(height:16),
      ]);
    },
  );
}

// ─── Forecast Report Screen (5‑Day) ──────────────────────────────────────────
class ForecastReportScreen extends StatelessWidget {
  final CurrentWeather current;
  final List<DailyForecast> forecast;
  const ForecastReportScreen({super.key, required this.current, required this.forecast});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor:kBgTop,
    body:SafeArea(
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Padding(
          padding:const EdgeInsets.all(16),
          child:Row(children:[
            CircleBtn(icon:Icons.arrow_back_ios,onTap:()=>Navigator.pop(context)),
            const SizedBox(width:16),
            Text(t('Forecast Report'),style:txt(20)),
          ]),
        ),
        Expanded(
          child:ListView.separated(
            padding:const EdgeInsets.all(16),
            separatorBuilder:(_,__)=>const SizedBox(height:12),
            itemCount:forecast.length,
            itemBuilder:(_,i){
              final f=forecast[i];
              return Container(
                padding:const EdgeInsets.all(16),
                decoration:BoxDecoration(color:kCard,borderRadius:BorderRadius.circular(24)),
                child:Row(children:[
                  SizedBox(height:50,width:50,child:Lottie.asset(getIcon(f.icon))),
                  const SizedBox(width:12),
                  Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                    Text(f.day,style:txt(16)),
                    Text('${f.temp.toStringAsFixed(1)}°C',style:txt(14,FontWeight.normal)),
                  ]),
                  const Spacer(),
                  Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
                    Text(current.desc,style:txt(14,FontWeight.normal)),
                    Text('${current.humidity}% ${t('Humidity')} • ${current.wind} km/h ${t('Wind')}',
                        style:txt(12,FontWeight.normal).copyWith(color:Colors.white54)),
                  ]),
                ]),
              );
            },
          ),
        ),
      ]),
    ),
  );
}

// ─── Weather Sharer Helper ───────────────────────────────────────────────────
class WeatherSharer {
  static void shareCurrentWeather(String city, double temp, String desc) {
    final message =
        '📍 $city\n🌡️ Temperature: ${temp.round()}°C\n🌤️ Condition: $desc\n\nCheck weather with my Jarvis Weather app!';
    Share.share(message);
  }
}

Future<String?> pickCity(BuildContext context) async =>
    await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const PickLocationScreen()),
    );
