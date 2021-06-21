# createchapter
Simple chapter maker with ability to export a FFmpeg Metadata file with chapter information.
The exported file can be loaded by mpv with the `--chapters-file=<filename>` option.

## Usage
Place the `createchapter.lua` file into mpv scripts folder.

## Keybind
`Shift-c` - Mark chapters

`Shift-x` - Export ffmetadata file

### mpv-ch
Open videos with `mpv-ch` to load the chapter file automatically.
#### To install:
Move the `mpv-ch` script to `/usr/local/bin` or your preferred binary installation directory.
And move `mpv-ch.desktop` to `$HOME/.local/share/applications/`.
