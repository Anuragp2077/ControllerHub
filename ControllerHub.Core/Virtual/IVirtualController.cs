using ControllerHub.Core.Controllers;

namespace ControllerHub.Core.Virtual;

public interface IVirtualController : IDisposable
{
    void SetButton(
        ControllerButton button,
        bool pressed);

    void SetStick(
        ControllerStick stick,
        float x,
        float y);

    void SetTrigger(
        ControllerTrigger trigger,
        float value);

    void Reset();
}