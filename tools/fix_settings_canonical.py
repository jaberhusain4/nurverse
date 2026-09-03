from pathlib import Path
import re
p=Path('lib/screens/canonical_settings_screen.dart')
s=p.read_text(encoding='utf-8')
# Fix the malformed tail introduced by the earlier Jamaat replacement.
s=s.replace("            ), s.ishaJamaat),\n          ]),", "            ),\n          ]),")
# Remove any Prayer Adjustments tile from the main Settings list.
s=re.sub(r"\n\s*_divider\(\),\n\s*_tile\(\s*context,\s*Icons\.tune_rounded,\s*t\(lang, 'সালাতের সময় সমন্বয়'.*?\),", "", s, count=1, flags=re.S)
# Ensure the dedicated Jamaat Settings entry exists and is the only Jamaat entry in the main list.
if "import 'prayer/jamaat_settings_screen.dart';" not in s:
    s=s.replace("import 'home_mode_settings_screen.dart';", "import 'home_mode_settings_screen.dart';\nimport 'prayer/jamaat_settings_screen.dart';", 1)
# Localize common internal values shown by choice sheets.
start=s.find('  String _choiceLabel(')
if start>=0:
    brace=s.find('{',start); depth=0; quote=None; esc=False; end=None
    for i in range(brace,len(s)):
        c=s[i]
        if quote:
            if esc: esc=False
            elif c=='\\': esc=True
            elif c==quote: quote=None
            continue
        if c in "'\"": quote=c
        elif c=='{': depth+=1
        elif c=='}':
            depth-=1
            if depth==0: end=i+1; break
    if end:
        helper='''  String _choiceLabel(String value, String languageCode) {\n    const bn = <String, String>{'system':'সিস্টেম অনুযায়ী','light':'লাইট মোড','dark':'ডার্ক মোড','amoled':'অ্যামোলেড','bn':'বাংলা','en':'ইংরেজি','ar':'আরবি','12':'১২ ঘণ্টা','24':'২৪ ঘণ্টা','automatic':'স্বয়ংক্রিয়','manual':'ম্যানুয়াল','Karachi':'করাচি','Muslim World League':'মুসলিম ওয়ার্ল্ড লীগ','Egyptian':'মিশরীয়','Umm Al Qura':'উম্মুল কুরা','Dubai':'দুবাই','Qatar':'কাতার','Kuwait':'কুয়েত','Singapore':'সিঙ্গাপুর','North America':'উত্তর আমেরিকা','Moonsighting Committee':'চাঁদ দেখা কমিটি','Tehran':'তেহরান','Turkey':'তুরস্ক','Other':'অন্যান্য','Hanafi':'হানাফি','Shafi':'শাফেয়ি','Maliki':'মালিকি','Hanbali':'হাম্বলি','Bangla':'বাংলা','English':'ইংরেজি','Arabic':'আরবি','Default':'ডিফল্ট','Silent':'নীরব','Amiri':'আমিরি','Scheherazade':'শেহেরাজাদে','hijri':'হিজরি','gregorian':'গ্রেগরিয়ান','both':'উভয়'};\n    if (languageCode == 'bn') return bn[value] ?? value;\n    if (languageCode == 'en') { if (value == '12') return '12-hour'; if (value == '24') return '24-hour'; return value; }\n    const ar=<String,String>{'system':'النظام','light':'فاتح','dark':'داكن','amoled':'AMOLED','bn':'البنغالية','en':'الإنجليزية','ar':'العربية','12':'12 ساعة','24':'24 ساعة','automatic':'تلقائي','manual':'يدوي','Karachi':'كراتشي','Muslim World League':'رابطة العالم الإسلامي','Egyptian':'المصري','Umm Al Qura':'أم القرى','Dubai':'دبي','Qatar':'قطر','Kuwait':'الكويت','Singapore':'سنغافورة','North America':'أمريكا الشمالية','Moonsighting Committee':'لجنة رؤية الهلال','Tehran':'طهران','Turkey':'تركيا','Other':'أخرى','Hanafi':'حنفي','Shafi':'شافعي','Maliki':'مالكي','Hanbali':'حنبلي','Bangla':'البنغالية','English':'الإنجليزية','Arabic':'العربية','Default':'افتراضي','Silent':'صامت','Amiri':'أميري','Scheherazade':'شهرزاد','hijri':'هجري','gregorian':'ميلادي','both':'كلاهما'};\n    return ar[value] ?? value;\n  }'''
        s=s[:start]+helper+s[end:]
p.write_text(s,encoding='utf-8')
print('settings repair applied')
