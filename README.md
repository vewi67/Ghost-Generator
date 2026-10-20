# Ghost Generator 👻

A tiny, intentionally useless Windows-only PowerShell project that creates empty ZIP files at a spooky pace.

## Download

Visit the [Releases page](https://github.com/vewi67/Ghost-Generator/releases) and download the ZIP package attached to the latest release.

Extract the entire ZIP before running the program. Keep `Ghost-Generator.exe` and `ghost.txt` in the same folder.

If no release is available yet, open [GitHub Actions](https://github.com/vewi67/Ghost-Generator/actions) and download the `Ghost-Generator-Windows` artifact from a successful build.

## How to use

1. Download and extract the package.
2. Run `Ghost-Generator.exe`.
3. Press **Enter** when you are ready.
4. Watch the countdown and the ghost-themed ZIP creation.
5. Press **Esc** to stop.

The console displays the ASCII ghost, then creates empty ZIP archives in the program's folder. Each filename gains another `o`, starting with `Ghost.zip`, `Ghoost.zip`, `Ghooost.zip`, and so on.

## Important notes

- **Windows only.** The executable is built from PowerShell using [ps2exe](https://github.com/MScholtes/PS2EXE).
- The program writes files to the folder containing the executable. Run it from a dedicated folder.
- The ZIP files are real, empty archives. Each is typically about 22 bytes before filesystem overhead.
- Filenames get longer every time. Windows limits the length of a single filename component, so the program cannot continue forever.
- If a file with the next generated name already exists, it may be overwritten.
- This is a silly programming experiment, not a useful file-generation or benchmarking tool. Stop it with **Esc** when you're done.

## Build it yourself

Requirements: Windows, PowerShell, and the `ps2exe` module.

```powershell
Install-Module ps2exe -Scope CurrentUser
Invoke-PS2EXE .\Ghost-Generator.ps1 .\Ghost-Generator.exe
Copy-Item .\ghost.txt .\ghost.txt
```

Keep `ghost.txt` next to the generated executable. The GitHub Actions workflow builds the executable automatically on pushes to `main` and publishes a downloadable package when a version tag such as `v1.0.0` is pushed.

## License

Released under the MIT License. See [LICENSE](LICENSE).
