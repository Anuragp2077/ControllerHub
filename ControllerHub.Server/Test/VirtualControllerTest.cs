using ControllerHub.Core.Controllers;
using ControllerHub.Server.Virtual;

namespace ControllerHub.Server.Test;

public static class VirtualControllerTest
{
    public static void Run()
    {
        Console.Clear();

        PrintInstructions();

        using var controller = new ViGEmVirtualController();

        Console.WriteLine();
        Console.WriteLine("Virtual Xbox controller connected.");
        Console.WriteLine("Open joy.cpl → Properties → Test.");
        Console.WriteLine();
        Console.WriteLine("Press any mapped key to test an input.");
        Console.WriteLine("Press ESC to exit.");
        Console.WriteLine();

        RunKeyboardLoop(controller);
    }

    private static void PrintInstructions()
    {
        Console.WriteLine("==============================================");
        Console.WriteLine("       ControllerHub Virtual Controller       ");
        Console.WriteLine("                Manual Tester                ");
        Console.WriteLine("==============================================");
        Console.WriteLine();

        Console.WriteLine("FACE BUTTONS");
        Console.WriteLine("  J = A");
        Console.WriteLine("  K = B");
        Console.WriteLine("  U = X");
        Console.WriteLine("  I = Y");
        Console.WriteLine();

        Console.WriteLine("SHOULDER / SYSTEM");
        Console.WriteLine("  Q = LB");
        Console.WriteLine("  E = RB");
        Console.WriteLine("  Enter = Start");
        Console.WriteLine("  Backspace = Back");
        Console.WriteLine("  G = Guide");
        Console.WriteLine();

        Console.WriteLine("D-PAD");
        Console.WriteLine("  W = Up");
        Console.WriteLine("  S = Down");
        Console.WriteLine("  A = Left");
        Console.WriteLine("  D = Right");
        Console.WriteLine();

        Console.WriteLine("STICK BUTTONS");
        Console.WriteLine("  L = L3");
        Console.WriteLine("  R = R3");
        Console.WriteLine();

        Console.WriteLine("LEFT STICK");
        Console.WriteLine("  Arrow Up    = Up");
        Console.WriteLine("  Arrow Down  = Down");
        Console.WriteLine("  Arrow Left  = Left");
        Console.WriteLine("  Arrow Right = Right");
        Console.WriteLine();

        Console.WriteLine("RIGHT STICK");
        Console.WriteLine("  T = Up");
        Console.WriteLine("  F = Down");
        Console.WriteLine("  V = Left");
        Console.WriteLine("  B = Right");
        Console.WriteLine();

        Console.WriteLine("TRIGGERS");
        Console.WriteLine("  Z = LT");
        Console.WriteLine("  X = RT");
        Console.WriteLine();

        Console.WriteLine("Press ESC to exit.");
        Console.WriteLine();
    }

    private static void RunKeyboardLoop(
        ViGEmVirtualController controller)
    {
        while (true)
        {
            ConsoleKeyInfo key = Console.ReadKey(intercept: true);

            if (key.Key == ConsoleKey.Escape)
            {
                break;
            }

            HandleKey(controller, key);
        }

        controller.Reset();

        Console.WriteLine();
        Console.WriteLine("Controller reset.");
        Console.WriteLine("Test finished.");
    }

    private static void HandleKey(
        ViGEmVirtualController controller,
        ConsoleKeyInfo key)
    {
        switch (key.Key)
        {
            // =========================
            // Face Buttons
            // =========================

            case ConsoleKey.J:
                TestButton(controller, ControllerButton.A, "A");
                break;

            case ConsoleKey.K:
                TestButton(controller, ControllerButton.B, "B");
                break;

            case ConsoleKey.U:
                TestButton(controller, ControllerButton.X, "X");
                break;

            case ConsoleKey.I:
                TestButton(controller, ControllerButton.Y, "Y");
                break;

            // =========================
            // Shoulder Buttons
            // =========================

            case ConsoleKey.Q:
                TestButton(
                    controller,
                    ControllerButton.LeftBumper,
                    "LB");
                break;

            case ConsoleKey.E:
                TestButton(
                    controller,
                    ControllerButton.RightBumper,
                    "RB");
                break;

            // =========================
            // System Buttons
            // =========================

            case ConsoleKey.Enter:
                TestButton(
                    controller,
                    ControllerButton.Start,
                    "Start");
                break;

            case ConsoleKey.Backspace:
                TestButton(
                    controller,
                    ControllerButton.Back,
                    "Back");
                break;

            case ConsoleKey.G:
                TestButton(
                    controller,
                    ControllerButton.Guide,
                    "Guide");
                break;

            // =========================
            // D-Pad
            // =========================

            case ConsoleKey.W:
                TestButton(
                    controller,
                    ControllerButton.DPadUp,
                    "D-Pad Up");
                break;

            case ConsoleKey.S:
                TestButton(
                    controller,
                    ControllerButton.DPadDown,
                    "D-Pad Down");
                break;

            case ConsoleKey.A:
                TestButton(
                    controller,
                    ControllerButton.DPadLeft,
                    "D-Pad Left");
                break;

            case ConsoleKey.D:
                TestButton(
                    controller,
                    ControllerButton.DPadRight,
                    "D-Pad Right");
                break;

            // =========================
            // Stick Buttons
            // =========================

            case ConsoleKey.L:
                TestButton(
                    controller,
                    ControllerButton.LeftStick,
                    "L3");
                break;

            case ConsoleKey.R:
                TestButton(
                    controller,
                    ControllerButton.RightStick,
                    "R3");
                break;

            // =========================
            // Left Stick
            // =========================

            case ConsoleKey.UpArrow:
                SetLeftStick(
                    controller,
                    0f,
                    1f,
                    "Left Stick Up");
                break;

            case ConsoleKey.DownArrow:
                SetLeftStick(
                    controller,
                    0f,
                    -1f,
                    "Left Stick Down");
                break;

            case ConsoleKey.LeftArrow:
                SetLeftStick(
                    controller,
                    -1f,
                    0f,
                    "Left Stick Left");
                break;

            case ConsoleKey.RightArrow:
                SetLeftStick(
                    controller,
                    1f,
                    0f,
                    "Left Stick Right");
                break;

            // =========================
            // Right Stick
            // =========================

            case ConsoleKey.T:
                SetRightStick(
                    controller,
                    0f,
                    1f,
                    "Right Stick Up");
                break;

            case ConsoleKey.F:
                SetRightStick(
                    controller,
                    0f,
                    -1f,
                    "Right Stick Down");
                break;

            case ConsoleKey.V:
                SetRightStick(
                    controller,
                    -1f,
                    0f,
                    "Right Stick Left");
                break;

            case ConsoleKey.B:
                SetRightStick(
                    controller,
                    1f,
                    0f,
                    "Right Stick Right");
                break;

            // =========================
            // Triggers
            // =========================

            case ConsoleKey.Z:
                TestTrigger(
                    controller,
                    ControllerTrigger.Left,
                    "LT");
                break;

            case ConsoleKey.X:
                TestTrigger(
                    controller,
                    ControllerTrigger.Right,
                    "RT");
                break;
        }
    }

    private static void TestButton(
        ViGEmVirtualController controller,
        ControllerButton button,
        string name)
    {
        Console.WriteLine($"Testing {name}");

        controller.SetButton(button, true);

        Thread.Sleep(200);

        controller.SetButton(button, false);
    }

    private static void SetLeftStick(
        ViGEmVirtualController controller,
        float x,
        float y,
        string name)
    {
        Console.WriteLine(
            $"{name}: X={x:0.00}, Y={y:0.00}");

        controller.SetStick(
            ControllerStick.Left,
            x,
            y);

        Thread.Sleep(300);

        controller.SetStick(
            ControllerStick.Left,
            0f,
            0f);
    }

    private static void SetRightStick(
        ViGEmVirtualController controller,
        float x,
        float y,
        string name)
    {
        Console.WriteLine(
            $"{name}: X={x:0.00}, Y={y:0.00}");

        controller.SetStick(
            ControllerStick.Right,
            x,
            y);

        Thread.Sleep(300);

        controller.SetStick(
            ControllerStick.Right,
            0f,
            0f);
    }

    private static void TestTrigger(
        ViGEmVirtualController controller,
        ControllerTrigger trigger,
        string name)
    {
        Console.WriteLine($"{name}: 25%");

        controller.SetTrigger(
            trigger,
            0.25f);

        Thread.Sleep(300);

        Console.WriteLine($"{name}: 50%");

        controller.SetTrigger(
            trigger,
            0.50f);

        Thread.Sleep(300);

        Console.WriteLine($"{name}: 75%");

        controller.SetTrigger(
            trigger,
            0.75f);

        Thread.Sleep(300);

        Console.WriteLine($"{name}: 100%");

        controller.SetTrigger(
            trigger,
            1.0f);

        Thread.Sleep(300);

        Console.WriteLine($"{name}: released");

        controller.SetTrigger(
            trigger,
            0f);
    }
}