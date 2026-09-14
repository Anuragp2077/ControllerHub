using ControllerHub.Core.Controllers;

namespace ControllerHub.Core.Input;

public sealed class ControllerState
{
    // =========================
    // Face Buttons
    // =========================

    public bool A { get; set; }
    public bool B { get; set; }
    public bool X { get; set; }
    public bool Y { get; set; }

    // =========================
    // Shoulder Buttons
    // =========================

    public bool LeftBumper { get; set; }
    public bool RightBumper { get; set; }

    // =========================
    // System Buttons
    // =========================

    public bool Start { get; set; }
    public bool Back { get; set; }
    public bool Guide { get; set; }

    // =========================
    // D-Pad
    // =========================

    public bool DPadUp { get; set; }
    public bool DPadDown { get; set; }
    public bool DPadLeft { get; set; }
    public bool DPadRight { get; set; }

    // =========================
    // Stick Buttons
    // =========================

    public bool LeftStickButton { get; set; }
    public bool RightStickButton { get; set; }

    // =========================
    // Left Stick
    // =========================

    public float LeftStickX { get; set; }
    public float LeftStickY { get; set; }

    // =========================
    // Right Stick
    // =========================

    public float RightStickX { get; set; }
    public float RightStickY { get; set; }

    // =========================
    // Analog Triggers
    // =========================

    public float LeftTrigger { get; set; }
    public float RightTrigger { get; set; }

    // =========================
    // Button Input
    // =========================

    public void SetButton(
        ControllerButton button,
        bool pressed)
    {
        switch (button)
        {
            case ControllerButton.A:
                A = pressed;
                break;

            case ControllerButton.B:
                B = pressed;
                break;

            case ControllerButton.X:
                X = pressed;
                break;

            case ControllerButton.Y:
                Y = pressed;
                break;

            case ControllerButton.LeftBumper:
                LeftBumper = pressed;
                break;

            case ControllerButton.RightBumper:
                RightBumper = pressed;
                break;

            case ControllerButton.Start:
                Start = pressed;
                break;

            case ControllerButton.Back:
                Back = pressed;
                break;

            case ControllerButton.Guide:
                Guide = pressed;
                break;

            case ControllerButton.DPadUp:
                DPadUp = pressed;
                break;

            case ControllerButton.DPadDown:
                DPadDown = pressed;
                break;

            case ControllerButton.DPadLeft:
                DPadLeft = pressed;
                break;

            case ControllerButton.DPadRight:
                DPadRight = pressed;
                break;

            case ControllerButton.LeftStick:
                LeftStickButton = pressed;
                break;

            case ControllerButton.RightStick:
                RightStickButton = pressed;
                break;

            default:
                throw new ArgumentOutOfRangeException(
                    nameof(button),
                    button,
                    null);
        }
    }

    // =========================
    // Stick Input
    // =========================

    public void SetStick(
        ControllerStick stick,
        float x,
        float y)
    {
        x = Math.Clamp(x, -1f, 1f);
        y = Math.Clamp(y, -1f, 1f);

        if (stick == ControllerStick.Left)
        {
            LeftStickX = x;
            LeftStickY = y;
        }
        else
        {
            RightStickX = x;
            RightStickY = y;
        }
    }

    // =========================
    // Trigger Input
    // =========================

    public void SetTrigger(
        ControllerTrigger trigger,
        float value)
    {
        value = Math.Clamp(value, 0f, 1f);

        if (trigger == ControllerTrigger.Left)
        {
            LeftTrigger = value;
        }
        else
        {
            RightTrigger = value;
        }
    }

    // =========================
    // Reset Everything
    // =========================

    public void Reset()
    {
        A = false;
        B = false;
        X = false;
        Y = false;

        LeftBumper = false;
        RightBumper = false;

        Start = false;
        Back = false;
        Guide = false;

        DPadUp = false;
        DPadDown = false;
        DPadLeft = false;
        DPadRight = false;

        LeftStickButton = false;
        RightStickButton = false;

        LeftStickX = 0f;
        LeftStickY = 0f;

        RightStickX = 0f;
        RightStickY = 0f;

        LeftTrigger = 0f;
        RightTrigger = 0f;
    }
}