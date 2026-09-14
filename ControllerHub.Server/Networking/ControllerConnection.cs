using System.Net;

namespace ControllerHub.Server.Networking;

public sealed class ControllerConnection
{
    public ControllerSession Session { get; }

    public int SlotNumber =>
        Session.SlotNumber;

    public string ClientId =>
        Session.ClientId;

    public DateTime ConnectedAt =>
        Session.ConnectedAt;

    public DateTime LastHeartbeat =>
        Session.LastHeartbeat;

    public IPAddress? RemoteAddress =>
        Session.RemoteAddress;

    public bool IsAlive =>
        Session.IsAlive;

    public ControllerConnection(
        ControllerSession session)
    {
        Session =
            session ??
            throw new ArgumentNullException(
                nameof(session));
    }

    // Temporary compatibility constructor.
    public ControllerConnection(
        int slotNumber)
        : this(
            new ControllerSession(
                $"slot-{slotNumber}",
                slotNumber))
    {
    }

    public void SetClientId(
        string clientId)
    {
        Session.SetClientId(
            clientId);
    }

    public void Heartbeat()
    {
        Session.Heartbeat();
    }

    public bool CheckTimeout(
        TimeSpan timeout)
    {
        return Session.CheckTimeout(
            timeout);
    }

    public void Disconnect()
    {
        Session.Disconnect();
    }
}