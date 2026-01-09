import 'package:flutter/material.dart';

class PartyTab extends StatefulWidget {
  const PartyTab({super.key});

  @override
  State<PartyTab> createState() => _PartyTabState();
}

class _PartyTabState extends State<PartyTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: 
        const Size.fromHeight(kToolbarHeight),
        child: PartyAppBar(),
      ),

      body:
        Center(
          child: Column(
            children: [
              Text("Placeholder"),
            ],
          ),
        )
    );
  }
}

class PartyCard extends StatelessWidget {
  const PartyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


class PartyAppBar extends StatelessWidget {
  const PartyAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "파티원 구하기",
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4C46E5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () => (), //Todo: 버튼 기능 구현
          icon: Icon(Icons.add),
          label: const Text("파티 만들기"),
        )
      ],
    );
  }
}
