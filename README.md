# Nakime

https://github.com/user-attachments/assets/8f6274f1-18b9-4f26-8694-257ce0428bbc

<div align="center">
  <img src="assets/icons/nakime-256.png"/>
  <p>Meet Nakime</p>
</div>

## Description
Nakime is a Windows session uptime tracker. It records **when your system was turned on**, **how long it stayed up**, **when it was shut down**, and the **idle time between sessions**. You can also view a graph of system uptime for a selected time period. 

Please view the video above to know more.

**Pro-tip**: Did you know? Nakime tracks sessions even without logging in, so you can see if someone tries to access your system while you're away.

## Features
- ⚡ Automatically keeps a track of system uptime
- 👌 See Live Session Uptime right when you open the app
- 🪸 System Uptime Graph
- 📀 Export your usage data in excel or json format
- ❤️ Dedicated command-line tool (called '[session-uptime](https://github.com/omegaui/uptime)')

## Installing
### Compatibilty
Nakime is tested on following version of Windows OS:
- ✔️ Windows 11 24H2
- ❌ Windows 10 (Please report any issue you face)

A dedicated installer is published with each release of Nakime.

Please checkout [the latest release's "Assets"](https://github.com/omegaui/nakime/releases/latest) to install Nakime.

# Technical Details
Nakime is built from scratch with three layers:

1. [Windows Service](https://github.com/omegaui/NakimeWindowsService) – The core of Nakime, responsible for tracking uptime data.
2. Flutter Desktop App (The face of Nakime) – A user-friendly interface to view the tracked data.
3. [Dart Command Line Tool](https://github.com/omegaui/uptime) – A lightweight cli alternative for querying the live session data.

The first layer handles session data management, while the other two provide readable outputs.
The core service operates independently, while the other two layers rely on its data. If you modify the core’s data schema, you may need to update the Flutter app and CLI tool to prevent compatibility issues.

## Building from source
Since, Nakime is built using Flutter.
Compiling it is quite easy, but you need to have following version of Flutter SDK to built it.
```sh
Flutter 3.24.4 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 603104015d (3 months ago) • 2024-10-24 08:01:25 -0700
Engine • revision db49896cf2
Tools • Dart 3.5.4 • DevTools 2.37.3
```

then, follow these steps to compile it from source.

1. Clone the base repository
```sh
git clone https://github.com/omegaui/nakime
```

2. Go to the cloned folder
```sh
cd nakime
```

3. Run flutter build
```sh
flutter build windows --release
```

If you like the project, consider giving it a star, this way GitHub will show it to more users.

## App name inspiration
The name "Nakime" is inspired from a popular anime named "Demon Slayer", It's my favourite anime so far. If you have watched Demon Slayer, then you already know why I named this app after "Nakime", if not, then, you can search for "Nakime Demon Slayer" and see some videos of it, if you want ;)
