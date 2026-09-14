using System.Security.Cryptography;

namespace ControllerHub.Server.Pairing;

public sealed class PairingService
{
    private const int TokenLength = 32;

    private readonly TimeSpan _tokenLifetime =
        TimeSpan.FromMinutes(5);

    private PairingInfo? _currentPairing;

    private readonly object _lock = new();

    public PairingInfo CreatePairing(
        string host,
        int port)
    {
        if (string.IsNullOrWhiteSpace(host))
        {
            throw new ArgumentException(
                "Host cannot be empty.",
                nameof(host));
        }

        if (port < 1 || port > 65535)
        {
            throw new ArgumentOutOfRangeException(
                nameof(port));
        }

        string token =
            GenerateToken();

        DateTime expiresAt =
            DateTime.UtcNow +
            _tokenLifetime;

        var pairing =
            new PairingInfo(
                host,
                port,
                token,
                expiresAt);

        lock (_lock)
        {
            _currentPairing =
                pairing;
        }

        return pairing;
    }

    public PairingInfo? GetCurrentPairing()
    {
        lock (_lock)
        {
            if (_currentPairing == null)
            {
                return null;
            }

            if (_currentPairing.IsExpired)
            {
                _currentPairing = null;
                return null;
            }

            return _currentPairing;
        }
    }

    public bool ValidateToken(
        string token)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            return false;
        }

        lock (_lock)
        {
            if (_currentPairing == null)
            {
                return false;
            }

            if (_currentPairing.IsExpired)
            {
                _currentPairing = null;
                return false;
            }

            try
            {
                byte[] expected =
                    Convert.FromBase64String(
                        _currentPairing.Token);

                byte[] supplied =
                    Convert.FromBase64String(
                        token);

                return CryptographicOperations.FixedTimeEquals(
                    expected,
                    supplied);
            }
            catch (FormatException)
            {
                return false;
            }
        }
    }

    public void ClearPairing()
    {
        lock (_lock)
        {
            _currentPairing = null;
        }
    }

    private static string GenerateToken()
    {
        byte[] bytes =
            RandomNumberGenerator.GetBytes(
                TokenLength);

        return Convert.ToBase64String(bytes);
    }
}