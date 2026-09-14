using ControllerHub.Server.Controllers;
using ControllerHub.Server.Networking;
using ControllerHub.Server.Pairing;
using ControllerHub.Server.Sessions;

namespace ControllerHub.App.Services;

public sealed class ServerService : IDisposable
{
    private const int ServerPort = 8080;

    private readonly ControllerMessageHandler _messageHandler;
    private readonly PairingService _pairingService;
    private readonly SessionManager _sessionManager;

    private WebSocketServer? _server;
    private CancellationTokenSource? _cancellationTokenSource;
    private Task? _serverTask;

    public ControllerManager ControllerManager { get; }

    public SessionManager SessionManager =>
        _sessionManager;

    public bool IsRunning =>
        _serverTask is
        {
            IsCompleted: false
        };

    public ServerService()
    {
        ControllerManager =
            new ControllerManager();

        var router =
            new ControllerInputRouter();

        _messageHandler =
            new ControllerMessageHandler(
                router);

        _pairingService =
            new PairingService();

        _sessionManager =
            new SessionManager();
    }

    public PairingInfo CreatePairing()
    {
        if (!IsRunning)
        {
            throw new InvalidOperationException(
                "The server must be running before creating a pairing session.");
        }

        return _server!.CreatePairing();
    }

    public async Task StartAsync()
    {
        if (IsRunning)
        {
            return;
        }

        _cancellationTokenSource =
            new CancellationTokenSource();

        _server =
            new WebSocketServer(
                ServerPort,
                ControllerManager,
                _messageHandler,
                _pairingService,
                _sessionManager);

        _serverTask =
            _server.RunAsync(
                _cancellationTokenSource.Token);

        await Task.Delay(100);
    }

    public async Task StopAsync()
    {
        if (_cancellationTokenSource == null)
        {
            return;
        }

        try
        {
            _cancellationTokenSource.Cancel();

            if (_serverTask != null)
            {
                try
                {
                    await _serverTask;
                }
                catch (OperationCanceledException)
                {
                }
            }
        }
        finally
        {
            _serverTask = null;
            _server = null;

            _cancellationTokenSource.Dispose();
            _cancellationTokenSource = null;

            _pairingService.ClearPairing();
            _sessionManager.Clear();
        }
    }

    public void Dispose()
    {
        StopAsync()
            .GetAwaiter()
            .GetResult();

        _sessionManager.Dispose();
        ControllerManager.Dispose();
    }
}