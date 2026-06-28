import 'package:flutter/material.dart';

class AppExamples {
  static final Map<String, List<Map<String, dynamic>>> data = {
    'AI tools': [
      {'name': 'ChatGPT Plus', 'color': const Color(0xFF10A37F), 'icon': Icons.smart_toy},
      {'name': 'Claude Pro', 'color': const Color(0xFFD97757), 'icon': Icons.smart_toy},
      {'name': 'Gemini Advanced', 'color': const Color(0xFF1A73E8), 'icon': Icons.smart_toy},
      {'name': 'Perplexity Pro', 'color': const Color(0xFF21BCA5), 'icon': Icons.search},
      {'name': 'Midjourney', 'color': const Color(0xFF000000), 'icon': Icons.brush},
      {'name': 'GitHub Copilot', 'color': const Color(0xFF000000), 'icon': Icons.code},
      {'name': 'Grammarly', 'color': const Color(0xFF15C39A), 'icon': Icons.edit},
    ],
    'Automotive': [
      {'name': 'Tesla Premium', 'color': const Color(0xFFE82127), 'icon': Icons.directions_car},
      {'name': 'SiriusXM', 'color': const Color(0xFF0000EB), 'icon': Icons.radio},
      {'name': 'OnStar', 'color': const Color(0xFF005596), 'icon': Icons.directions_car},
      {'name': 'Gojek', 'color': const Color(0xFF00AA13), 'icon': Icons.motorcycle},
      {'name': 'Grab', 'color': const Color(0xFF00B14F), 'icon': Icons.motorcycle},
      {'name': 'Maxim', 'color': const Color(0xFFFFCC00), 'icon': Icons.motorcycle},
      {'name': 'myPertamina', 'color': const Color(0xFFE22028), 'icon': Icons.local_gas_station},
    ],
    'Bills & utilities': [
      {'name': 'PDAM', 'color': const Color(0xFF2563EB), 'icon': Icons.water_drop},
      {'name': 'PLN', 'color': const Color(0xFFF59E0B), 'icon': Icons.electric_bolt},
      {'name': 'IndiHome', 'color': const Color(0xFFED1C24), 'icon': Icons.wifi},
      {'name': 'First Media', 'color': const Color(0xFFED1C24), 'icon': Icons.wifi},
      {'name': 'MyRepublic', 'color': const Color(0xFF90278E), 'icon': Icons.wifi},
      {'name': 'Biznet', 'color': const Color(0xFF8DC63F), 'icon': Icons.wifi},
      {'name': 'BPJS', 'color': const Color(0xFF00A859), 'icon': Icons.health_and_safety},
      {'name': 'Telkomsel', 'color': const Color(0xFFED1C24), 'icon': Icons.phone_android},
      {'name': 'XL', 'color': const Color(0xFF0030FF), 'icon': Icons.phone_android},
      {'name': 'Indosat', 'color': const Color(0xFFFFCC00), 'icon': Icons.phone_android},
      {'name': 'Smartfren', 'color': const Color(0xFFE3000F), 'icon': Icons.phone_android},
      {'name': 'Tri', 'color': const Color(0xFF000000), 'icon': Icons.phone_android},
      {'name': 'PGN', 'color': const Color(0xFF00569D), 'icon': Icons.local_fire_department},
      {'name': 'Telkom', 'color': const Color(0xFFED1C24), 'icon': Icons.phone},
    ],
    'Beauty & Grooming': [
      {'name': 'Sociolla Box', 'color': const Color(0xFFE84C88), 'icon': Icons.spa},
      {'name': 'Erha Clinic', 'color': const Color(0xFF00569D), 'icon': Icons.spa},
      {'name': 'Natasha', 'color': const Color(0xFF00963F), 'icon': Icons.spa},
    ],
    'Career': [
      {'name': 'LinkedIn Premium', 'color': const Color(0xFF0A66C2), 'icon': Icons.work},
      {'name': 'Glassdoor', 'color': const Color(0xFF0CAA41), 'icon': Icons.work},
      {'name': 'Indeed', 'color': const Color(0xFF2164F3), 'icon': Icons.work},
    ],
    'Charity & Donations': [
      {'name': 'Kitabisa', 'color': const Color(0xFF00A5CF), 'icon': Icons.volunteer_activism},
      {'name': 'Dompet Dhuafa', 'color': const Color(0xFF00963F), 'icon': Icons.volunteer_activism},
      {'name': 'UNICEF', 'color': const Color(0xFF00AEFF), 'icon': Icons.volunteer_activism},
      {'name': 'BAZNAS', 'color': const Color(0xFF005A30), 'icon': Icons.volunteer_activism},
      {'name': 'Rumah Zakat', 'color': const Color(0xFFF9A825), 'icon': Icons.volunteer_activism},
      {'name': 'Yatim Mandiri', 'color': const Color(0xFFE65100), 'icon': Icons.volunteer_activism},
    ],
    'Cloud platforms': [
      {'name': 'AWS', 'color': const Color(0xFFFF9900), 'icon': Icons.cloud},
      {'name': 'Google Cloud', 'color': const Color(0xFF4285F4), 'icon': Icons.cloud},
      {'name': 'Azure', 'color': const Color(0xFF0089D6), 'icon': Icons.cloud},
      {'name': 'DigitalOcean', 'color': const Color(0xFF0080FF), 'icon': Icons.cloud},
    ],
    'Cloud storage': [
      {'name': 'Google One', 'color': const Color(0xFF4285F4), 'icon': Icons.cloud},
      {'name': 'iCloud+', 'color': const Color(0xFF000000), 'icon': Icons.cloud},
      {'name': 'Dropbox', 'color': const Color(0xFF0061FE), 'icon': Icons.cloud},
      {'name': 'OneDrive', 'color': const Color(0xFF00A4EF), 'icon': Icons.cloud},
      {'name': 'Mega', 'color': const Color(0xFFD9272E), 'icon': Icons.cloud},
      {'name': 'Box', 'color': const Color(0xFF0061D5), 'icon': Icons.cloud},
      {'name': 'pCloud', 'color': const Color(0xFF00B0FF), 'icon': Icons.cloud},
      {'name': 'MediaFire', 'color': const Color(0xFF1271D2), 'icon': Icons.cloud},
      {'name': 'TeraBox', 'color': const Color(0xFF0A65FF), 'icon': Icons.cloud},
    ],
    'Communication': [
      {'name': 'Zoom', 'color': const Color(0xFF2D8CFF), 'icon': Icons.video_call},
      {'name': 'Slack', 'color': const Color(0xFF4A154B), 'icon': Icons.chat},
      {'name': 'Discord Nitro', 'color': const Color(0xFF5865F2), 'icon': Icons.chat},
      {'name': 'Microsoft Teams', 'color': const Color(0xFF6264A7), 'icon': Icons.chat},
    ],
    'Creator memberships': [
      {'name': 'Patreon', 'color': const Color(0xFFFF424D), 'icon': Icons.favorite},
      {'name': 'KaryaKarsa', 'color': const Color(0xFF6B48FF), 'icon': Icons.favorite},
      {'name': 'YouTube Channel', 'color': const Color(0xFFFF0000), 'icon': Icons.play_arrow},
      {'name': 'Trakteer', 'color': const Color(0xFFDB2D2E), 'icon': Icons.local_cafe},
    ],
    'Dating': [
      {'name': 'Tinder Plus', 'color': const Color(0xFFFE3C72), 'icon': Icons.favorite},
      {'name': 'Bumble Premium', 'color': const Color(0xFFFFC629), 'icon': Icons.favorite},
      {'name': 'OkCupid', 'color': const Color(0xFF3B5998), 'icon': Icons.favorite},
      {'name': 'Omi', 'color': const Color(0xFFFF4B4B), 'icon': Icons.favorite},
    ],
    'Design': [
      {'name': 'Canva Pro', 'color': const Color(0xFF00C4CC), 'icon': Icons.design_services},
      {'name': 'Adobe CC', 'color': const Color(0xFFFF0000), 'icon': Icons.brush},
      {'name': 'Figma', 'color': const Color(0xFFF24E1E), 'icon': Icons.brush},
    ],
    'Developer tools': [
      {'name': 'GitHub Pro', 'color': const Color(0xFF000000), 'icon': Icons.code},
      {'name': 'JetBrains', 'color': const Color(0xFF000000), 'icon': Icons.code},
      {'name': 'Vercel', 'color': const Color(0xFF000000), 'icon': Icons.code},
      {'name': 'GitLab', 'color': const Color(0xFFFC6D26), 'icon': Icons.code},
      {'name': 'Bitbucket', 'color': const Color(0xFF2684FF), 'icon': Icons.code},
    ],
    'Education': [
      {'name': 'Ruangguru', 'color': const Color(0xFF0054A6), 'icon': Icons.school},
      {'name': 'Zenius', 'color': const Color(0xFF5A1C8E), 'icon': Icons.school},
      {'name': 'Duolingo Plus', 'color': const Color(0xFF58CC02), 'icon': Icons.school},
      {'name': 'Coursera', 'color': const Color(0xFF0056D2), 'icon': Icons.school},
      {'name': 'Udemy', 'color': const Color(0xFFA435F0), 'icon': Icons.school},
      {'name': 'Brainly', 'color': const Color(0xFF485FC7), 'icon': Icons.school},
      {'name': 'Kahoot', 'color': const Color(0xFF46178F), 'icon': Icons.school},
      {'name': 'edX', 'color': const Color(0xFF00262B), 'icon': Icons.school},
      {'name': 'Codecademy', 'color': const Color(0xFF1F285C), 'icon': Icons.school},
      {'name': 'Skillshare', 'color': const Color(0xFF00FF84), 'icon': Icons.school},
      {'name': 'MasterClass', 'color': const Color(0xFF000000), 'icon': Icons.school},
      {'name': 'LinkedIn Learning', 'color': const Color(0xFF0A66C2), 'icon': Icons.school},
      {'name': 'Pahamify', 'color': const Color(0xFFF9A825), 'icon': Icons.school},
      {'name': 'Binar Academy', 'color': const Color(0xFF6200EA), 'icon': Icons.school},
      {'name': 'Cakap', 'color': const Color(0xFF00B0FF), 'icon': Icons.school},
    ],
    'Entertainment': [
      {'name': 'Netflix', 'color': const Color(0xFFE50914), 'icon': Icons.movie},
      {'name': 'Disney+', 'color': const Color(0xFF113CCF), 'icon': Icons.movie_filter},
      {'name': 'Prime Video', 'color': const Color(0xFF00A8E1), 'icon': Icons.movie},
      {'name': 'YouTube Premium', 'color': const Color(0xFFFF0000), 'icon': Icons.play_arrow},
      {'name': 'Vidio', 'color': const Color(0xFFED2324), 'icon': Icons.live_tv},
      {'name': 'HBO GO', 'color': const Color(0xFF5A009C), 'icon': Icons.movie},
      {'name': 'Viu', 'color': const Color(0xFFFFCC00), 'icon': Icons.movie},
      {'name': 'iQIYI', 'color': const Color(0xFF00CC22), 'icon': Icons.movie},
      {'name': 'WeTV', 'color': const Color(0xFF0088FF), 'icon': Icons.movie},
      {'name': 'Crunchyroll', 'color': const Color(0xFFF47521), 'icon': Icons.movie},
      {'name': 'Bstation', 'color': const Color(0xFF00A1D6), 'icon': Icons.movie},
      {'name': 'MAXstream', 'color': const Color(0xFFE22028), 'icon': Icons.movie},
    ],
    'Finance': [
      {'name': 'Jenius', 'color': const Color(0xFF00B5E2), 'icon': Icons.account_balance},
      {'name': 'Jago', 'color': const Color(0xFFF96D00), 'icon': Icons.account_balance},
      {'name': 'SeaBank', 'color': const Color(0xFFFC6421), 'icon': Icons.account_balance},
      {'name': 'BCA Mobile', 'color': const Color(0xFF0066AE), 'icon': Icons.account_balance},
      {'name': 'Livin by Mandiri', 'color': const Color(0xFFF2A900), 'icon': Icons.account_balance},
      {'name': 'BRImo', 'color': const Color(0xFF00529C), 'icon': Icons.account_balance},
      {'name': 'BNI Mobile', 'color': const Color(0xFF005E6A), 'icon': Icons.account_balance},
      {'name': 'GoPay', 'color': const Color(0xFF00A5CF), 'icon': Icons.account_balance_wallet},
      {'name': 'OVO', 'color': const Color(0xFF4C3494), 'icon': Icons.account_balance_wallet},
      {'name': 'DANA', 'color': const Color(0xFF108EE9), 'icon': Icons.account_balance_wallet},
      {'name': 'ShopeePay', 'color': const Color(0xFFEE4D2D), 'icon': Icons.account_balance_wallet},
      {'name': 'Bibit', 'color': const Color(0xFF0F985D), 'icon': Icons.account_balance_wallet},
      {'name': 'Ajaib', 'color': const Color(0xFF0A66C2), 'icon': Icons.account_balance_wallet},
      {'name': 'Pluang', 'color': const Color(0xFF263238), 'icon': Icons.account_balance_wallet},
      {'name': 'Stockbit', 'color': const Color(0xFF1DB954), 'icon': Icons.account_balance_wallet},
      {'name': 'BSI Mobile', 'color': const Color(0xFF00A59B), 'icon': Icons.account_balance},
      {'name': 'Bank Mega', 'color': const Color(0xFFFFCC00), 'icon': Icons.account_balance},
      {'name': 'Flip', 'color': const Color(0xFFFF5722), 'icon': Icons.account_balance_wallet},
      {'name': 'LinkAja', 'color': const Color(0xFFE3000F), 'icon': Icons.account_balance_wallet},
    ],
    'Fitness': [
      {'name': 'Strava', 'color': const Color(0xFFFC4C02), 'icon': Icons.fitness_center},
      {'name': 'Fitbit Premium', 'color': const Color(0xFF00B0B9), 'icon': Icons.fitness_center},
      {'name': 'MyFitnessPal', 'color': const Color(0xFF0066EE), 'icon': Icons.fitness_center},
    ],
    'Food & Delivery': [
      {'name': 'GoFood', 'color': const Color(0xFFEE2737), 'icon': Icons.restaurant},
      {'name': 'GrabFood', 'color': const Color(0xFF00B14F), 'icon': Icons.restaurant},
      {'name': 'ShopeeFood', 'color': const Color(0xFFEE4D2D), 'icon': Icons.restaurant},
      {'name': 'McDonald\'s', 'color': const Color(0xFFFFC72C), 'icon': Icons.fastfood},
      {'name': 'Lalamove', 'color': const Color(0xFFF26522), 'icon': Icons.local_shipping},
      {'name': 'Borzo', 'color': const Color(0xFF0091EA), 'icon': Icons.local_shipping},
    ],
    'Gaming': [
      {'name': 'PlayStation Plus', 'color': const Color(0xFF003791), 'icon': Icons.gamepad},
      {'name': 'Xbox Game Pass', 'color': const Color(0xFF107C10), 'icon': Icons.gamepad},
      {'name': 'Nintendo Switch Online', 'color': const Color(0xFFE60012), 'icon': Icons.gamepad},
      {'name': 'Steam', 'color': const Color(0xFF000000), 'icon': Icons.videogame_asset},
      {'name': 'EA Play', 'color': const Color(0xFFFF4747), 'icon': Icons.videogame_asset},
      {'name': 'Ubisoft+', 'color': const Color(0xFF0070F0), 'icon': Icons.videogame_asset},
      {'name': 'Twitch', 'color': const Color(0xFF9146FF), 'icon': Icons.videogame_asset},
      {'name': 'GeForce Now', 'color': const Color(0xFF76B900), 'icon': Icons.videogame_asset},
    ],
    'Groceries': [
      {'name': 'Sayurbox', 'color': const Color(0xFF43B02A), 'icon': Icons.local_grocery_store},
      {'name': 'Segari', 'color': const Color(0xFF3BA754), 'icon': Icons.local_grocery_store},
      {'name': 'Astro', 'color': const Color(0xFF131114), 'icon': Icons.local_grocery_store},
      {'name': 'Alfagift', 'color': const Color(0xFFED1B24), 'icon': Icons.local_grocery_store},
      {'name': 'KlikIndomaret', 'color': const Color(0xFF005EB8), 'icon': Icons.local_grocery_store},
    ],
    'Health': [
      {'name': 'Halodoc', 'color': const Color(0xFFE00024), 'icon': Icons.health_and_safety},
      {'name': 'Alodokter', 'color': const Color(0xFF1B85E6), 'icon': Icons.health_and_safety},
      {'name': 'Apple Health', 'color': const Color(0xFFFF2D55), 'icon': Icons.favorite},
    ],
    'Hosting & Domains': [
      {'name': 'Niagahoster', 'color': const Color(0xFF0056D2), 'icon': Icons.dns},
      {'name': 'Hostinger', 'color': const Color(0xFF673AB7), 'icon': Icons.dns},
      {'name': 'Namecheap', 'color': const Color(0xFFDE3B00), 'icon': Icons.dns},
      {'name': 'GoDaddy', 'color': const Color(0xFF1BDBDB), 'icon': Icons.dns},
    ],
    'Gym & Sports Clubs': [
      {'name': 'Celebrity Fitness', 'color': const Color(0xFFE22028), 'icon': Icons.sports_gymnastics},
      {'name': 'Anytime Fitness', 'color': const Color(0xFF512A72), 'icon': Icons.sports_gymnastics},
      {'name': 'Fitness First', 'color': const Color(0xFFD41F26), 'icon': Icons.sports_gymnastics},
    ],
    'Housing & Rent': [
      {'name': 'Kos Bulanan', 'color': const Color(0xFF009688), 'icon': Icons.house},
      {'name': 'IPL Apartemen', 'color': const Color(0xFF3F51B5), 'icon': Icons.apartment},
      {'name': 'Sewa Rumah', 'color': const Color(0xFF795548), 'icon': Icons.home},
    ],
    'Insurance': [
      {'name': 'Prudential', 'color': const Color(0xFFED1B2E), 'icon': Icons.shield},
      {'name': 'Allianz', 'color': const Color(0xFF003781), 'icon': Icons.shield},
      {'name': 'Manulife', 'color': const Color(0xFF00A758), 'icon': Icons.shield},
      {'name': 'BPJS Ketenagakerjaan', 'color': const Color(0xFF00A859), 'icon': Icons.shield},
    ],
    'Meditation': [
      {'name': 'Headspace', 'color': const Color(0xFFF47C5D), 'icon': Icons.self_improvement},
      {'name': 'Calm', 'color': const Color(0xFF8BB7D6), 'icon': Icons.self_improvement},
      {'name': 'Insight Timer', 'color': const Color(0xFFD6A461), 'icon': Icons.self_improvement},
    ],
    'Music': [
      {'name': 'Spotify', 'color': const Color(0xFF1DB954), 'icon': Icons.music_note},
      {'name': 'Apple Music', 'color': const Color(0xFFFA243C), 'icon': Icons.music_note},
      {'name': 'YouTube Music', 'color': const Color(0xFFFF0000), 'icon': Icons.music_video},
      {'name': 'Joox', 'color': const Color(0xFF0EBC52), 'icon': Icons.music_note},
      {'name': 'Resso', 'color': const Color(0xFF000000), 'icon': Icons.music_note},
      {'name': 'SoundCloud', 'color': const Color(0xFFFF5500), 'icon': Icons.music_note},
      {'name': 'Tidal', 'color': const Color(0xFF000000), 'icon': Icons.music_note},
      {'name': 'Deezer', 'color': const Color(0xFF000000), 'icon': Icons.music_note},
    ],
    'News & Reading': [
      {'name': 'Medium', 'color': const Color(0xFF000000), 'icon': Icons.menu_book},
      {'name': 'Kompas.id', 'color': const Color(0xFF0056A6), 'icon': Icons.menu_book},
      {'name': 'NY Times', 'color': const Color(0xFF000000), 'icon': Icons.menu_book},
      {'name': 'Gramedia Digital', 'color': const Color(0xFFE22028), 'icon': Icons.menu_book},
      {'name': 'Detikcom', 'color': const Color(0xFF1B3D7B), 'icon': Icons.menu_book},
      {'name': 'IDN Times', 'color': const Color(0xFFE62129), 'icon': Icons.menu_book},
      {'name': 'Tirto.id', 'color': const Color(0xFF3B5998), 'icon': Icons.menu_book},
    ],
    'Password manager': [
      {'name': '1Password', 'color': const Color(0xFF0572EC), 'icon': Icons.lock},
      {'name': 'Bitwarden', 'color': const Color(0xFF175DDC), 'icon': Icons.lock},
      {'name': 'LastPass', 'color': const Color(0xFFD32D27), 'icon': Icons.lock},
      {'name': 'Dashlane', 'color': const Color(0xFF0A2540), 'icon': Icons.lock},
    ],
    'Pets': [
      {'name': 'BarkBox', 'color': const Color(0xFF333333), 'icon': Icons.pets},
      {'name': 'PetDesk', 'color': const Color(0xFF00A2D9), 'icon': Icons.pets},
    ],
    'Podcasts': [
      {'name': 'Pocket Casts', 'color': const Color(0xFFF43E37), 'icon': Icons.podcasts},
      {'name': 'Noice', 'color': const Color(0xFFF9D000), 'icon': Icons.podcasts},
    ],
    'Productivity': [
      {'name': 'Evernote', 'color': const Color(0xFF00A82D), 'icon': Icons.note},
      {'name': 'Notion', 'color': const Color(0xFF000000), 'icon': Icons.note},
      {'name': 'Todoist', 'color': const Color(0xFFE44332), 'icon': Icons.check_circle},
      {'name': 'Microsoft 365', 'color': const Color(0xFF00A4EF), 'icon': Icons.dashboard},
    ],
    'Retail memberships': [
      {'name': 'Amazon Prime', 'color': const Color(0xFFFF9900), 'icon': Icons.shopping_bag},
      {'name': 'Walmart+', 'color': const Color(0xFF0071CE), 'icon': Icons.shopping_bag},
      {'name': 'Alfamart Member', 'color': const Color(0xFFED1B24), 'icon': Icons.shopping_bag},
      {'name': 'Indomaret Poinku', 'color': const Color(0xFF005EB8), 'icon': Icons.shopping_bag},
    ],
    'Security & VPN': [
      {'name': 'NordVPN', 'color': const Color(0xFF4687FF), 'icon': Icons.security},
      {'name': 'ExpressVPN', 'color': const Color(0xFFDA0F47), 'icon': Icons.security},
      {'name': 'Surfshark', 'color': const Color(0xFF00D2B5), 'icon': Icons.security},
      {'name': 'McAfee', 'color': const Color(0xFFC01818), 'icon': Icons.security},
    ],
    'Shopping': [
      {'name': 'Shopee', 'color': const Color(0xFFEE4D2D), 'icon': Icons.shopping_cart},
      {'name': 'Tokopedia', 'color': const Color(0xFF00AA5B), 'icon': Icons.shopping_cart},
      {'name': 'Lazada', 'color': const Color(0xFF0F1568), 'icon': Icons.shopping_cart},
      {'name': 'Blibli', 'color': const Color(0xFF0095DA), 'icon': Icons.shopping_cart},
      {'name': 'Amazon', 'color': const Color(0xFFFF9900), 'icon': Icons.shopping_cart},
      {'name': 'AliExpress', 'color': const Color(0xFFFF4747), 'icon': Icons.shopping_cart},
      {'name': 'Sephora', 'color': const Color(0xFF000000), 'icon': Icons.shopping_cart},
      {'name': 'MAPCLUB', 'color': const Color(0xFF000000), 'icon': Icons.shopping_cart},
    ],
    'Subscriptions': [
      {'name': 'Apple One', 'color': const Color(0xFF000000), 'icon': Icons.subscriptions},
      {'name': 'Google Play Pass', 'color': const Color(0xFF00C782), 'icon': Icons.subscriptions},
    ],
    'Travel': [
      {'name': 'Traveloka', 'color': const Color(0xFF00A1E4), 'icon': Icons.flight},
      {'name': 'Tiket.com', 'color': const Color(0xFF0064D2), 'icon': Icons.flight},
      {'name': 'Agoda', 'color': const Color(0xFF000000), 'icon': Icons.hotel},
      {'name': 'Airbnb', 'color': const Color(0xFFFF5A5F), 'icon': Icons.hotel},
      {'name': 'Pegipegi', 'color': const Color(0xFFFF7A00), 'icon': Icons.flight},
      {'name': 'KAI Access', 'color': const Color(0xFF003399), 'icon': Icons.train},
    ],
  };

  static Map<String, List<Map<String, dynamic>>> getAppData() {
    Map<String, List<Map<String, dynamic>>> appExamples = Map.from(data);
    
    // Create Indonesian language mappings
    appExamples['Tools AI'] = appExamples['AI tools']!;
    appExamples['Otomotif'] = appExamples['Automotive']!;
    appExamples['Tagihan & utilitas'] = appExamples['Bills & utilities']!;
    appExamples['Karir'] = appExamples['Career']!;
    appExamples['Platform cloud'] = appExamples['Cloud platforms']!;
    appExamples['Komunikasi'] = appExamples['Communication']!;
    appExamples['Langganan kreator'] = appExamples['Creator memberships']!;
    appExamples['Desain'] = appExamples['Design']!;
    appExamples['Tools developer'] = appExamples['Developer tools']!;
    appExamples['Edukasi'] = appExamples['Education']!;
    appExamples['Hiburan'] = appExamples['Entertainment']!;
    appExamples['Keuangan'] = appExamples['Finance']!;
    appExamples['Kebugaran'] = appExamples['Fitness']!;
    appExamples['Makanan & Pengiriman'] = appExamples['Food & Delivery']!;
    appExamples['Game'] = appExamples['Gaming']!;
    appExamples['Kebutuhan sehari-hari'] = appExamples['Groceries']!;
    appExamples['Kesehatan'] = appExamples['Health']!;
    appExamples['Kecantikan & Perawatan'] = appExamples['Beauty & Grooming']!;
    appExamples['Asuransi'] = appExamples['Insurance']!;
    appExamples['Properti & Sewa'] = appExamples['Housing & Rent']!;
    appExamples['Donasi & Amal'] = appExamples['Charity & Donations']!;
    appExamples['Hosting & Domain'] = appExamples['Hosting & Domains']!;
    appExamples['Gym & Klub Olahraga'] = appExamples['Gym & Sports Clubs']!;
    appExamples['Meditasi'] = appExamples['Meditation']!;
    appExamples['Musik'] = appExamples['Music']!;
    appExamples['Berita & Membaca'] = appExamples['News & Reading']!;
    appExamples['Hewan peliharaan'] = appExamples['Pets']!;
    appExamples['Podcast'] = appExamples['Podcasts']!;
    appExamples['Produktivitas'] = appExamples['Productivity']!;
    appExamples['Membership retail'] = appExamples['Retail memberships']!;
    appExamples['Keamanan & VPN'] = appExamples['Security & VPN']!;
    appExamples['Belanja'] = appExamples['Shopping']!;
    appExamples['Langganan'] = appExamples['Subscriptions']!;
    
    return appExamples;
  }
}
