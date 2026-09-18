import 'package:flutter/foundation.dart';

import '../models/controller_element.dart';
import '../models/controller_layout.dart';
import 'default_layout.dart';
import 'layout_service.dart';

class LayoutController extends ChangeNotifier {
  final LayoutService _service = LayoutService();

  ControllerLayout? _layout;
  bool _loading = true;

  ControllerLayout? get layout => _layout;

  bool get isLoading => _loading;

  List<ControllerElement> get elements =>
      _layout?.elements ??
      const <ControllerElement>[];

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    ControllerLayout? savedLayout =
        await _service.getActiveLayout();

    if (savedLayout == null) {
      savedLayout = DefaultLayout.create();

      await _service.saveLayout(
        savedLayout,
      );

      await _service.setActiveLayout(
        savedLayout.id,
      );
    }

    _layout = savedLayout;

    _loading = false;
    notifyListeners();
  }

  ControllerElement? getElement(
    String id,
  ) {
    return _layout?.getElement(id);
  }

  void updateElement(
    String id, {
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    double? opacity,
    bool? visible,
  }) {
    final element = getElement(id);

    if (element == null) {
      return;
    }

    if (width != null) {
      element.width = width.clamp(
        0.02,
        1.0,
      );
    }

    if (height != null) {
      element.height = height.clamp(
        0.02,
        1.0,
      );
    }

    if (x != null) {
      element.x = _clampPosition(
        x,
        element.width,
      );
    }

    if (y != null) {
      element.y = _clampPosition(
        y,
        element.height,
      );
    }

    if (rotation != null) {
      element.rotation =
          _normalizeRotation(rotation);
    }

    if (opacity != null) {
      element.opacity = opacity.clamp(
        0.0,
        1.0,
      );
    }

    if (visible != null) {
      element.visible = visible;
    }

    notifyListeners();
  }

  void moveElement(
    String id, {
    required double dx,
    required double dy,
  }) {
    final element = getElement(id);

    if (element == null) {
      return;
    }

    updateElement(
      id,
      x: element.x + dx,
      y: element.y + dy,
    );
  }

  void resizeElement(
    String id, {
    required double deltaWidth,
    required double deltaHeight,
  }) {
    final element = getElement(id);

    if (element == null) {
      return;
    }

    final newWidth =
        (element.width + deltaWidth)
            .clamp(
              0.02,
              1.0 - element.x,
            );

    final newHeight =
        (element.height + deltaHeight)
            .clamp(
              0.02,
              1.0 - element.y,
            );

    updateElement(
      id,
      width: newWidth,
      height: newHeight,
    );
  }

  void rotateElement(
    String id,
    double degrees,
  ) {
    final element = getElement(id);

    if (element == null) {
      return;
    }

    updateElement(
      id,
      rotation:
          element.rotation + degrees,
    );
  }

  void setElementVisibility(
    String id,
    bool visible,
  ) {
    updateElement(
      id,
      visible: visible,
    );
  }

  void setElementOpacity(
    String id,
    double opacity,
  ) {
    updateElement(
      id,
      opacity: opacity,
    );
  }

  Future<void> save() async {
    final currentLayout = _layout;

    if (currentLayout == null) {
      return;
    }

    await _service.saveLayout(
      currentLayout,
    );

    await _service.setActiveLayout(
      currentLayout.id,
    );
  }

  Future<void> resetToDefault() async {
    final defaultLayout =
        DefaultLayout.create();

    _layout = defaultLayout;

    await _service.saveLayout(
      defaultLayout,
    );

    await _service.setActiveLayout(
      defaultLayout.id,
    );

    notifyListeners();
  }

  Future<void> resetElement(
    String id,
  ) async {
    final defaultLayout =
        DefaultLayout.create();

    final defaultElement =
        defaultLayout.getElement(id);

    final currentElement =
        getElement(id);

    if (defaultElement == null ||
        currentElement == null) {
      return;
    }

    currentElement.x =
        defaultElement.x;

    currentElement.y =
        defaultElement.y;

    currentElement.width =
        defaultElement.width;

    currentElement.height =
        defaultElement.height;

    currentElement.rotation =
        defaultElement.rotation;

    currentElement.opacity =
        defaultElement.opacity;

    currentElement.visible =
        defaultElement.visible;

    notifyListeners();
  }

  static double _clampPosition(
    double value,
    double size,
  ) {
    final maximum =
        (1.0 - size).clamp(
      0.0,
      1.0,
    );

    return value.clamp(
      0.0,
      maximum,
    );
  }

  static double _normalizeRotation(
    double value,
  ) {
    var rotation =
        value % 360.0;

    if (rotation > 180.0) {
      rotation -= 360.0;
    }

    if (rotation < -180.0) {
      rotation += 360.0;
    }

    return rotation;
  }
}