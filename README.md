# Portside

A macOS menu bar app that shows which processes are listening on TCP ports. Built for developers who juggle multiple dev servers.

**Portside** sits in your menu bar and shows a live count of active ports. Click it to see every listening process with its port, project name, git branch, and uptime — then kill or open any of them in one click.

## Features

- Scans TCP listeners via `lsof` (no root required)
- Detects project name from the process working directory
- Shows the current git branch for each process
- Kill processes or open `localhost:<port>` in your browser
- Lightweight — pure Swift, no dependencies

## Requirements

- macOS 14 (Sonoma) or later

## Install

Download `Portside.zip` from [Releases](../../releases), unzip, and drag `Portside.app` to your Applications folder.

> Since the app is not signed with a Developer ID, macOS will block it on first launch. Right-click the app → **Open** → click **Open** in the dialog to bypass Gatekeeper. You only need to do this once.

## Build from source

```
git clone https://github.com/alexmercyadeiza/portside.git
cd portside
make build    # produces Portside.app in the project root
make run      # build + open
make install  # build + copy to /Applications
```

## License

MIT
