import 'package:autolog/data/services/expense_suggestions_service.dart';
import 'package:autolog/domain/models/expense.dart';
import 'package:autolog/domain/models/expense_suggestion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseSuggestionsService & ExpenseSuggestion Tests', () {
    test('Predefined suggestions contains essential automotive items', () {
      final suggestions = ExpenseSuggestionsService.predefinedSuggestions;
      expect(suggestions.isNotEmpty, isTrue);

      final hasFuel = suggestions.any(
        (s) => s.category == ExpenseCategory.fuel,
      );
      final hasService = suggestions.any(
        (s) => s.category == ExpenseCategory.service,
      );
      final hasParts = suggestions.any(
        (s) => s.category == ExpenseCategory.parts,
      );
      final hasInsurance = suggestions.any(
        (s) => s.category == ExpenseCategory.insurance,
      );
      final hasTolls = suggestions.any(
        (s) => s.category == ExpenseCategory.tollsFees,
      );

      expect(hasFuel, isTrue);
      expect(hasService, isTrue);
      expect(hasParts, isTrue);
      expect(hasInsurance, isTrue);
      expect(hasTolls, isTrue);
    });

    test('Infer category correctly detects categories based on keywords', () {
      expect(
        ExpenseSuggestionsService.inferCategory('Tankowanie Pb95'),
        ExpenseCategory.fuel,
      );
      expect(
        ExpenseSuggestionsService.inferCategory('Orlen diesel do pełna'),
        ExpenseCategory.fuel,
      );
      expect(
        ExpenseSuggestionsService.inferCategory('Wymiana klocków i tarcz'),
        ExpenseCategory.service,
      );
      expect(
        ExpenseSuggestionsService.inferCategory('Serwis klimatyzacji'),
        ExpenseCategory.service,
      );
      expect(
        ExpenseSuggestionsService.inferCategory('Wycieraczki Bosch'),
        ExpenseCategory.parts,
      );
      expect(
        ExpenseSuggestionsService.inferCategory('Płyn do spryskiwaczy zimowy'),
        ExpenseCategory.parts,
      );
      expect(
        ExpenseSuggestionsService.inferCategory('Polisa OC PZU'),
        ExpenseCategory.insurance,
      );
      expect(
        ExpenseSuggestionsService.inferCategory('Autostrada A4 bilet'),
        ExpenseCategory.tollsFees,
      );
      expect(
        ExpenseSuggestionsService.inferCategory('Badanie techniczne SKP'),
        ExpenseCategory.tollsFees,
      );
    });

    test('getSuggestions returns prefix matching items for query "Wycier"', () {
      final results = ExpenseSuggestionsService.getSuggestions(
        query: 'Wycier',
        userSuggestions: [],
      );

      expect(results.isNotEmpty, isTrue);
      expect(results.first.title, startsWith('Wycieraczki'));
      expect(results.first.category, ExpenseCategory.parts);
    });

    test('getSuggestions prioritizes custom user history suggestions', () {
      final customSuggestions = [
        const ExpenseSuggestion(
          title: 'Wycieraczki Heyner Hybrid',
          category: ExpenseCategory.parts,
          isCustom: true,
          count: 5,
        ),
      ];

      final results = ExpenseSuggestionsService.getSuggestions(
        query: 'Wycier',
        userSuggestions: customSuggestions,
      );

      expect(results.first.title, 'Wycieraczki Heyner Hybrid');
      expect(results.first.isCustom, isTrue);
    });

    test(
      'getSuggestions with empty query returns items for specified category',
      () {
        final fuelResults = ExpenseSuggestionsService.getSuggestions(
          query: '',
          categoryFilter: ExpenseCategory.fuel,
        );

        expect(
          fuelResults.every((s) => s.category == ExpenseCategory.fuel),
          isTrue,
        );

        final partsResults = ExpenseSuggestionsService.getSuggestions(
          query: '',
          categoryFilter: ExpenseCategory.parts,
        );

        expect(
          partsResults.every((s) => s.category == ExpenseCategory.parts),
          isTrue,
        );
      },
    );
  });
}
