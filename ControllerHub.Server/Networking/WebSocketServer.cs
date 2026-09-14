using System.Net;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Net.WebSockets;
using System.Text;
using System.Text.Json;

using ControllerHub.Server.Controllers;
using ControllerHub.Server.Pairing;
using ControllerHub.Server.Sessions;

using Microsoft.AspNetCore.Builder;

namespace ControllerHub.Server.Networking;

public sealed class WebSocketServer
{
    private readonly int _port;
    private readonly ControllerManager _controllerManager;
    private readonly ControllerMessageHandler _messageHandler;
    private readonly PairingService _pairingService;
    private readonly SessionManager _sessionManager;

    private static readonly TimeSpan HeartbeatTimeout =
        TimeSpan.FromSeconds(6);

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    public WebSocketServer(
        int port,
        ControllerManager controllerManager,
        ControllerMessageHandler messageHandler,
        PairingService pairingService,
        SessionManager sessionManager)
    {
        _port = port;
        _controllerManager = controllerManager;
        _messageHandler = messageHandler;
        _pairingService = pairingService;
        _sessionManager = sessionManager;
    }

    public PairingInfo CreatePairing()
    {
        string? host =
            GetLocalNetworkAddress();

        if (host == null)
        {
            throw new InvalidOperationException(
                "Could not determine the local network address.");
        }

        return _pairingService.CreatePairing(
            host,
            _port);
    }

    public async Task RunAsync(
        CancellationToken cancellationToken = default)
    {
        var builder =
            WebApplication.CreateBuilder();

        builder.WebHost.UseUrls(
            $"http://0.0.0.0:{_port}");

        var app =
            builder.Build();

        app.UseWebSockets();

        app.MapGet(
            "/test",
            async context =>
            {
                context.Response.ContentType =
                    "text/html; charset=utf-8";

                await context.Response.WriteAsync(
                    TestPage.Html);
            });

        app.MapGet(
            "/pair",
            async context =>
            {
                PairingInfo? pairing =
                    _pairingService.GetCurrentPairing();

                if (pairing == null)
                {
                    context.Response.StatusCode = 404;

                    await context.Response.WriteAsync(
                        "No active pairing session.");

                    return;
                }

                context.Response.ContentType =
                    "application/json";

                await context.Response.WriteAsJsonAsync(
                    new
                    {
                        host = pairing.Host,
                        port = pairing.Port,
                        token = pairing.Token,
                        expiresAt = pairing.ExpiresAt
                    });
            });

        app.Map(
            "/",
            async context =>
            {
                if (!context.WebSockets.IsWebSocketRequest)
                {
                    context.Response.StatusCode = 400;

                    await context.Response.WriteAsync(
                        "WebSocket connection required.");

                    return;
                }

                ControllerSlot? slot = null;
                ControllerConnection? connection = null;

                try
                {
                    using WebSocket socket =
                        await context.WebSockets
                            .AcceptWebSocketAsync();

                    Console.WriteLine();
                    Console.WriteLine(
                        "WebSocket client connected.");

                    ControllerMessage? authenticationMessage =
                        await AuthenticateConnectionAsync(
                            socket,
                            cancellationToken);

                    if (authenticationMessage == null)
                    {
                        Console.WriteLine(
                            "WebSocket authentication failed.");

                        return;
                    }

                    string clientId =
                        authenticationMessage.ClientId!;

                    ControllerSession? existingSession =
                        _sessionManager.GetByClientId(
                            clientId);

                    if (existingSession != null)
                    {
                        await SendErrorAsync(
                            socket,
                            "This client is already connected.",
                            cancellationToken);

                        Console.WriteLine(
                            $"Duplicate client rejected: {clientId}");

                        return;
                    }

                    try
                    {
                        slot =
                            _controllerManager.AcquireSlot();
                    }
                    catch (InvalidOperationException exception)
                    {
                        await SendErrorAsync(
                            socket,
                            exception.Message,
                            cancellationToken);

                        Console.WriteLine(
                            "No controller slots available.");

                        return;
                    }

                    IPAddress? remoteAddress =
                        context.Connection.RemoteIpAddress;

                    var session =
                        new ControllerSession(
                            clientId,
                            slot.SlotNumber,
                            remoteAddress);

                    if (!_sessionManager.Add(session))
                    {
                        _controllerManager.ReleaseSlot(
                            slot);

                        slot = null;

                        await SendErrorAsync(
                            socket,
                            "Could not create controller session.",
                            cancellationToken);

                        return;
                    }

                    connection =
                        new ControllerConnection(
                            session);

                    Console.WriteLine(
                        "WebSocket client authenticated.");

                    Console.WriteLine(
                        $"Client ID: {session.ClientId}");

                    Console.WriteLine(
                        $"Remote IP: {session.RemoteAddress}");

                    Console.WriteLine(
                        $"Assigned Slot: {session.SlotNumber}");

                    await SendSlotAsync(
                        socket,
                        slot.SlotNumber,
                        cancellationToken);

                    await HandleConnectionAsync(
                        socket,
                        slot,
                        connection,
                        cancellationToken);
                }
                catch (OperationCanceledException)
                {
                }
                catch (WebSocketException exception)
                {
                    Console.WriteLine(
                        $"WebSocket error: " +
                        $"{exception.Message}");
                }
                finally
                {
                    if (connection != null)
                    {
                        connection.Disconnect();

                        _sessionManager.Remove(
                            connection.SlotNumber);
                    }

                    if (slot != null)
                    {
                        _controllerManager.ReleaseSlot(
                            slot);

                        Console.WriteLine(
                            $"WebSocket client for Slot " +
                            $"{slot.SlotNumber} disconnected.");
                    }
                }
            });

        Console.WriteLine(
            $"WebSocket server starting on port {_port}...");

        await app.RunAsync(
            cancellationToken);
    }

    private async Task<ControllerMessage?> AuthenticateConnectionAsync(
        WebSocket socket,
        CancellationToken cancellationToken)
    {
        var buffer =
            new byte[4096];

        using var timeoutCts =
            CancellationTokenSource
                .CreateLinkedTokenSource(
                    cancellationToken);

        timeoutCts.CancelAfter(
            TimeSpan.FromSeconds(5));

        string? message;

        try
        {
            message =
                await ReceiveMessageAsync(
                    socket,
                    buffer,
                    timeoutCts.Token);
        }
        catch (OperationCanceledException)
            when (!cancellationToken.IsCancellationRequested)
        {
            await SendErrorAsync(
                socket,
                "Authentication timed out.",
                cancellationToken);

            return null;
        }

        if (message == null)
        {
            return null;
        }

        Console.WriteLine(
            $"Authentication message: {message}");

        ControllerMessage? controllerMessage;

        try
        {
            controllerMessage =
                JsonSerializer.Deserialize<ControllerMessage>(
                    message,
                    JsonOptions);
        }
        catch (JsonException)
        {
            await SendErrorAsync(
                socket,
                "Invalid authentication message.",
                cancellationToken);

            return null;
        }

        if (controllerMessage == null)
        {
            await SendErrorAsync(
                socket,
                "Empty authentication message.",
                cancellationToken);

            return null;
        }

        if (
            !string.Equals(
                controllerMessage.Type,
                "connect",
                StringComparison.OrdinalIgnoreCase))
        {
            await SendErrorAsync(
                socket,
                "First message must be a connect message.",
                cancellationToken);

            return null;
        }

        if (controllerMessage.Version < 1)
        {
            await SendErrorAsync(
                socket,
                $"Unsupported protocol version: " +
                $"{controllerMessage.Version}",
                cancellationToken);

            return null;
        }

        if (
            string.IsNullOrWhiteSpace(
                controllerMessage.ClientId))
        {
            await SendErrorAsync(
                socket,
                "Client ID is required.",
                cancellationToken);

            return null;
        }

        if (
            string.IsNullOrWhiteSpace(
                controllerMessage.Token))
        {
            await SendErrorAsync(
                socket,
                "Pairing token is required.",
                cancellationToken);

            return null;
        }

        bool valid =
            _pairingService.ValidateToken(
                controllerMessage.Token);

        if (!valid)
        {
            await SendErrorAsync(
                socket,
                "Invalid or expired pairing token.",
                cancellationToken);

            return null;
        }

        return controllerMessage;
    }

    private async Task HandleConnectionAsync(
        WebSocket socket,
        ControllerSlot slot,
        ControllerConnection connection,
        CancellationToken cancellationToken)
    {
        var buffer =
            new byte[4096];

        while (
            socket.State == WebSocketState.Open &&
            !cancellationToken.IsCancellationRequested)
        {
            try
            {
                using var timeoutCts =
                    CancellationTokenSource
                        .CreateLinkedTokenSource(
                            cancellationToken);

                timeoutCts.CancelAfter(
                    HeartbeatTimeout);

                string? message;

                try
                {
                    message =
                        await ReceiveMessageAsync(
                            socket,
                            buffer,
                            timeoutCts.Token);
                }
                catch (OperationCanceledException)
                    when (
                        !cancellationToken.IsCancellationRequested)
                {
                    if (
                        connection.CheckTimeout(
                            HeartbeatTimeout))
                    {
                        Console.WriteLine();
                        Console.WriteLine(
                            $"HEARTBEAT TIMEOUT: " +
                            $"Slot {slot.SlotNumber}");

                        Console.WriteLine(
                            $"Client: " +
                            $"{connection.ClientId}");

                        Console.WriteLine(
                            $"Resetting Slot " +
                            $"{slot.SlotNumber}.");

                        slot.Disconnect();

                        return;
                    }

                    continue;
                }

                if (message == null)
                {
                    return;
                }

                Console.WriteLine(
                    $"Received from Slot " +
                    $"{slot.SlotNumber}: " +
                    $"{message}");

                _messageHandler.Handle(
                    slot,
                    message,
                    connection);
            }
            catch (OperationCanceledException)
            {
                return;
            }
            catch (WebSocketException)
            {
                return;
            }
        }
    }

    private static async Task<string?> ReceiveMessageAsync(
        WebSocket socket,
        byte[] buffer,
        CancellationToken cancellationToken)
    {
        using var messageStream =
            new MemoryStream();

        WebSocketReceiveResult result;

        do
        {
            result =
                await socket.ReceiveAsync(
                    buffer,
                    cancellationToken);

            if (
                result.MessageType ==
                WebSocketMessageType.Close)
            {
                return null;
            }

            if (
                result.MessageType !=
                WebSocketMessageType.Text)
            {
                continue;
            }

            await messageStream.WriteAsync(
                buffer.AsMemory(
                    0,
                    result.Count),
                cancellationToken);

        } while (
            !result.EndOfMessage);

        return Encoding.UTF8.GetString(
            messageStream.ToArray());
    }

    private static async Task SendSlotAsync(
        WebSocket socket,
        int slotNumber,
        CancellationToken cancellationToken)
    {
        string message =
            JsonSerializer.Serialize(
                new
                {
                    type = "slot",
                    slot = slotNumber
                });

        byte[] bytes =
            Encoding.UTF8.GetBytes(
                message);

        await socket.SendAsync(
            new ArraySegment<byte>(
                bytes),
            WebSocketMessageType.Text,
            true,
            cancellationToken);
    }

    private static async Task SendErrorAsync(
        WebSocket socket,
        string message,
        CancellationToken cancellationToken)
    {
        if (
            socket.State !=
            WebSocketState.Open)
        {
            return;
        }

        string error =
            JsonSerializer.Serialize(
                new
                {
                    type = "error",
                    message
                });

        byte[] bytes =
            Encoding.UTF8.GetBytes(
                error);

        try
        {
            await socket.SendAsync(
                new ArraySegment<byte>(
                    bytes),
                WebSocketMessageType.Text,
                true,
                cancellationToken);
        }
        catch (WebSocketException)
        {
            // Client may have disconnected before
            // the error could be delivered.
        }
    }

    private static string? GetLocalNetworkAddress()
    {
        try
        {
            NetworkInterface[] interfaces =
                NetworkInterface.GetAllNetworkInterfaces();

            foreach (
                NetworkInterface networkInterface
                in interfaces)
            {
                if (
                    networkInterface.OperationalStatus !=
                    OperationalStatus.Up)
                {
                    continue;
                }

                if (
                    networkInterface.NetworkInterfaceType ==
                    NetworkInterfaceType.Loopback)
                {
                    continue;
                }

                IPInterfaceProperties properties =
                    networkInterface.GetIPProperties();

                foreach (
                    UnicastIPAddressInformation address
                    in properties.UnicastAddresses)
                {
                    IPAddress ip =
                        address.Address;

                    if (
                        ip.AddressFamily ==
                        AddressFamily.InterNetwork &&
                        !IPAddress.IsLoopback(ip))
                    {
                        return ip.ToString();
                    }
                }
            }
        }
        catch
        {
            // Network address detection is best effort.
        }

        return null;
    }
}