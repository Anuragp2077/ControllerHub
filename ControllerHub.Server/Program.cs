using ControllerHub.Server.Controllers;
using ControllerHub.Server.Networking;
using ControllerHub.Server.Pairing;
using ControllerHub.Server.Sessions;

namespace ControllerHub.Server;

public static class Program
{
    public static async Task Main(
        string[] args)
    {
        var controllerManager =
            new ControllerManager();

        var router =
            new ControllerInputRouter();

        var messageHandler =
            new ControllerMessageHandler(
                router);

        var pairingService =
            new PairingService();

        var sessionManager =
            new SessionManager();

        var server =
            new WebSocketServer(
                8080,
                controllerManager,
                messageHandler,
                pairingService,
                sessionManager);

        Console.WriteLine(
            "ControllerHub Server");

        Console.WriteLine(
            "====================");

        try
        {
            await server.RunAsync();
        }
        finally
        {
            sessionManager.Dispose();
            controllerManager.Dispose();
        }
    }
}