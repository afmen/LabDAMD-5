import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lista_compras_simples/main.dart';

void main() {
  group('Lista de Compras App', () {
    testWidgets('Adicionar, marcar e remover item', (WidgetTester tester) async {
      await tester.pumpWidget(const MeuApp());

      // Lista começa vazia
      expect(find.text('Sua lista está vazia!'), findsOneWidget);

      // Digitar item
      await tester.enterText(find.byType(TextField).first, 'Leite');

      // Clicar em Adicionar
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verificar item adicionado
      expect(find.text('Leite'), findsOneWidget);

      // Marcar como comprado
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Verifica se a linha está riscada
      final textWidget = tester.widget<Text>(find.text('Leite'));
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);

      // Remover item
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Lista vazia novamente
      expect(find.text('Sua lista está vazia!'), findsOneWidget);
    });

    testWidgets('Filtro de busca e categoria', (WidgetTester tester) async {
      await tester.pumpWidget(const MeuApp());

      // Adicionar dois itens
      await tester.enterText(find.byType(TextField).first, 'Leite');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'Maçã');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verifica ambos na lista
      expect(find.text('Leite'), findsOneWidget);
      expect(find.text('Maçã'), findsOneWidget);

      // Filtrar por busca
      await tester.enterText(find.byType(TextField).at(1), 'Leite');
      await tester.pump();

      expect(find.text('Leite'), findsOneWidget);
      expect(find.text('Maçã'), findsNothing);

      // Limpar busca
      await tester.enterText(find.byType(TextField).at(1), '');
      await tester.pump();

      // Filtrar por categoria (ex: Frutas)
      await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Frutas').last);
      await tester.pumpAndSettle();

      expect(find.text('Maçã'), findsOneWidget);
      expect(find.text('Leite'), findsNothing);
    });

    testWidgets('Simular compartilhamento', (WidgetTester tester) async {
      await tester.pumpWidget(const MeuApp());

      // Adicionar item
      await tester.enterText(find.byType(TextField).first, 'Leite');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Clicar no botão de compartilhar
      await tester.tap(find.byIcon(Icons.share));
      await tester.pump();

      // Verifica se aparece SnackBar de compartilhamento
      expect(find.textContaining('Lista vazia'), findsNothing);
      // Note: não é possível testar o compartilhamento real em teste unitário
    });
  });
}
