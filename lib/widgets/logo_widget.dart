import 'package:flutter/material.dart';
import '../utils/category_utils.dart';

class LogoWidget extends StatelessWidget {
  final String name;
  final String category;
  final double size;
  final double borderRadius;

  const LogoWidget({
    super.key,
    required this.name,
    required this.category,
    this.size = 40,
    this.borderRadius = 12,
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
      return 'https://www.google.com/s2/favicons?domain=${domains[lowerName]}&sz=128';
    }
    
    // Guess domain
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
      decoration: BoxDecoration(
        color: catColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(catIcon, color: catColor, size: size * 0.5),
    );

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
