using System.Net;

namespace ControllerHub.Server.Networking;

public sealed class ControllerSession
{
    public string ClientId { get; private set; }

    public int SlotNumber { get; }

    public DateTime ConnectedAt { get; }

    public DateTime LastHeartbeat { get; private set; }

    public IPAddress? RemoteAddress { get; }

    public bool IsAlive { get; private set; }

    public ControllerSession(
        string clientId,
        int slotNumber,
        IPAddress? remoteAddress = null)
    {
        if (string.IsNullOrWhiteSpace(clientId))
        {
            throw new ArgumentException(
                "Client ID cannot be empty.",
                nameof(clientId));
        }

        if (slotNumber < 1)
        {
            throw new ArgumentOutOfRangeException(
                nameof(slotNumber));
        }

        ClientId = clientId;
        SlotNumber = slotNumber;
        RemoteAddress = remoteAddress;

        ConnectedAt = DateTime.UtcNow;
        LastHeartbeat = ConnectedAt;

        IsAlive = true;
    }

    public void SetClientId(
        string clientId)
    {
        if (string.IsNullOrWhiteSpace(clientId))
        {
            throw new ArgumentException(
                "Client ID cannot be empty.",
                nameof(clientId));
        }

        ClientId = clientId;
    }

    public void Heartbeat()
    {
        LastHeartbeat = DateTime.UtcNow;
        IsAlive = true;
    }

    public bool CheckTimeout(
        TimeSpan timeout)
    {
        if (
            DateTime.UtcNow -
            LastHeartbeat >
            timeout)
        {
            IsAlive = false;
            return true;
        }

        return false;
    }

    public void Disconnect()
    {
        IsAlive = false;
    }
}