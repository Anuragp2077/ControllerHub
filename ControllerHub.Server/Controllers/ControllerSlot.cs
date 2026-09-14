using ControllerHub.Core.Input;
using ControllerHub.Core.Virtual;

namespace ControllerHub.Server.Controllers;

public sealed class ControllerSlot : IDisposable
{
    public int SlotNumber { get; }

    public bool IsConnected { get; private set; }

    public ControllerState State { get; }

    public IVirtualController VirtualController { get; }

    public ControllerSlot(
        int slotNumber,
        IVirtualController virtualController)
    {
        if (slotNumber < 1)
        {
            throw new ArgumentOutOfRangeException(
                nameof(slotNumber));
        }

        SlotNumber = slotNumber;
        VirtualController = virtualController;
        State = new ControllerState();
    }

    public void Connect()
    {
        IsConnected = true;
    }

    public void Disconnect()
    {
        IsConnected = false;

        State.Reset();
        VirtualController.Reset();
    }

    public void Dispose()
    {
        Disconnect();
        VirtualController.Dispose();
    }
}