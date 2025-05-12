import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile(
          title: Text('Тёмная тема'),
          value: true,
          onChanged: (val) {},
        ),
        ListTile(
          title: Text('Уведомления'),
          subtitle: Text('Скоро будет доступно'),
        ),
        ListTile(
          title: Text('API-ключи'),
          subtitle: Text('Скоро будет доступно'),
        ),
      ],
    );
  }
}
