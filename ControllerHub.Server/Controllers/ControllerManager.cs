using ControllerHub.Server.Virtual;

namespace ControllerHub.Server.Controllers;

public sealed class ControllerManager : IDisposable
{
    private const int MaxSlots = 4;

    private readonly Dictionary<int, ControllerSlot> _slots = new();
    private readonly HashSet<int> _reservedSlots = new();

    private readonly object _lock = new();

    public IReadOnlyCollection<ControllerSlot> Slots
    {
        get
        {
            lock (_lock)
            {
                return _slots.Values.ToArray();
            }
        }
    }

    public ControllerSlot AcquireSlot()
    {
        lock (_lock)
        {
            Console.WriteLine(
                $"MANAGER {GetHashCode()} | " +
                $"Slots={_slots.Count} | " +
                $"Reserved={string.Join(",", _reservedSlots)}");

            for (int slotNumber = 1;
                 slotNumber <= MaxSlots;
                 slotNumber++)
            {
                /*
                 * Never give an already reserved slot
                 * to another connection.
                 */

                if (_reservedSlots.Contains(slotNumber))
                {
                    continue;
                }

                /*
                 * Get or create the virtual controller.
                 */

                if (!_slots.TryGetValue(
                        slotNumber,
                        out ControllerSlot? slot))
                {
                    slot = CreateSlot(slotNumber);

                    _slots.Add(
                        slotNumber,
                        slot);
                }

                /*
                 * Reserve this slot BEFORE returning it.
                 */

                _reservedSlots.Add(slotNumber);

                slot.Connect();

                Console.WriteLine(
                    $"ALLOCATED Slot {slotNumber}");

                Console.WriteLine(
                    $"CURRENT RESERVED SLOTS: " +
                    $"{string.Join(", ", _reservedSlots)}");

                return slot;
            }

            throw new InvalidOperationException(
                "All 4 controller slots are currently in use.");
        }
    }

    public void ReleaseSlot(
        ControllerSlot slot)
    {
        lock (_lock)
        {
            Console.WriteLine(
                $"RELEASING Slot {slot.SlotNumber}");

            slot.Disconnect();

            _reservedSlots.Remove(
                slot.SlotNumber);

            Console.WriteLine(
                $"Slot {slot.SlotNumber} is now available.");

            Console.WriteLine(
                $"CURRENT RESERVED SLOTS: " +
                $"{string.Join(", ", _reservedSlots)}");
        }
    }

    public ControllerSlot? GetSlot(
        int slotNumber)
    {
        lock (_lock)
        {
            _slots.TryGetValue(
                slotNumber,
                out ControllerSlot? slot);

            return slot;
        }
    }

    public bool RemoveSlot(
        int slotNumber)
    {
        lock (_lock)
        {
            if (!_slots.Remove(
                    slotNumber,
                    out ControllerSlot? slot))
            {
                return false;
            }

            _reservedSlots.Remove(
                slotNumber);

            slot.Dispose();

            return true;
        }
    }

    public void Dispose()
    {
        lock (_lock)
        {
            foreach (ControllerSlot slot in _slots.Values)
            {
                slot.Dispose();
            }

            _slots.Clear();
            _reservedSlots.Clear();
        }
    }

    private static ControllerSlot CreateSlot(
        int slotNumber)
    {
        var virtualController =
            new ViGEmVirtualController();

        return new ControllerSlot(
            slotNumber,
            virtualController);
    }
}