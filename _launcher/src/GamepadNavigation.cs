using System;
using System.Runtime.InteropServices;
using System.Windows.Threading;

namespace BladeOfAgonyLauncher
{
    internal enum GamepadAction
    {
        Up,
        Down,
        Left,
        Right,
        Accept,
        Back,
        PreviousPage,
        NextPage
    }

    internal sealed class GamepadNavigation : IDisposable
    {
        private const ushort Up = 0x0001;
        private const ushort Down = 0x0002;
        private const ushort Left = 0x0004;
        private const ushort Right = 0x0008;
        private const ushort LeftShoulder = 0x0100;
        private const ushort RightShoulder = 0x0200;
        private const ushort A = 0x1000;
        private const ushort B = 0x2000;

        private readonly DispatcherTimer timer;
        private readonly Action<GamepadAction> handler;
        private ushort previousButtons;
        private ushort repeatingButton;
        private DateTime repeatAt;
        private bool disposed;

        internal GamepadNavigation(Action<GamepadAction> action)
        {
            handler = action;
            timer = new DispatcherTimer(DispatcherPriority.Input) {
                Interval = TimeSpan.FromMilliseconds(60)
            };
            timer.Tick += Tick;
            timer.Start();
        }

        internal bool Enabled { get; set; }

        public void Dispose()
        {
            if (disposed) return;
            disposed = true;
            timer.Stop();
            timer.Tick -= Tick;
        }

        private void Tick(object sender, EventArgs eventArgs)
        {
            if (!Enabled) {
                previousButtons = 0;
                return;
            }
            XInputState state;
            if (!TryGetState(out state)) {
                previousButtons = 0;
                return;
            }
            ushort buttons = state.Gamepad.Buttons;
            ushort pressed = (ushort)(buttons & ~previousButtons);
            if (pressed != 0) {
                DispatchFirst(pressed);
                repeatingButton = Repeatable(pressed);
                repeatAt = DateTime.UtcNow.AddMilliseconds(360);
            } else if (repeatingButton != 0 && (buttons & repeatingButton) != 0 &&
                    DateTime.UtcNow >= repeatAt) {
                DispatchFirst(repeatingButton);
                repeatAt = DateTime.UtcNow.AddMilliseconds(110);
            }
            if ((buttons & repeatingButton) == 0) repeatingButton = 0;
            previousButtons = buttons;
        }

        private void DispatchFirst(ushort buttons)
        {
            if ((buttons & Up) != 0) handler(GamepadAction.Up);
            else if ((buttons & Down) != 0) handler(GamepadAction.Down);
            else if ((buttons & Left) != 0) handler(GamepadAction.Left);
            else if ((buttons & Right) != 0) handler(GamepadAction.Right);
            else if ((buttons & A) != 0) handler(GamepadAction.Accept);
            else if ((buttons & B) != 0) handler(GamepadAction.Back);
            else if ((buttons & LeftShoulder) != 0) handler(GamepadAction.PreviousPage);
            else if ((buttons & RightShoulder) != 0) handler(GamepadAction.NextPage);
        }

        private static ushort Repeatable(ushort buttons)
        {
            foreach (ushort value in new[] { Up, Down, Left, Right }) {
                if ((buttons & value) != 0) return value;
            }
            return 0;
        }

        private static bool TryGetState(out XInputState state)
        {
            state = new XInputState();
            try {
                return XInputGetState14(0, out state) == 0;
            } catch (DllNotFoundException) {
                try {
                    return XInputGetState910(0, out state) == 0;
                } catch {
                    return false;
                }
            } catch (EntryPointNotFoundException) {
                return false;
            }
        }

        [DllImport("xinput1_4.dll", EntryPoint = "XInputGetState")]
        private static extern uint XInputGetState14(uint userIndex, out XInputState state);

        [DllImport("xinput9_1_0.dll", EntryPoint = "XInputGetState")]
        private static extern uint XInputGetState910(uint userIndex, out XInputState state);

        [StructLayout(LayoutKind.Sequential)]
        private struct XInputState
        {
            internal uint PacketNumber;
            internal XInputGamepad Gamepad;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct XInputGamepad
        {
            internal ushort Buttons;
            internal byte LeftTrigger;
            internal byte RightTrigger;
            internal short ThumbLX;
            internal short ThumbLY;
            internal short ThumbRX;
            internal short ThumbRY;
        }
    }
}
