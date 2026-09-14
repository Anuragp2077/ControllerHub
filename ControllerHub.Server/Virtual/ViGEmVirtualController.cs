using ControllerHub.Core.Controllers;
using ControllerHub.Core.Virtual;
using Nefarius.ViGEm.Client;
using Nefarius.ViGEm.Client.Targets;
using Nefarius.ViGEm.Client.Targets.Xbox360;

namespace ControllerHub.Server.Virtual;

public sealed class ViGEmVirtualController : IVirtualController
{
    private readonly ViGEmClient _client;
    private readonly IXbox360Controller _controller;

    public ViGEmVirtualController()
    {
        _client = new ViGEmClient();

        _controller = _client.CreateXbox360Controller();

        _controller.Connect();
    }

    public void SetButton(
        ControllerButton button,
        bool pressed)
    {
        switch (button)
        {
            case ControllerButton.A:
                SetXboxButton(
                    Xbox360Button.A,
                    pressed);
                break;

            case ControllerButton.B:
                SetXboxButton(
                    Xbox360Button.B,
                    pressed);
                break;

            case ControllerButton.X:
                SetXboxButton(
                    Xbox360Button.X,
                    pressed);
                break;

            case ControllerButton.Y:
                SetXboxButton(
                    Xbox360Button.Y,
                    pressed);
                break;

            case ControllerButton.LeftBumper:
                SetXboxButton(
                    Xbox360Button.LeftShoulder,
                    pressed);
                break;

            case ControllerButton.RightBumper:
                SetXboxButton(
                    Xbox360Button.RightShoulder,
                    pressed);
                break;

            case ControllerButton.Start:
                SetXboxButton(
                    Xbox360Button.Start,
                    pressed);
                break;

            case ControllerButton.Back:
                SetXboxButton(
                    Xbox360Button.Back,
                    pressed);
                break;

            case ControllerButton.Guide:
                SetXboxButton(
                    Xbox360Button.Guide,
                    pressed);
                break;

            case ControllerButton.DPadUp:
                SetXboxButton(
                    Xbox360Button.Up,
                    pressed);
                break;

            case ControllerButton.DPadDown:
                SetXboxButton(
                    Xbox360Button.Down,
                    pressed);
                break;

            case ControllerButton.DPadLeft:
                SetXboxButton(
                    Xbox360Button.Left,
                    pressed);
                break;

            case ControllerButton.DPadRight:
                SetXboxButton(
                    Xbox360Button.Right,
                    pressed);
                break;

            case ControllerButton.LeftStick:
                SetXboxButton(
                    Xbox360Button.LeftThumb,
                    pressed);
                break;

            case ControllerButton.RightStick:
                SetXboxButton(
                    Xbox360Button.RightThumb,
                    pressed);
                break;

            default:
                throw new ArgumentOutOfRangeException(
                    nameof(button),
                    button,
                    null);
        }
    }

    public void SetStick(
        ControllerStick stick,
        float x,
        float y)
    {
        x = Math.Clamp(x, -1f, 1f);
        y = Math.Clamp(y, -1f, 1f);

        short xboxX = ToShort(x);
        short xboxY = ToShort(y);

        if (stick == ControllerStick.Left)
        {
            _controller.SetAxisValue(
                Xbox360Axis.LeftThumbX,
                xboxX);

            _controller.SetAxisValue(
                Xbox360Axis.LeftThumbY,
                xboxY);
        }
        else
        {
            _controller.SetAxisValue(
                Xbox360Axis.RightThumbX,
                xboxX);

            _controller.SetAxisValue(
                Xbox360Axis.RightThumbY,
                xboxY);
        }
    }

    public void SetTrigger(
        ControllerTrigger trigger,
        float value)
    {
        value = Math.Clamp(value, 0f, 1f);

        byte xboxValue = ToByte(value);

        if (trigger == ControllerTrigger.Left)
        {
            _controller.SetSliderValue(
                Xbox360Slider.LeftTrigger,
                xboxValue);
        }
        else
        {
            _controller.SetSliderValue(
                Xbox360Slider.RightTrigger,
                xboxValue);
        }
    }

    public void Reset()
    {
        _controller.ResetReport();
    }

    public void Dispose()
    {
        try
        {
            Reset();
        }
        finally
        {
            _controller.Disconnect();
            _client.Dispose();
        }
    }

    private void SetXboxButton(
        Xbox360Button button,
        bool pressed)
    {
        if (pressed)
        {
            _controller.SetButtonState(
                button,
                true);
        }
        else
        {
            _controller.SetButtonState(
                button,
                false);
        }
    }

    private static short ToShort(float value)
    {
        value = Math.Clamp(value, -1f, 1f);

        return (short)(value * short.MaxValue);
    }

    private static byte ToByte(float value)
    {
        value = Math.Clamp(value, 0f, 1f);

        return (byte)(value * byte.MaxValue);
    }
}