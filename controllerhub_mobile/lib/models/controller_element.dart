import 'dart:convert';

class ControllerElement {
  final String id;

  double x;
  double y;

  double width;
  double height;

  double rotation;
  double opacity;

  bool visible;

  ControllerElement({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0.0,
    this.opacity = 1.0,
    this.visible = true,
  });

  ControllerElement copyWith({
    String? id,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    double? opacity,
    bool? visible,
  }) {
    return ControllerElement(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      visible: visible ?? this.visible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
      'opacity': opacity,
      'visible': visible,
    };
  }

  factory ControllerElement.fromJson(
    Map<String, dynamic> json,
  ) {
    return ControllerElement(
      id: json['id'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      rotation:
          (json['rotation'] as num?)?.toDouble() ?? 0.0,
      opacity:
          (json['opacity'] as num?)?.toDouble() ?? 1.0,
      visible:
          json['visible'] as bool? ?? true,
    );
  }

  String encode() {
    return jsonEncode(toJson());
  }

  factory ControllerElement.decode(String value) {
    return ControllerElement.fromJson(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }
}