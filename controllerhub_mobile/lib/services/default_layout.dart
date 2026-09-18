import 'package:uuid/uuid.dart';

import '../models/controller_element.dart';
import '../models/controller_layout.dart';

class DefaultLayout {
  static const Uuid _uuid = Uuid();

  static ControllerLayout create() {
    return ControllerLayout(
      id: 'default',
      name: 'Default',
      elements: [
        // Top triggers / bumpers
        ControllerElement(
          id: 'lt',
          x: 0.055,
          y: 0.055,
          width: 0.135,
          height: 0.105,
        ),

        ControllerElement(
          id: 'lb',
          x: 0.055,
          y: 0.175,
          width: 0.135,
          height: 0.105,
        ),

        ControllerElement(
          id: 'rt',
          x: 0.810,
          y: 0.055,
          width: 0.135,
          height: 0.105,
        ),

        ControllerElement(
          id: 'rb',
          x: 0.810,
          y: 0.175,
          width: 0.135,
          height: 0.105,
        ),

        // Analog sticks
        ControllerElement(
          id: 'left_stick',
          x: 0.230,
          y: 0.350,
          width: 0.180,
          height: 0.270,
        ),

        ControllerElement(
          id: 'right_stick',
          x: 0.590,
          y: 0.350,
          width: 0.180,
          height: 0.270,
        ),

        // D-pad
        ControllerElement(
          id: 'dpad',
          x: 0.055,
          y: 0.610,
          width: 0.190,
          height: 0.300,
        ),

        // Face buttons
        ControllerElement(
          id: 'y',
          x: 0.750,
          y: 0.575,
          width: 0.085,
          height: 0.130,
        ),

        ControllerElement(
          id: 'x',
          x: 0.675,
          y: 0.675,
          width: 0.085,
          height: 0.130,
        ),

        ControllerElement(
          id: 'b',
          x: 0.825,
          y: 0.675,
          width: 0.085,
          height: 0.130,
        ),

        ControllerElement(
          id: 'a',
          x: 0.750,
          y: 0.775,
          width: 0.085,
          height: 0.130,
        ),

        // Center buttons
        ControllerElement(
          id: 'back',
          x: 0.395,
          y: 0.655,
          width: 0.065,
          height: 0.075,
        ),

        ControllerElement(
          id: 'settings',
          x: 0.465,
          y: 0.655,
          width: 0.065,
          height: 0.075,
        ),

        ControllerElement(
          id: 'start',
          x: 0.535,
          y: 0.655,
          width: 0.065,
          height: 0.075,
        ),
      ],
    );
  }

  static ControllerElement createElement({
    required String id,
    required double x,
    required double y,
    required double width,
    required double height,
  }) {
    return ControllerElement(
      id: '$id-${_uuid.v4()}',
      x: x,
      y: y,
      width: width,
      height: height,
    );
  }
}