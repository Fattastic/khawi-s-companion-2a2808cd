import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Test widget to demonstrate ValueKey fixing state retention in lists
class StatefulItem extends StatefulWidget {
  final int id;
  const StatefulItem({super.key, required this.id});

  @override
  State<StatefulItem> createState() => _StatefulItemState();
}

class _StatefulItemState extends State<StatefulItem> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Item ${widget.id}'),
      subtitle: Text('Count: $count'),
      trailing: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => setState(() => count++),
      ),
    );
  }
}

void main() {
  testWidgets('List items retain state when reordered if they have ValueKeys',
      (tester) async {
    List<int> items = [1, 2];

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: items.map((id) {
                        return StatefulItem(
                          key: ValueKey(id),
                          id: id,
                        );
                      }).toList(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Reverse order
                        items = items.reversed.toList();
                      });
                    },
                    child: const Text('Reverse'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    // Initially: Item 1 (count 0), Item 2 (count 0)
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);

    // Tap to increment Item 1
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();

    // Verify Item 1 has count 1
    expect(find.text('Count: 1'), findsOneWidget);

    // Tap reverse
    await tester.tap(find.text('Reverse'));
    await tester.pump();

    // With ValueKey, Item 1 should still have count 1 even though it moved
    final item1Finder = find.ancestor(
      of: find.text('Count: 1'),
      matching: find.byType(ListTile),
    );
    expect(
      find.descendant(of: item1Finder, matching: find.text('Item 1')),
      findsOneWidget,
    );
  });
}
