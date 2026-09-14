namespace ControllerHub.Server.Networking;

public sealed class ControllerMessage
{
    public string? Type { get; set; }

    public string? Button { get; set; }

    public bool Pressed { get; set; }

    public string? Stick { get; set; }

    public float X { get; set; }

    public float Y { get; set; }

    public string? Trigger { get; set; }

    public float Value { get; set; }

    public int Version { get; set; } = 1;

    public string? ClientId { get; set; }

    public string? Token { get; set; }
}