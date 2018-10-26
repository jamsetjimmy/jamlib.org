---
layout: software
title: libaudio
desc: "Library for manipulation of audio files"
src: https://github.com/jamlib/libaudio
---

## ffmpeg

A wrapper around `ffmpeg` providing the following exported functions:

```go
ToMp3(c *Mp3Config) (string, error)
OptimizeAlbumArt(s, d string) (string, error)
Exec(args ...string) (string, error)
```

## ffprobe

A wrapper around `ffprobe` providing the following exported functions:

```go
GetData(filePath string) (*Data, error)
EmbeddedImage() (int, int, bool)
```

## fsutil

Exports various file system functions.
