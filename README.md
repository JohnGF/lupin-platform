# LUPIN platform

**LUPIN, Learning User Physiological Intent Networks**: the open-source software behind the
[LUPIN](https://lupin.johngf.xyz/) neuroengineering / BCI project.

This repository is the workspace that ties the pieces together. Each component lives in its own
repository and is included here as a git submodule, so one clone gives you the whole platform in
the layout the components expect.

## Architecture

Hub and spokes over [Lab Streaming Layer](https://labstreaminglayer.org/) (LSL): every device
repository publishes LSL streams, and `nautilus_bci` is the hub that discovers, records
(BIDS) and decodes them. The hub never imports device code. See the
[nautilus_bci architecture docs](https://johngf.github.io/nautilus_bci/architecture/).

```
 g.Nautilus EEG/fNIRS ─┐
 Galaxy Watch IMU/PPG ─┤
 HIKMICRO thermal ─────┼──► LSL ──► nautilus_bci  (recording, BIDS, decoding, tasks, games)
 Kinect head pose/gaze ┘
```

`bci_workshop` is a separate, self-contained setup (Muse EEG and phone/watch IMU) for teaching.

## Components

| Repository | Role | LSL streams |
|---|---|---|
| [nautilus_bci](https://github.com/JohnGF/nautilus_bci) | Hub: g.Nautilus EEG/fNIRS bridges, multimodal BIDS recorder, decoding, tasks and games. [Docs](https://johngf.github.io/nautilus_bci/) | `gNautilus_EEG`, `gNautilus_fNIRS`, markers |
| [kinect_eye_tracker](https://github.com/JohnGF/kinect_eye_tracker) | Kinect v2 head pose and coarse screen gaze (MediaPipe, L2CS-Net) | `KinectGaze` |
| [kinect2pipe](https://github.com/JohnGF/kinect2pipe) | Kinect v2 on Linux: 1080p webcam via v4l2loopback, IR night vision, colour + IR + depth over shared memory (fork of swedishborgie/kinect2pipe). Feeds `kinect_eye_tracker`. | none (frame source) |
| [hikmicro-lsl](https://github.com/JohnGF/hikmicro-lsl) | HIKMICRO Pocket 2 / InfiRay thermal camera to LSL, plus offline temperature extraction | thermal |
| [galaxy_watch_lsl](https://github.com/JohnGF/galaxy_watch_lsl) | Wear OS / Android app streaming IMU, heart rate and touch over UDP (bridged to LSL in nautilus_bci) | `Smartwatch_IMU`, `Smartwatch_PPG` |
| [bci_workshop](https://github.com/JohnGF/bci_workshop) | Workshop material: Muse EEG and phone/watch IMU, real-time dashboard and BCI-controlled games | Muse EEG, IMU |

Each repository has its own README, setup and licence.

## Getting started

```bash
git clone --recurse-submodules https://github.com/JohnGF/lupin-platform.git
cd lupin-platform
```

Already cloned without submodules: `git submodule update --init`.
To move every component to its latest default branch: `git submodule update --remote`.

Then follow the README of the component you need. Most Python components run with
[uv](https://docs.astral.sh/uv/). The Kinect pipeline also needs
[libfreenect2](https://github.com/OpenKinect/libfreenect2) built next to `kinect2pipe`
(`../libfreenect2/build/lib`), or its libraries copied to `kinect2pipe/lib/`. LSL discovery
needs the firewall open:
[LSL network setup](https://johngf.github.io/nautilus_bci/guides/lsl_network_setup/).

## Licence

The workspace files here are MIT ([LICENSE](LICENSE)). Each component carries its own licence.
