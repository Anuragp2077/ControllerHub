using System.IO;
using System.Net;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Windows;
using System.Windows.Media;
using System.Windows.Threading;
using ControllerHub.App.Services;
using ControllerHub.Server.Controllers;
using ControllerHub.Server.Networking;
using ControllerHub.Server.Pairing;
using ControllerHub.Server.Sessions;
using QRCoder;

namespace ControllerHub.App;

public partial class MainWindow
{
    private const int ServerPort = 8080;

    private readonly ServerService _serverService;
    private readonly DispatcherTimer _refreshTimer;

    private PairingInfo? _currentPairing;

    public MainWindow()
    {
        InitializeComponent();

        _serverService =
            new ServerService();

        _refreshTimer =
            new DispatcherTimer
            {
                Interval =
                    TimeSpan.FromMilliseconds(500)
            };

        _refreshTimer.Tick +=
            RefreshTimer_Tick;

        _refreshTimer.Start();

        UpdateServerUi();
    }

    private async void ServerButton_Click(
        object sender,
        RoutedEventArgs e)
    {
        ServerButton.IsEnabled = false;

        try
        {
            if (!_serverService.IsRunning)
            {
                await _serverService.StartAsync();

                _currentPairing = null;

                PairingPanel.Visibility =
                    Visibility.Visible;

                PairingQrImage.Source =
                    null;

                PairingStatusText.Text =
                    "No active pairing code.";

                PairingAddressText.Text =
                    "--";

                PairingExpirationText.Text =
                    "Generate a pairing code to connect phones.";

                PairButton.Content =
                    "Generate Pairing Code";
            }
            else
            {
                await _serverService.StopAsync();

                _currentPairing = null;

                PairingPanel.Visibility =
                    Visibility.Collapsed;

                PairingQrImage.Source =
                    null;

                PairingStatusText.Text =
                    "No active pairing code.";

                PairingAddressText.Text =
                    "--";

                PairingExpirationText.Text =
                    "Start the server to generate a pairing code.";

                PairButton.Content =
                    "Generate Pairing Code";
            }

            UpdateServerUi();
        }
        finally
        {
            ServerButton.IsEnabled = true;
        }
    }

    private void PairButton_Click(
        object sender,
        RoutedEventArgs e)
    {
        if (!_serverService.IsRunning)
        {
            MessageBox.Show(
                "Start the ControllerHub server first.",
                "Server Not Running",
                MessageBoxButton.OK,
                MessageBoxImage.Information);

            return;
        }

        try
        {
            _currentPairing =
                _serverService.CreatePairing();

            string pairingPayload =
                CreatePairingPayload(
                    _currentPairing);

            GenerateQrCode(
                pairingPayload);

            PairingPanel.Visibility =
                Visibility.Visible;

            PairButton.IsEnabled =
                true;

            PairButton.Content =
                "Generate New QR Code";

            PairingStatusText.Text =
                "Scan this code with ControllerHub";

            PairingAddressText.Text =
                $"{_currentPairing.Host}:{_currentPairing.Port}";

            UpdatePairingExpiration();
        }
        catch (Exception exception)
        {
            MessageBox.Show(
                exception.Message,
                "Pairing Error",
                MessageBoxButton.OK,
                MessageBoxImage.Error);
        }
    }

    private void RefreshTimer_Tick(
        object? sender,
        EventArgs e)
    {
        UpdateServerUi();

        UpdatePairingExpiration();
    }

    private void UpdateServerUi()
    {
        bool running =
            _serverService.IsRunning;

        if (running)
        {
            ServerStatusDot.Fill =
                Brushes.Green;

            ServerStatusText.Text =
                "Server Running";

            ServerButton.Content =
                "Stop Server";

            FooterStatusText.Text =
                "Server is running";

            string? localAddress =
                GetLocalNetworkAddress();

            if (localAddress != null)
            {
                ServerAddressText.Text =
                    $"{localAddress}:{ServerPort}";
            }
            else
            {
                ServerAddressText.Text =
                    $"Network unavailable:{ServerPort}";
            }

            PairButton.IsEnabled = true;

            if (_currentPairing == null)
            {
                PairButton.Content =
                    "Generate Pairing Code";
            }
        }
        else
        {
            ServerStatusDot.Fill =
                Brushes.Gray;

            ServerStatusText.Text =
                "Server Stopped";

            ServerButton.Content =
                "Start Server";

            FooterStatusText.Text =
                "Ready";

            ServerAddressText.Text =
                $"Port {ServerPort}";

            PairButton.IsEnabled =
                false;

            PairButton.Content =
                "Generate Pairing Code";
        }

        IReadOnlyCollection<ControllerSlot> slots =
            _serverService
                .ControllerManager
                .Slots;

        int connectedCount =
            slots.Count(
                slot => slot.IsConnected);

        ConnectionsText.Text =
            $"{connectedCount} / 4";

        UpdateSlotUi(
            1,
            Slot1StatusText,
            Slot1ClientText,
            Slot1ClientIdText,
            Slot1IpText,
            Slot1ConnectedAtText,
            Slot1HeartbeatText);

        UpdateSlotUi(
            2,
            Slot2StatusText,
            Slot2ClientText,
            Slot2ClientIdText,
            Slot2IpText,
            Slot2ConnectedAtText,
            Slot2HeartbeatText);

        UpdateSlotUi(
            3,
            Slot3StatusText,
            Slot3ClientText,
            Slot3ClientIdText,
            Slot3IpText,
            Slot3ConnectedAtText,
            Slot3HeartbeatText);

        UpdateSlotUi(
            4,
            Slot4StatusText,
            Slot4ClientText,
            Slot4ClientIdText,
            Slot4IpText,
            Slot4ConnectedAtText,
            Slot4HeartbeatText);
    }

    private void UpdateSlotUi(
        int slotNumber,
        System.Windows.Controls.TextBlock statusText,
        System.Windows.Controls.TextBlock clientText,
        System.Windows.Controls.TextBlock clientIdText,
        System.Windows.Controls.TextBlock ipText,
        System.Windows.Controls.TextBlock connectedAtText,
        System.Windows.Controls.TextBlock heartbeatText)
    {
        ControllerSlot? slot =
            _serverService
                .ControllerManager
                .GetSlot(slotNumber);

        ControllerSession? session =
            _serverService
                .SessionManager
                .Get(slotNumber);

        if (
            slot == null ||
            !slot.IsConnected ||
            session == null)
        {
            statusText.Text =
                "Disconnected";

            clientText.Text =
                "Available";

            clientIdText.Text =
                "--";

            ipText.Text =
                "--";

            connectedAtText.Text =
                "--";

            heartbeatText.Text =
                "Heartbeat: --";

            return;
        }

        statusText.Text =
            "Connected";

        clientText.Text =
            "Phone connected";

        clientIdText.Text =
            session.ClientId;

        ipText.Text =
            session.RemoteAddress?.ToString() ??
            "--";

        connectedAtText.Text =
            session.ConnectedAt
                .ToLocalTime()
                .ToString("HH:mm:ss");

        heartbeatText.Text =
            $"Heartbeat: " +
            $"{session.LastHeartbeat.ToLocalTime():HH:mm:ss}";
    }

    private void UpdatePairingExpiration()
    {
        if (_currentPairing == null)
        {
            PairingExpirationText.Text =
                _serverService.IsRunning
                    ? "Generate a pairing code to connect phones."
                    : "Start the server to generate a pairing code.";

            PairButton.Content =
                "Generate Pairing Code";

            return;
        }

        if (_currentPairing.IsExpired)
        {
            PairingExpirationText.Text =
                "Pairing code expired.";

            PairingStatusText.Text =
                "Generate a new code to connect phones.";

            PairButton.IsEnabled =
                _serverService.IsRunning;

            PairButton.Content =
                "Generate Pairing Code";

            return;
        }

        TimeSpan remaining =
            _currentPairing.ExpiresAt -
            DateTime.UtcNow;

        if (remaining < TimeSpan.Zero)
        {
            remaining =
                TimeSpan.Zero;
        }

        PairingExpirationText.Text =
            $"Expires in {remaining.Minutes:00}:{remaining.Seconds:00}";

        PairButton.IsEnabled =
            _serverService.IsRunning;

        PairButton.Content =
            "Generate New QR Code";
    }

    private static string CreatePairingPayload(
        PairingInfo pairing)
    {
        string token =
            Uri.EscapeDataString(
                pairing.Token);

        return
            $"http://{pairing.Host}:{pairing.Port}/test" +
            $"?token={token}";
    }

    private void GenerateQrCode(
        string payload)
    {
        using var generator =
            new QRCodeGenerator();

        using QRCodeData qrData =
            generator.CreateQrCode(
                payload,
                QRCodeGenerator.ECCLevel.Q);

        using var qrCode =
            new PngByteQRCode(
                qrData);

        byte[] qrBytes =
            qrCode.GetGraphic(
                12);

        using var stream =
            new MemoryStream(
                qrBytes);

        var image =
            new System.Windows.Media.Imaging.BitmapImage();

        image.BeginInit();

        image.CacheOption =
            System.Windows.Media.Imaging.BitmapCacheOption.OnLoad;

        image.StreamSource =
            stream;

        image.EndInit();

        image.Freeze();

        PairingQrImage.Source =
            image;
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
            // Network information is optional UI data.
        }

        return null;
    }

    protected override async void OnClosed(
        EventArgs e)
    {
        _refreshTimer.Stop();

        await _serverService.StopAsync();

        _serverService.Dispose();

        base.OnClosed(e);
    }
}