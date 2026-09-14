using System.Text.Json;
using ControllerHub.Core.Controllers;
using ControllerHub.Server.Controllers;

namespace ControllerHub.Server.Networking;

public sealed class ControllerMessageHandler
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    private readonly ControllerInputRouter _router;

    public ControllerMessageHandler(
        ControllerInputRouter router)
    {
        _router = router;
    }

    public bool Handle(
        ControllerSlot slot,
        string message,
        ControllerConnection? connection = null)
    {
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
            Console.WriteLine(
                "Invalid JSON message.");

            return false;
        }

        if (controllerMessage == null)
        {
            Console.WriteLine(
                "Empty controller message.");

            return false;
        }

        if (controllerMessage.Version < 1)
        {
            Console.WriteLine(
                $"Unsupported protocol version: " +
                $"{controllerMessage.Version}");

            return false;
        }

        if (
            !string.IsNullOrWhiteSpace(
                controllerMessage.ClientId))
        {
            if (connection != null)
            {
                connection.SetClientId(
                    controllerMessage.ClientId);
            }
        }

        switch (
            controllerMessage.Type?
                .ToLowerInvariant())
        {
            case "heartbeat":

                connection?.Heartbeat();

                Console.WriteLine(
                    $"Heartbeat from Slot " +
                    $"{slot.SlotNumber}");

                return true;

            case "button":

                HandleButton(
                    slot,
                    controllerMessage);

                return true;

            case "stick":

                HandleStick(
                    slot,
                    controllerMessage);

                return true;

            case "trigger":

                HandleTrigger(
                    slot,
                    controllerMessage);

                return true;

            default:

                Console.WriteLine(
                    $"Unknown message type: " +
                    $"{controllerMessage.Type}");

                return false;
        }
    }

    private void HandleButton(
        ControllerSlot slot,
        ControllerMessage message)
    {
        if (
            !Enum.TryParse(
                message.Button,
                ignoreCase: true,
                out ControllerButton button))
        {
            Console.WriteLine(
                $"Unknown button: " +
                $"{message.Button}");

            return;
        }

        _router.SetButton(
            slot,
            button,
            message.Pressed);

        Console.WriteLine(
            $"Slot {slot.SlotNumber}: " +
            $"{button} = " +
            $"{message.Pressed}");
    }

    private void HandleStick(
        ControllerSlot slot,
        ControllerMessage message)
    {
        if (
            !Enum.TryParse(
                message.Stick,
                ignoreCase: true,
                out ControllerStick stick))
        {
            Console.WriteLine(
                $"Unknown stick: " +
                $"{message.Stick}");

            return;
        }

        _router.SetStick(
            slot,
            stick,
            message.X,
            message.Y);

        Console.WriteLine(
            $"Slot {slot.SlotNumber}: " +
            $"{stick} = " +
            $"({message.X:0.00}, " +
            $"{message.Y:0.00})");
    }

    private void HandleTrigger(
        ControllerSlot slot,
        ControllerMessage message)
    {
        if (
            !Enum.TryParse(
                message.Trigger,
                ignoreCase: true,
                out ControllerTrigger trigger))
        {
            Console.WriteLine(
                $"Unknown trigger: " +
                $"{message.Trigger}");

            return;
        }

        _router.SetTrigger(
            slot,
            trigger,
            message.Value);

        Console.WriteLine(
            $"Slot {slot.SlotNumber}: " +
            $"{trigger} = " +
            $"{message.Value:0.00}");
    }
}