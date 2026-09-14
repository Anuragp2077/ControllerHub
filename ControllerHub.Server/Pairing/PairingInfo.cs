namespace ControllerHub.Server.Pairing;

public sealed class PairingInfo
{
    public string Host { get; }

    public int Port { get; }

    public string Token { get; }

    public DateTime ExpiresAt { get; }

    public PairingInfo(
        string host,
        int port,
        string token,
        DateTime expiresAt)
    {
        Host = host;
        Port = port;
        Token = token;
        ExpiresAt = expiresAt;
    }

    public bool IsExpired =>
        DateTime.UtcNow >= ExpiresAt;
}