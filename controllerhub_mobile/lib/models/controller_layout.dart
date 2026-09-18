import 'dart:convert';

import 'controller_element.dart';

class ControllerLayout {
  final String id;
  String name;

  List<ControllerElement> elements;

  ControllerLayout({
    required this.id,
    required this.name,
    required this.elements,
  });

  ControllerLayout copyWith({
    String? id,
    String? name,
    List<ControllerElement>? elements,
  }) {
    return ControllerLayout(
      id: id ?? this.id,
      name: name ?? this.name,
      elements: elements ?? this.elements,
    );
  }

  ControllerElement? getElement(String elementId) {
    for (final element in elements) {
      if (element.id == elementId) {
        return element;
      }
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'elements': elements
          .map(
            (element) => element.toJson(),
          )
          .toList(),
    };
  }

  factory ControllerLayout.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawElements = json['elements'];

    final elements = <ControllerElement>[];

    if (rawElements is List) {
      for (final element in rawElements) {
        if (element is Map<String, dynamic>) {
          elements.add(
            ControllerElement.fromJson(element),
          );
        }
      }
    }

    return ControllerLayout(
      id: json['id'] as String,
      name: json['name'] as String,
      elements: elements,
    );
  }

  String encode() {
    return jsonEncode(toJson());
  }

  factory ControllerLayout.decode(String value) {
    return ControllerLayout.fromJson(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }
}