import '../../domain/models/expense.dart';
import '../../domain/models/expense_suggestion.dart';

class ExpenseSuggestionsService {
  static const List<ExpenseSuggestion> predefinedSuggestions = [
    // --- PALIWO ---
    ExpenseSuggestion(title: 'Tankowanie Pb95', category: ExpenseCategory.fuel),
    ExpenseSuggestion(title: 'Tankowanie Pb98', category: ExpenseCategory.fuel),
    ExpenseSuggestion(title: 'Tankowanie Diesel', category: ExpenseCategory.fuel),
    ExpenseSuggestion(title: 'Tankowanie Diesel V-Power', category: ExpenseCategory.fuel),
    ExpenseSuggestion(title: 'Tankowanie LPG', category: ExpenseCategory.fuel),
    ExpenseSuggestion(title: 'AdBlue', category: ExpenseCategory.fuel),
    ExpenseSuggestion(title: 'Ładowanie EV (AC)', category: ExpenseCategory.fuel),
    ExpenseSuggestion(title: 'Ładowanie EV (DC Fast)', category: ExpenseCategory.fuel),

    // --- NAPRAWA / SERWIS ---
    ExpenseSuggestion(title: 'Wymiana oleju i filtrów', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Wymiana oleju silnikowego', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Wymiana oleju w skrzyni biegów', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Serwis olejowy', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Wymiana rozrządu', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Serwis klimatyzacji i odgrzybianie', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Napełnienie klimatyzacji', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Geometria i zbieżność kół', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Klocki i tarcze hamulcowe (przód)', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Klocki i tarcze hamulcowe (tył)', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Wymiana płynu hamulcowego', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Wymiana płynu chłodniczego', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Wymiana świec zapłonowych', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Wymiana świec żarowych', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Wymiana amortyzatorów', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Wymiana sprzęgła i dwumasy', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Wymiana łożyska koła', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Diagnostyka komputerowa OBD', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Przegląd okresowy / serwisowy', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Regeneracja turbosprężarki', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Regeneracja wtryskiwaczy', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Wymiana wahaczy / tulei', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Naprawa układu wydechowego / DPF', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Wymiana opon / wulkanizacja', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Wyważanie kół', category: ExpenseCategory.service),
    ExpenseSuggestion(title: 'Polerowanie lakieru / detailing', category: ExpenseCategory.service),

    // --- CZĘŚCI I EKSPLOATACJA ---
    ExpenseSuggestion(title: 'Wycieraczki szyb', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Wycieraczki szyb Bosch', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Pióra wycieraczek', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Płyn do spryskiwaczy (zimowy)', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Płyn do spryskiwaczy (letni)', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Akumulator', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Żarówki / Oświetlenie LED', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Żarówki H7 / H4', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Filtr kabinowy / węglowy', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Filtr powietrza', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Filtr paliwa', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Olej silnikowy (dolewka 1L)', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Komplet opon letnich', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Komplet opon zimowych', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Komplet opon całorocznych', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Dywaniki samochodowe', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Mata do bagażnika', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Uchwyt na telefon / akcesoria', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Bezpieczniki samochodowe', category: ExpenseCategory.parts),
    ExpenseSuggestion(title: 'Kosmetyki samochodowe / szampon', category: ExpenseCategory.parts),

    // --- UBEZPIECZENIE ---
    ExpenseSuggestion(title: 'Polisa OC', category: ExpenseCategory.insurance),
    ExpenseSuggestion(title: 'Pakiet OC + AC + NNW', category: ExpenseCategory.insurance),
    ExpenseSuggestion(title: 'Ubezpieczenie Assistance', category: ExpenseCategory.insurance),
    ExpenseSuggestion(title: 'Ubezpieczenie szyb', category: ExpenseCategory.insurance),
    ExpenseSuggestion(title: 'Rata ubezpieczenia OC/AC', category: ExpenseCategory.insurance),
    ExpenseSuggestion(title: 'Zielona Karta', category: ExpenseCategory.insurance),
    ExpenseSuggestion(title: 'Ubezpieczenie GAP', category: ExpenseCategory.insurance),

    // --- OPŁATY I INNE ---
    ExpenseSuggestion(title: 'Badanie techniczne (przegląd rejestracyjny)', category: ExpenseCategory.tollsFees),
    ExpenseSuggestion(title: 'Opłata autostradowa (A1/A2/A4)', category: ExpenseCategory.tollsFees),
    ExpenseSuggestion(title: 'Winieta autostradowa', category: ExpenseCategory.tollsFees),
    ExpenseSuggestion(title: 'Myjnia bezdotykowa', category: ExpenseCategory.tollsFees),
    ExpenseSuggestion(title: 'Myjnia detailingowa / ręczna', category: ExpenseCategory.tollsFees),
    ExpenseSuggestion(title: 'Parkometr / bilet parkingowy', category: ExpenseCategory.tollsFees),
    ExpenseSuggestion(title: 'Abonament parkingowy', category: ExpenseCategory.tollsFees),
    ExpenseSuggestion(title: 'Rejestracja pojazdu / tablice', category: ExpenseCategory.tollsFees),
    ExpenseSuggestion(title: 'Podatek PCC-3', category: ExpenseCategory.tollsFees),
    ExpenseSuggestion(title: 'Mandat karny', category: ExpenseCategory.tollsFees),
    ExpenseSuggestion(title: 'Holowanie / pomoc drogowa', category: ExpenseCategory.tollsFees),
  ];

  /// Infer the most matching ExpenseCategory from entered title/text
  static ExpenseCategory? inferCategory(
    String text, {
    List<ExpenseSuggestion> customSuggestions = const [],
  }) {
    final clean = text.trim().toLowerCase();
    if (clean.isEmpty) return null;

    // 1. Direct match with custom suggestions
    for (final s in customSuggestions) {
      if (s.title.toLowerCase() == clean) {
        return s.category;
      }
    }

    // 2. Direct match with predefined suggestions
    for (final s in predefinedSuggestions) {
      if (s.title.toLowerCase() == clean) {
        return s.category;
      }
    }

    // 3. Prefix / contains match in custom suggestions
    for (final s in customSuggestions) {
      if (clean.contains(s.title.toLowerCase()) || s.title.toLowerCase().contains(clean)) {
        return s.category;
      }
    }

    // 4. Prefix / contains match in predefined suggestions
    for (final s in predefinedSuggestions) {
      if (clean.contains(s.title.toLowerCase()) || s.title.toLowerCase().contains(clean)) {
        return s.category;
      }
    }

    bool matchesAny(List<String> keywords) {
      for (final k in keywords) {
        if (k.length <= 3) {
          final pattern = RegExp(r'(^|\s|[.,/\-_+])' + RegExp.escape(k) + r'($|\s|[.,/\-_+])');
          if (pattern.hasMatch(clean)) return true;
        } else {
          if (clean.contains(k)) return true;
        }
      }
      return false;
    }

    // 5. Keyword & Stem Matching
    // Service & repair keywords
    final serviceKeywords = [
      'serwis', 'wymian', 'napraw', 'mechanik', 'aso', 'geometr', 'zbieżn',
      'rozrząd', 'rozrzad', 'klimatyz', 'odgrzyb', 'klock', 'tarcz', 'hamulc',
      'amortyz', 'sprzęgł', 'sprzegl', 'dwumas', 'łożysk', 'lozysk', 'obd',
      'diagnost', 'turbin', 'wtrysk', 'wahacz', 'wydech', 'dpf', 'wulkaniz',
      'wyważan', 'wywazan', 'detailing', 'olejow', 'przegląd',
    ];
    if (matchesAny(serviceKeywords)) {
      return ExpenseCategory.service;
    }

    // Parts keywords
    final partsKeywords = [
      'wycieraczk', 'piór', 'spryskiwac', 'akumulator', 'żarówk', 'zarowk',
      'filtr', 'opon', 'dywanik', 'części', 'czesci', 'część', 'bater',
      'bezpiecznik', 'uchwyt', 'płyn do spryskiwaczy', 'żarówka',
    ];
    if (matchesAny(partsKeywords)) {
      return ExpenseCategory.parts;
    }

    // Fuel keywords
    final fuelKeywords = [
      'tankowan', 'paliw', 'pb95', 'pb98', 'diesel', 'on', 'lpg', 'adblue',
      'stacja', 'orlen', 'shell', 'bp', 'circle k', 'moya', 'lotos', 'ładowan', 'kwh',
    ];
    if (matchesAny(fuelKeywords)) {
      return ExpenseCategory.fuel;
    }

    // Insurance keywords
    final insuranceKeywords = [
      'ubezpiecz', 'polisa', 'oc', 'ac', 'nnw', 'assistance', 'pzu', 'warta',
      'hestia', 'allianz', 'generali', 'uniqa', 'link4', 'tuir', 'gap', 'zielona karta',
    ];
    if (matchesAny(insuranceKeywords)) {
      return ExpenseCategory.insurance;
    }

    // Tolls & fees keywords
    final tollsKeywords = [
      'badanie techniczn', 'przegląd rejestracyjn', 'autostrad', 'winiet',
      'myjni', 'parking', 'parkometr', 'bilet', 'mandat', 'pcc', 'rejestracj',
      'holowan', 'opłata', 'oplata',
    ];
    if (matchesAny(tollsKeywords)) {
      return ExpenseCategory.tollsFees;
    }

    return null;
  }

  /// Get merged and filtered suggestions based on query and active filters
  static List<ExpenseSuggestion> getSuggestions({
    required String query,
    ExpenseCategory? categoryFilter,
    List<ExpenseSuggestion> userSuggestions = const [],
    int limit = 10,
  }) {
    final cleanQuery = query.trim().toLowerCase();

    // Deduplicate: merge user suggestions with predefined (user items override/take precedence)
    final Map<String, ExpenseSuggestion> merged = {};

    // 1. Add user custom suggestions first
    for (final s in userSuggestions) {
      merged[s.title.toLowerCase()] = s;
    }

    // 2. Add predefined suggestions if not overridden
    for (final s in predefinedSuggestions) {
      final key = s.title.toLowerCase();
      if (!merged.containsKey(key)) {
        merged[key] = s;
      }
    }

    final allList = merged.values.toList();

    // If query is empty: filter by category if provided, or return all
    if (cleanQuery.isEmpty) {
      if (categoryFilter != null) {
        final filtered = allList.where((s) => s.category == categoryFilter).toList();
        filtered.sort((a, b) {
          if (a.isCustom != b.isCustom) return a.isCustom ? -1 : 1;
          if (a.count != b.count) return b.count.compareTo(a.count);
          return a.title.compareTo(b.title);
        });
        return filtered.take(limit).toList();
      } else {
        return allList.take(limit).toList();
      }
    }

    // If query is not empty: match query
    final matching = allList.where((s) {
      final titleLower = s.title.toLowerCase();
      return titleLower.contains(cleanQuery);
    }).toList();

    // Sort matching results:
    // 1. Starts with query first
    // 2. User custom items first (or higher usage count)
    // 3. Current category match
    // 4. Shortest title / alphabetical
    matching.sort((a, b) {
      final aLower = a.title.toLowerCase();
      final bLower = b.title.toLowerCase();
      final aStarts = aLower.startsWith(cleanQuery);
      final bStarts = bLower.startsWith(cleanQuery);

      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;

      if (a.isCustom != b.isCustom) return a.isCustom ? -1 : 1;
      if (a.count != b.count) return b.count.compareTo(a.count);

      if (categoryFilter != null) {
        final aCat = a.category == categoryFilter;
        final bCat = b.category == categoryFilter;
        if (aCat && !bCat) return -1;
        if (!aCat && bCat) return 1;
      }

      return a.title.length.compareTo(b.title.length);
    });

    return matching.take(limit).toList();
  }
}
