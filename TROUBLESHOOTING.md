# Troubleshooting: Hyprland cursor and pointer issues

Use this guide if the mouse pointer or touchpad behaves strangely in Hyprland—for example, movement seems restricted to one axis, the pointer jumps when changing windows, or the pointer does not visually track movement correctly.

These are diagnostic steps. The commands below change the running Hyprland session only; they do not permanently edit your configuration.

## 1. Open a terminal

Press **Super + Q** to open Kitty.

## 2. Test the cursor settings one at a time

Run the first command:

```bash
hyprctl keyword cursor:no_hardware_cursors 1
```

Test both the mouse and touchpad. Check horizontal and vertical movement, and switch between windows.

Then run:

```bash
hyprctl keyword cursor:no_warps true
```

Test again. This disables Hyprland's automatic cursor warping.

Then run:

```bash
hyprctl keyword input:follow_mouse 0
```

Test again. This stops the pointer from changing keyboard focus just because it moves over another window.

**Important:** Test after each command and note exactly which command, if any, changes the behaviour. Do not assume a setting fixed the issue until you have tested both input devices and switched windows.

## 3. Check whether it happens outside Hyprland

Restart into Windows and test the same mouse and touchpad.

- If the problem happens in Windows too, it may not be specific to Hyprland.
- If it happens only in Hyprland, continue with the diagnostic output below.

## 4. If the issue is still present

Open Kitty with **Super + Q** and run:

```bash
hyprctl devices
```

Copy the complete output. Also run:

```bash
hyprctl configerrors
```

Keep both outputs so they can be reviewed together.

## 5. What to report

Send back:

1. Whether the issue happens in Windows or only in Hyprland.
2. Whether the first, second, or third command changed anything.
3. The output of `hyprctl devices` and `hyprctl configerrors` if none of the tests helped.

Do not reinstall Hyprland or change random input-driver settings while diagnosing this.

## Notes

- The repository's Hyprland config already includes `cursor { no_hardware_cursors = 1 }` as a possible workaround for cursor-rendering problems.
- The other two settings are intentionally tested at runtime first. Only make them permanent in `hyprland.conf` after confirming they help.
- Runtime keyword changes are temporary and will be reset when the Hyprland session restarts.
