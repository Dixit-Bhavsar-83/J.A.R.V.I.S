// ╭────────────────────────────────────────────────────────────────────────────╮
// │  lib/pages/about_page.dart — heading big, paragraph small, 3 languages    │
// ╰────────────────────────────────────────────────────────────────────────────╯
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jarvis/controller/settings_controller.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  String selectedLang = 'English';
  String displayedText = '';
  int _charIndex = 0;
  late final AnimationController _fadeController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
        ..forward();
  late final Animation<double> _fadeAnimation =
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

  // ───────────────────────────────────── aboutText ────────────────────────────
  final Map<String, String> aboutText = {
    'English': '''
🙏 About Me & Code Studio83

Hello! I'm Dixit Bhavsar, the proud founder of Code Studio83 — a creative tech company passionate about building the future with AI tools, smart UI projects, and AI‑powered websites.

From developing chat‑based learning apps to handwritten notes generators and intelligent assistants, I started this journey with a single vision: to use AI and design to simplify real‑world problems for students, teachers, and creators.

💡 Our AI Projects & Tools

At Code Studio83, we've created multiple innovative tools, including:

• GitaAI – Your spiritual guide for Bhagavad Gita with AI‑powered shlok explanations, notes & chat  
• Jarvis AI Assistant – A custom voice‑controlled assistant for productivity and smart responses  
• RachnaCare AI – An intelligent tool to analyze medical X‑rays and generate reports  
• Tuition Management App – Manages fees, schedules, and generates PDFs for educational institutes  
• Birthday Portal (AI Powered) – Personalized Gemini AI‑based celebration web portals  
• Handwritten Notes Generator – Converts PDFs to clean notes in English, Hindi, and Gujarati  
• Students' Study Companion – Upload your notes, chat with AI, get instant answers

And many more are coming under Code Studio83 soon!

🌟 My Inspirations & Support

Behind every achievement stands a pillar of strength, guidance, and encouragement.

I am deeply grateful to Manish Vyas Sir and Rachana Vyas Mam — two extraordinary mentors who have been my greatest source of inspiration. Their unwavering belief in my abilities, their knowledge, and their dedication to teaching have shaped not just my skills, but also my values. Manish Sir's logical and mathematical clarity, and Rachana Mam's emotional support and subject‑wise guidance, helped me grow personally and academically.

I also owe everything to my Mom and Dad, whose endless love, sacrifices, and tireless efforts are the true foundation of my journey. Their constant encouragement, silent strength, and belief in my dreams keep me moving forward every single day.

🧠 Why I Created Jarvis & More

This project, Jarvis, is not just a virtual assistant — it's a reflection of the real support system that powers me every day. Through this AI‑powered journey, I hope to inspire others to build boldly, think differently, and never forget the hands that lifted them.''',

    // ───────────────────────────────────── Hindi ─────────────────────────────
    'Hindi': '''
🙏 मेरे बारे में और Code Studio83

नमस्ते! मैं दीक्षित भावसार हूँ, Code Studio83 का संस्थापक — एक क्रिएटिव टेक कंपनी जो AI टूल्स, स्मार्ट UI प्रोजेक्ट्स और AI‑पावर्ड वेबसाइट्स के ज़रिए भविष्य गढ़ने के लिए समर्पित है।

चैट‑आधारित लर्निंग ऐप्स से लेकर हस्तलिखित नोट जनरेटर्स और इंटेलिजेंट असिस्टेंट्स तक, यह यात्रा मैंने एक ही उद्देश्य से शुरू की: छात्रों, शिक्षकों और क्रिएटर्स की वास्तविक समस्याएँ AI और डिज़ाइन से सरल बनाना।

💡 हमारे AI प्रोजेक्ट्स व टूल्स

Code Studio83 में हमने कई इनोवेटिव टूल बनाए हैं, जैसे—

• GitaAI – भगवद्‑गीता का आपका आध्यात्मिक गाइड (AI‑आधारित श्लोक व्याख्या, नोट्स, चैट)  
• Jarvis AI Assistant – प्रोडक्टिविटी के लिए कस्टम वॉइस‑कंट्रोल्ड असिस्टेंट  
• RachnaCare AI – मेडिकल एक्स‑रे का विश्लेषण कर रिपोर्ट तैयार करने वाला टूल  
• Tuition Management App – फ़ीस, शेड्यूल मैनेज करता है और PDF जनरेट करता है  
• Birthday Portal (AI Powered) – Gemini‑AI आधारित पर्सनलाइज़्ड सेलिब्रेशन पोर्टल  
• Handwritten Notes Generator – PDF को साफ़ हस्तलिखित नोट्स में बदले (अंग्रेज़ी, हिंदी, गुजराती)  
• Students' Study Companion – नोट्स अपलोड करें, AI से चैट करें, तुरंत उत्तर पाएँ

और भी कई इनोवेशन जल्द ही Code Studio83 के तहत आ रहे हैं!

🌟 मेरी प्रेरणाएँ व समर्थन

हर सफल कदम के पीछे मार्गदर्शन और प्रेरणा का स्तंभ होता है।

मैं मनिष व्यास सर और रचना व्यास मैम का दिल से आभारी हूँ — ये दो असाधारण गुरु मेरी सबसे बड़ी प्रेरणा रहे हैं। उनकी अटूट आस्था, ज्ञान और शिक्षण‑समर्पण ने मेरी स्किल्स ही नहीं, मेरे जीवन‑मूल्यों को भी गढ़ा। मनिष सर की तार्किक स्पष्टता और रचना मैम का भावनात्मक सहारा मुझे व्यक्तिगत व शैक्षणिक रूप से आगे बढ़ाता रहा।

मैं अपने माता‑पिता का भी ऋणी हूँ, जिनका अथाह प्रेम, त्याग और प्रेरणा मेरी यात्रा की असली बुनियाद हैं। उनका विश्वास मुझे हर दिन आगे बढ़ने की शक्ति देता है।

🧠 मैंने Jarvis व अन्य प्रोजेक्ट्स क्यों बनाए

Jarvis सिर्फ़ एक वर्चुअल असिस्टेंट नहीं — यह उस समर्थन‑तंत्र का प्रतिबिंब है जो मुझे हर दिन शक्ति देता है। इस AI‑यात्रा के माध्यम से मैं दूसरों को भी साहसपूर्वक निर्माण करने, अलग सोचने और उन हाथों को न भूलने के लिए प्रेरित करना चाहता हूँ जिन्होंने उन्हें उठाया।''',

    // ───────────────────────────────────── Gujarati ──────────────────────────
    'Gujarati': '''
🙏 મારા વિશે અને Code Studio83

નમસ્કાર! હું દિક્ષિત ભાવસાર, Code Studio83 નો સંસ્થાપક — એક ક્રિએટિવ ટેક કંપની જે AI ટૂલ્સ, સ્માર્ટ UI પ્રોજેક્ટ્સ અને AI‑પાવર્ડ વેબસાઇટ્સ દ્વારા ભવિષ્ય ગોઠવવા માટે સમર્પિત છે.

ચેટ‑આધારિત લર્નિંગ ઍપ, હસ્તલિખિત નોટ જનરેટર અને બુદ્ધિશાળી સહાયકોની આ યાત્રા મેં એક જ દ્રષ્ટિથી શરૂ કરી: AI અને ડિઝાઇનની મદદથી વિદ્યાર્થીઓ, શિક્ષકો અને ક્રિએટરોની વાસ્તવિક સમસ્યાઓ સરળ કરવી.

💡 અમારા AI પ્રોજેકટ્સ અને ટૂલ્સ

Code Studio83 માં અમે ઘણા નવીન ટૂલ્સ બનાવ્યા છે, જેમ કે—

• GitaAI – AI શક્તિશાળી શ્લોક વિગત, નોંધો અને ચેટ સાથે તમારો આધ્યાત્મિક માર્ગદર્શક  
• Jarvis AI Assistant – પ્રોડક્ટિવિટી માટે કસ્ટમ વૉઇસ‑કંટ્રોલ્ડ સહાયક  
• RachnaCare AI – મેડિકલ X‑Ray વિશ્લેષણ કરીને રિપોર્ટ બનાવતું બુદ્ધિશાળી ટૂલ  
• Tuition Management App – ફીસ, શિડ્યૂલ મેનેજ કરે અને PDF જનરેટ કરે  
• Birthday Portal (AI Powered) – Gemini‑AI આધારિત વ્યક્તિગત ઉજવણી પોર્ટલ  
• Handwritten Notes Generator – PDF ને અંગ્રેજી, હિન્દી, ગુજરાતી ભાષામાં સ્વચ્છ હસ્તલિખિત નોંધોમાં બદલે  
• Students' Study Companion – નોંધો અપલોડ કરો, AI સાથે ચેટ કરો, તરત જવાબ મેળવો

અને Code Studio83 હેઠળ ઘણા વધુ નવીન પ્રોજેકટ્સ જલ્દી આવી રહ્યા છે!

🌟 моей પ્રેરણા અને આધાર

દરેક સિદ્ધિ પાછળ શક્તિ, માર્ગદર્શન અને ઉત્સાહનો સ્તંભ છુપાયેલો હોય છે.

હું મનિષ વ્યાસ સર અને રચના વ્યાસ મેમનો દિલથી આભારી છું — આ બે અસાધારણ મેન્ટર્સ મારી સૌથી મોટી પ્રેરણા છે. તેમની અવિરત શ્રદ્ધા, જ્ઞાન અને શિક્ષણ‑પ્રતિબદ્ધતાએ મારી કુશળતાઓને જ નહીં, પરંતુ મારા મૂલ્યોને પણ ઘડ્યા. મનિષ સરની તર્કશક્તિ અને રચના મેમનો ભાવનાત્મક સહારો мене વ્યક્તિગત અને શૈક્ષણિક રીતે આગળ વધાર્યો.

મારા મા‑પિતા પ્રત્યે હું ખૂબજ ઋણી છું, જેમનો અનંત પ્રેમ, ત્યાગ અને પ્રોત્સાહન моей યાત્રાની સાચી આધારશિલા છે. તેમનો વિશ્વાસ меня هر દિવસ આગળ વધવાની શક્તિ આપે છે.

🧠 મેં Jarvis અને અન્ય પ્રોજેકટ્સ શા માટે બનાવ્યાં

Jarvis માત્ર એક વર્ચ્યુઅલ સહાયક નથી — તે રોજ мене શક્તિ આપતી વાસ્તવિક આધારતંત્રનો પ્રતિબિંબ છે. આ AI‑યાત્રા દ્વારા હું બીજાઓને પણ બહાદુરીથી સર્જન કરવા, અલગ રીતે વિચારવા અને વાંચન કરનાર હાથે ભૂલ ન કરવા માટે પ્રેરેવું છું.''',
  };
  // ───────────────────────────────────────────────────────────────────────────

  void _speak() async {
    await _tts.setLanguage(
      selectedLang == 'Hindi'
          ? 'hi-IN'
          : selectedLang == 'Gujarati'
              ? 'gu-IN'
              : 'en-US',
    );
    await _tts.speak(aboutText[selectedLang]!);
  }

  void _startTyping() {
    displayedText = '';
    _charIndex = 0;
    Future.doWhile(() async {
      if (_charIndex < aboutText[selectedLang]!.length) {
        await Future.delayed(const Duration(milliseconds: 15));
        setState(() => displayedText += aboutText[selectedLang]![_charIndex++]);
        return true;
      }
      return false;
    });
  }

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>();
    final cs = Theme.of(context).colorScheme;
    final font = GoogleFonts.getFont(SettingsController.fontNames[s.fontIdx]);

    // Split current displayedText into heading + rest (first blank line separator)
    final int sep = displayedText.indexOf('\n\n');
    final String heading = sep == -1 ? displayedText : displayedText.substring(0, sep);
    final String body = sep == -1 ? '' : displayedText.substring(sep + 2);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('About'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: _speak,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<String>(
                value: selectedLang,
                dropdownColor: cs.surface,
                style: TextStyle(color: cs.onSurface, fontFamily: font.fontFamily),
                underline: const SizedBox(),
                onChanged: (v) {
                  setState(() {
                    selectedLang = v!;
                    _startTyping();
                  });
                },
                items: ['English', 'Hindi', 'Gujarati']
                    .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 15,               // paragraph छोटा
                        height: 1.5,
                        fontFamily: font.fontFamily,
                      ),
                      children: [
                        TextSpan(
                          text: heading.isEmpty ? '' : '$heading\n\n',
                          style: TextStyle(
                            fontSize: 22,           // heading बड़ा
                            fontWeight: FontWeight.bold,
                            fontFamily: font.fontFamily,
                            color: cs.onSurface,
                          ),
                        ),
                        TextSpan(text: body),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
