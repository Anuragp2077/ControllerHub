import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/controller_layout.dart';

class LayoutService {
  static const String _layoutsKey =
      'controllerhub_controller_layouts';

  static const String _activeLayoutKey =
      'controllerhub_active_layout';

  Future<List<ControllerLayout>> loadLayouts() async {
    final preferences =
        await SharedPreferences.getInstance();

    final raw =
        preferences.getStringList(_layoutsKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    final layouts = <ControllerLayout>[];

    for (final value in raw) {
      try {
        final decoded =
            jsonDecode(value) as Map<String, dynamic>;

        layouts.add(
          ControllerLayout.fromJson(decoded),
        );
      } catch (_) {
        // Ignore invalid saved layouts.
      }
    }

    return layouts;
  }

  Future<void> saveLayout(
    ControllerLayout layout,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

    final layouts =
        await loadLayouts();

    final existingIndex = layouts.indexWhere(
      (item) => item.id == layout.id,
    );

    if (existingIndex >= 0) {
      layouts[existingIndex] = layout;
    } else {
      layouts.add(layout);
    }

    await preferences.setStringList(
      _layoutsKey,
      layouts
          .map(
            (item) => item.encode(),
          )
          .toList(),
    );
  }

  Future<void> deleteLayout(
    String layoutId,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

    final layouts =
        await loadLayouts();

    layouts.removeWhere(
      (layout) => layout.id == layoutId,
    );

    await preferences.setStringList(
      _layoutsKey,
      layouts
          .map(
            (item) => item.encode(),
          )
          .toList(),
    );

    final activeLayout =
        preferences.getString(_activeLayoutKey);

    if (activeLayout == layoutId) {
      await preferences.remove(_activeLayoutKey);
    }
  }

  Future<ControllerLayout?> getLayout(
    String layoutId,
  ) async {
    final layouts =
        await loadLayouts();

    for (final layout in layouts) {
      if (layout.id == layoutId) {
        return layout;
      }
    }

    return null;
  }

  Future<void> setActiveLayout(
    String layoutId,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.setString(
      _activeLayoutKey,
      layoutId,
    );
  }

  Future<String?> getActiveLayoutId() async {
    final preferences =
        await SharedPreferences.getInstance();

    return preferences.getString(
      _activeLayoutKey,
    );
  }

  Future<ControllerLayout?> getActiveLayout() async {
    final activeId =
        await getActiveLayoutId();

    if (activeId == null || activeId.isEmpty) {
      return null;
    }

    return getLayout(activeId);
  }

  Future<void> clearAllLayouts() async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.remove(_layoutsKey);
    await preferences.remove(_activeLayoutKey);
  }
}