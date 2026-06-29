import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/category_utils.dart';

class LogoWidget extends StatelessWidget {
  final String name;
  final String category;
  final double size;
  final double borderRadius;
  final String? customLogoPath;
  final bool showBackground;

  const LogoWidget({
    super.key,
    required this.name,
    required this.category,
    this.size = 40,
    this.borderRadius = 12,
    this.customLogoPath,
    this.showBackground = true,
  });

  static String? getLogoUrl(String name) {
    String lowerName = name.toLowerCase().replaceAll(' ', '').replaceAll("'", "").replaceAll('-', '');
    Map<String, String> domains = {
      // Video / Movies
      'netflix': 'netflix.com',
      'spotify': 'spotify.com',
      'youtube': 'youtube.com',
      'youtubepremium': 'youtube.com',
      'disney+': 'disneyplus.com',
      'disneyplus': 'disneyplus.com',
      'primevideo': 'primevideo.com',
      'amazonprime': 'amazon.com',
      'hbo': 'hbo.com',
      'hbogo': 'hbo.com',
      'vidio': 'vidio.com',
      'viu': 'viu.com',
      'iqiyi': 'iq.com',
      'wetv': 'wetv.vip',
      'catchplay': 'catchplay.com',
      'appletv+': 'apple.com',
      'appletv': 'apple.com',
      'crunchyroll': 'crunchyroll.com',
      'molatv': 'mola.tv',
      'maxstream': 'telkomsel.com',
      'vision+': 'visionplus.id',
      'hulu': 'hulu.com',
      'paramount+': 'paramountplus.com',
      'peacock': 'peacocktv.com',
      'bilibili': 'bilibili.tv',
      'viki': 'viki.com',
      
      // Music
      'applemusic': 'apple.com',
      'joox': 'joox.com',
      'resso': 'resso.com',
      'soundcloud': 'soundcloud.com',
      'tidal': 'tidal.com',
      'deezer': 'deezer.com',
      'youtubemusic': 'youtube.com',
      'amazonmusic': 'amazon.com',
      'pandora': 'pandora.com',
      'audiomack': 'audiomack.com',
      
      // Cloud Storage
      'apple': 'apple.com',
      'appleone': 'apple.com',
      'icloud': 'icloud.com',
      'icloud+': 'icloud.com',
      'google': 'google.com',
      'googleone': 'google.com',
      'dropbox': 'dropbox.com',
      'onedrive': 'onedrive.live.com',
      'mega': 'mega.io',
      'box': 'box.com',
      'pcloud': 'pcloud.com',
      'mediafire': 'mediafire.com',
      'terabox': 'terabox.com',
      'sync': 'sync.com',
      
      // Software / AI
      'adobe': 'adobe.com',
      'adobecc': 'adobe.com',
      'microsoft': 'microsoft.com',
      'microsoft365': 'microsoft.com',
      'canva': 'canva.com',
      'canvapro': 'canva.com',
      'chatgpt': 'openai.com',
      'chatgptplus': 'openai.com',
      'notion': 'notion.so',
      'figma': 'figma.com',
      'github': 'github.com',
      'githubcopilot': 'github.com',
      'gitlab': 'gitlab.com',
      'bitbucket': 'bitbucket.org',
      'zoom': 'zoom.us',
      'slack': 'slack.com',
      'evernote': 'evernote.com',
      'midjourney': 'midjourney.com',
      'claude': 'anthropic.com',
      'gemini': 'google.com',
      'perplexity': 'perplexity.ai',
      'jetbrains': 'jetbrains.com',
      'autocad': 'autodesk.com',
      'grammarly': 'grammarly.com',
      
      // Gaming
      'playstation': 'playstation.com',
      'playstationplus': 'playstation.com',
      'xbox': 'xbox.com',
      'xboxgamepass': 'xbox.com',
      'nintendo': 'nintendo.com',
      'nintendoswitchonline': 'nintendo.com',
      'steam': 'steampowered.com',
      'eaplay': 'ea.com',
      'ubisoft+': 'ubisoft.com',
      'riotgames': 'riotgames.com',
      'robloxpremium': 'roblox.com',
      'epicgames': 'epicgames.com',
      'geforcenow': 'nvidia.com',
      'twitch': 'twitch.tv',
      'discordnitro': 'discord.com',
      
      // Social Media
      'twitter': 'twitter.com',
      'x': 'twitter.com',
      'discord': 'discord.com',
      
      // Utilities / Internet / Local Indonesia
      'pdam': 'pdam.co.id',
      'pln': 'pln.co.id',
      'indihome': 'indihome.co.id',
      'telkomsel': 'telkomsel.com',
      'byu': 'byu.id',
      'by.u': 'byu.id',
      'xl': 'xl.co.id',
      'indosat': 'indosatooredoo.com',
      'smartfren': 'smartfren.com',
      'tri': 'tri.co.id',
      'axis': 'axis.co.id',
      'myrepublic': 'myrepublic.co.id',
      'biznet': 'biznetnetworks.com',
      'firstmedia': 'firstmedia.com',
      'oxygen': 'oxygen.id',
      'bpjs': 'bpjs-kesehatan.go.id',
      'mncplay': 'mncplay.id',
      'cbn': 'cbn.id',
      'iconnet': 'iconnet.id',
      'megavision': 'megavision.net.id',
      'transvision': 'transvision.co.id',
      
      // Education
      'ruangguru': 'ruangguru.com',
      'zenius': 'zenius.net',
      'udemy': 'udemy.com',
      'coursera': 'coursera.org',
      'skillshare': 'skillshare.com',
      'duolingo': 'duolingo.com',
      'memrise': 'memrise.com',
      'masterclass': 'masterclass.com',
      'quipper': 'quipper.com',
      'brainly': 'brainly.co.id',
      'kahoot': 'kahoot.com',
      'linkedinlearning': 'linkedin.com',
      'edx': 'edx.org',
      'codecademy': 'codecademy.com',
      
      // Shopping
      'shopee': 'shopee.co.id',
      'tokopedia': 'tokopedia.com',
      'lazada': 'lazada.co.id',
      'blibli': 'blibli.com',
      'bukalapak': 'bukalapak.com',
      'amazon': 'amazon.com',
      
      'aliexpress': 'aliexpress.com',
      'gojek': 'gojek.com',
      'grab': 'grab.com',
      'maxim': 'taximaxim.com',
      'traveloka': 'traveloka.com',
      'tiket.com': 'tiket.com',
      'zalora': 'zalora.co.id',
      'sociolla': 'sociolla.com',
      'agoda': 'agoda.com',
      'airbnb': 'airbnb.com',
      'ebay': 'ebay.com',
      'alibaba': 'alibaba.com',
      
      // Newly added missing services
      'zapclinic': 'zapclinic.com',
      'msglow': 'msglowid.com',
      'thebodyshop': 'thebodyshop.co.id',
      'jobstreet': 'jobstreet.co.id',
      'kalibrr': 'kalibrr.com',
      'glints': 'glints.com',
      'alibabacloud': 'alibabacloud.com',
      'heroku': 'heroku.com',
      'hinge': 'hinge.co',
      'tantan': 'tantanapp.com',
      'badoo': 'badoo.com',
      'sketch': 'sketch.com',
      'invision': 'invisionapp.com',
      'freepikpremium': 'freepik.com',
      'firebase': 'firebase.google.com',
      'docker': 'docker.com',
      'postman': 'postman.com',
      'applefitness+': 'apple.com',
      'freeletics': 'freeletics.com',
      'niketrainingclub': 'nike.com',
      'kfc': 'kfc.co.id',
      'domino\'s': 'dominos.co.id',
      'pizzahut': 'pizzahut.co.id',
      'starbucksrewards': 'starbucks.co.id',
      'applearcade': 'apple.com',
      'lottemart': 'lottemart.co.id',
      'klikdokter': 'klikdokter.com',
      'gooddoctor': 'gooddoctor.co.id',
      'flo': 'flo.health',
      'f45': 'f45training.com',
      'gold\'sgym': 'goldsgym.com',
      'fithub': 'fithub.id',
      'mamikos': 'mamikos.com',
      'travelio': 'travelio.com',
      'rukita': 'rukita.co',
      'axamandiri': 'axa-mandiri.co.id',
      'aia': 'aia-financial.co.id',
      'fwd': 'fwd.co.id',
      'wakingup': 'wakingup.com',
      'riliv': 'riliv.co',
      'tempo': 'tempo.co',
      'wattpad': 'wattpad.com',
      'webtoon': 'webtoons.com',
      'bloomberg': 'bloomberg.com',
      'scribd': 'scribd.com',
      'nordpass': 'nordpass.com',
      'keeper': 'keepersecurity.com',
      'enpass': 'enpass.io',
      'roboform': 'roboform.com',
      'chewy': 'chewy.com',
      'royalcaninclub': 'royalcanin.com',
      'petloverscentre': 'petloverscentre.com',
      'applepodcasts': 'apple.com',
      'audible': 'audible.com',
      'storytel': 'storytel.com',
      'kakaopage': 'kakaopage.co.id',
      'trello': 'trello.com',
      'asana': 'asana.com',
      'monday.com': 'monday.com',
      'clickup': 'clickup.com',
      'obsidian': 'obsidian.md',
      'ikeafamily': 'ikea.co.id',
      'costco': 'costco.com',
      'mysuperindo': 'superindo.co.id',
      'cyberghost': 'cyberghostvpn.com',
      'protonvpn': 'protonvpn.com',
      'piavpn': 'privateinternetaccess.com',
      'kaspersky': 'kaspersky.com',
      'bitdefender': 'bitdefender.com',
      'microsoft365family': 'microsoft.com',
      'halo+': 'telkomsel.com',
      'booking.com': 'booking.com',
      'expedia': 'expedia.co.id',
      'reddoorz': 'reddoorz.com',
      'oyo': 'oyorooms.com',
      'flazzbca': 'bca.co.id',
      'emoneymandiri': 'bankmandiri.co.id',
      'brizzi': 'bri.co.id',
      'tapcashbni': 'bni.co.id',
      'kmtcommuterline': 'krl.co.id',
      'jaklingko': 'jaklingkoindonesia.co.id',
      'xpremium': 'x.com',
      'telegrampremium': 'telegram.org',
      'metaverified': 'meta.com',
      'snapchat+': 'snapchat.com',
    };
    
    // Explicit overrides for logos that fail or user uploaded
    Map<String, String> explicitUrls = {
      'pln': 'assets/logos/pln.png',
      'pdam': 'assets/logos/pdam.png',
      'indihome': 'assets/logos/indihome.png',
      'pegipegi': 'assets/logos/pegipegi.png',
      'mypertamina': 'assets/logos/mypertamina.png',
      'mcdonalds': 'assets/logos/mcdonalds.png',
      'alfagift': 'assets/logos/alfagift.png',
      'klikindomaret': 'assets/logos/klikindomaret.png',
      'telkom': 'assets/logos/telkom.png',
      'telkomindonesia': 'assets/logos/telkom.png',
      'ipl': 'assets/logos/ipl.png',
      'pgn': 'assets/logos/pgn.png',
      'duolingoplus': 'assets/logos/duolingoplus.png',
      'kost': 'assets/logos/kost.png',
    };

    if (explicitUrls.containsKey(lowerName)) {
      return explicitUrls[lowerName];
    }

    if (domains.containsKey(lowerName)) {
      final safeName = lowerName.replaceAll('\'', '').replaceAll('+', '');
      return 'assets/logos/$safeName.png';
    }
    
    // Guess domain if it's not in our downloaded list
    return 'https://www.google.com/s2/favicons?domain=$lowerName.com&sz=128';
  }

  @override
  Widget build(BuildContext context) {
    final catColor = CategoryUtils.getColor(category);
    final catIcon = CategoryUtils.getIcon(category);
    final url = getLogoUrl(name);

    Widget fallback = Container(
      width: size,
      height: size,
      decoration: showBackground ? BoxDecoration(
        color: catColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ) : null,
      child: Icon(catIcon, color: catColor, size: size * 0.5),
    );

    if (customLogoPath != null && customLogoPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.file(
          File(customLogoPath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback,
        ),
      );
    }

    if (url != null) {
      if (url.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.asset(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => fallback,
          ),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          headers: const {'User-Agent': 'SubTrackerApp/1.0'},
          errorBuilder: (context, error, stackTrace) => fallback,
        ),
      );
    }
    
    return fallback;
  }
}
