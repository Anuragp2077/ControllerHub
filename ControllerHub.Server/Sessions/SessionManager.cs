using ControllerHub.Server.Networking;

namespace ControllerHub.Server.Sessions;

public sealed class SessionManager
{
    private readonly Dictionary<int, ControllerSession> _sessions = new();

    private readonly object _lock = new();

    public IReadOnlyCollection<ControllerSession> Sessions
    {
        get
        {
            lock (_lock)
            {
                return _sessions.Values.ToArray();
            }
        }
    }

    public bool Add(
        ControllerSession session)
    {
        ArgumentNullException.ThrowIfNull(session);

        lock (_lock)
        {
            if (_sessions.ContainsKey(session.SlotNumber))
            {
                return false;
            }

            _sessions.Add(
                session.SlotNumber,
                session);

            Console.WriteLine(
                $"SESSION ADDED | " +
                $"Slot={session.SlotNumber} | " +
                $"Client={session.ClientId} | " +
                $"IP={session.RemoteAddress}");

            return true;
        }
    }

    public bool Remove(
        int slotNumber)
    {
        lock (_lock)
        {
            if (
                !_sessions.Remove(
                    slotNumber,
                    out ControllerSession? session))
            {
                return false;
            }

            session.Disconnect();

            Console.WriteLine(
                $"SESSION REMOVED | " +
                $"Slot={slotNumber} | " +
                $"Client={session.ClientId}");

            return true;
        }
    }

    public ControllerSession? Get(
        int slotNumber)
    {
        lock (_lock)
        {
            _sessions.TryGetValue(
                slotNumber,
                out ControllerSession? session);

            return session;
        }
    }

    public ControllerSession? GetByClientId(
        string clientId)
    {
        if (string.IsNullOrWhiteSpace(clientId))
        {
            return null;
        }

        lock (_lock)
        {
            return _sessions.Values.FirstOrDefault(
                session =>
                    string.Equals(
                        session.ClientId,
                        clientId,
                        StringComparison.Ordinal));
        }
    }

    public bool ContainsClient(
        string clientId)
    {
        return GetByClientId(clientId) != null;
    }

    public void Clear()
    {
        lock (_lock)
        {
            foreach (
                ControllerSession session
                in _sessions.Values)
            {
                session.Disconnect();
            }

            _sessions.Clear();
        }
    }

    public void Dispose()
    {
        Clear();
    }
}