import 'package:flutter/material.dart';

class ButtonModel {
  String label;
  int count;
  Color color;
  String id;

  ButtonModel({
    required this.label,
    required this.count,
    required this.color,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'count': count,
      'color': color.value,
      'id': id,
    };
  }

  factory ButtonModel.fromJson(Map<String, dynamic> json) {
    return ButtonModel(
      label: json['label'],
      count: json['count'],
      color: Color(json['color']),
      id: json['id'],
    );
  }
}
