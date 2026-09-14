using ControllerHub.Core.Controllers;

namespace ControllerHub.Server.Controllers;

public sealed class ControllerInputRouter
{
    public void SetButton(
        ControllerSlot slot,
        ControllerButton button,
        bool pressed)
    {
        slot.State.SetButton(
            button,
            pressed);

        slot.VirtualController.SetButton(
            button,
            pressed);
    }

    public void SetStick(
        ControllerSlot slot,
        ControllerStick stick,
        float x,
        float y)
    {
        slot.State.SetStick(
            stick,
            x,
            y);

        slot.VirtualController.SetStick(
            stick,
            x,
            y);
    }

    public void SetTrigger(
    ControllerSlot slot,
    ControllerTrigger trigger,
    float value)
{
    float digitalValue = value > 0f ? 1f : 0f;

    slot.State.SetTrigger(
        trigger,
        digitalValue);

    slot.VirtualController.SetTrigger(
        trigger,
        digitalValue);
}

    public void Reset(
        ControllerSlot slot)
    {
        slot.State.Reset();

        slot.VirtualController.Reset();
    }
}