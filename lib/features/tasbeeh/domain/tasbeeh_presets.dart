import '../../../data/models/tasbeeh_state.dart';

/// Built-in tasbeeh phrases. These are common words of remembrance that
/// appear in Hisn al-Muslim's chapter on the virtue of tasbih, tahmid,
/// tahlil and takbir (and in the after-prayer adhkar); the full narrations
/// and references are in the adhkar library.
const tasbeehPresets = <TasbeehDhikr>[
  TasbeehDhikr(id: 'subhanallah', text: 'سُبْحَانَ اللَّهِ', meaningEn: 'Glory be to Allah'),
  TasbeehDhikr(
    id: 'alhamdulillah',
    text: 'الْحَمْدُ لِلَّهِ',
    meaningEn: 'All praise is for Allah',
  ),
  TasbeehDhikr(id: 'allahuakbar', text: 'اللَّهُ أَكْبَرُ', meaningEn: 'Allah is the Greatest'),
  TasbeehDhikr(
    id: 'tahlil',
    text: 'لَا إِلَهَ إِلَّا اللَّهُ',
    meaningEn: 'None has the right to be worshipped but Allah',
    defaultTarget: 100,
  ),
  TasbeehDhikr(
    id: 'subhanallah_wabihamdihi',
    text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    meaningEn: 'Glory be to Allah and praise Him',
    defaultTarget: 100,
  ),
  TasbeehDhikr(
    id: 'subhanallah_aladheem',
    text: 'سُبْحَانَ اللَّهِ الْعَظِيمِ',
    meaningEn: 'Glory be to Allah, the Magnificent',
  ),
  TasbeehDhikr(
    id: 'astaghfirullah',
    text: 'أَسْتَغْفِرُ اللَّهَ',
    meaningEn: 'I seek forgiveness from Allah',
    defaultTarget: 100,
  ),
  TasbeehDhikr(
    id: 'hawqala',
    text: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    meaningEn: 'There is no might nor power except with Allah',
  ),
];

/// Target options offered in the UI. 0 means unlimited.
const tasbeehTargets = [33, 100, 1000, 0];
