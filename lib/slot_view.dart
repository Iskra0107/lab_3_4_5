import 'package:flutter/material.dart';

class SlotsView extends StatelessWidget {
  final List<Map<String, String>> elements;

  const SlotsView({Key? key, required this.elements}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (elements.length > 0)
      return Container(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: elements.length,
              itemBuilder: (contx, index) {
                return Card(
                  elevation: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: Text(
                          elements[index]['subject'] as String,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(contx).primaryColorDark,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: Text(
                          elements[index]['termin'] as String,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    else
      return Container(
        child: Center(
          child: Text('На овој ден нема закажани испити'),
        ),
      );
  }
}
