// ╭──────────────────────────────────────────────────────────────╮
// │  pick_location_screen.dart                                   │
// │  • Live auto‑suggest search (GeoDB – India)                  │
// │  • Returns the tapped place‑name back to WeatherHomeScreen   │
// ╰──────────────────────────────────────────────────────────────╯
//  Requires : http  |  uses constants & helpers from weather_ui.dart

// ignore_for_file: library_private_types_in_public_api
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'weather_ui.dart';          // kBgTop, kBgBottom, kCard, txt(), CircleBtn

const _rapidKey  = '80bf67e8edmsh3637a881eb2fca7p1d183bjsn1ed048fafdc8';
const _rapidHost = 'wft-geo-db.p.rapidapi.com';

class PickLocationScreen extends StatefulWidget {
  const PickLocationScreen({super.key});
  @override
  _PickLocationScreenState createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  final TextEditingController _ctl = TextEditingController();
  Timer? _debounce;
  List<String> _results = [];
  bool _loading = false;

  // ─── Call GeoDB cities API (India only) ──────────────────────
  Future<void> _search(String q) async {
    if (q.isEmpty) return setState(() => _results = []);
    setState(() => _loading = true);

    final uri = Uri.parse(
      'https://$_rapidHost/v1/geo/cities'
      '?namePrefix=$q&countryIds=IN&limit=10',
    );

    try {
      final res = await http.get(uri, headers: {
        'X-RapidAPI-Key':  _rapidKey,
        'X-RapidAPI-Host': _rapidHost,
      });

      if (res.statusCode == 200) {
        final list = (json.decode(res.body)['data'] as List)
            .map((e) => e['city'].toString())
            .toSet()                       // duplicates हटाओ
            .toList();
        setState(() => _results = list);
      }
    } catch (_) {/* ignore network errors for now */}
    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    _ctl.addListener(() {
      _debounce?.cancel();
      _debounce =
          Timer(const Duration(milliseconds: 300), () => _search(_ctl.text));
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBgTop,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kBgTop, kBgBottom]),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔙 Back + Title
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    CircleBtn(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 16),
                    Text('Select Location', style: txt(20)),
                  ]),
                ),

                // 🔍 Search box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _ctl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: kCard,
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white70),
                      hintText: 'Search city / village…',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 📍 Results (no explicit loader – results replace instantly)
                Expanded(
                  child: _results.isEmpty && !_loading
                      ? Center(
                          child: Text('No result',
                              style: txt(14, FontWeight.normal)
                                  .copyWith(color: Colors.white54)),
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (_, i) {
                            final place = _results[i];
                            return ListTile(
                              tileColor: kCard,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              leading: const Icon(Icons.location_on,
                                  color: Colors.white),
                              title: Text(place, style: txt(15)),
                              onTap: () => Navigator.pop(context, place),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
}
