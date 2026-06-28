import 'package:flutter/material.dart';

class GroupDetailsPage extends StatelessWidget {
  final String groupId;

  const GroupDetailsPage({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Details: $groupId'),
      ),
      body: Center(
        child: Text('Details for Group ID: $groupId'),
      ),
    );
  }
}
