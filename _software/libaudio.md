---
layout: page
---

Library for manipulation of audio files.

[View source](https://github.com/jamlib/libaudio "View source code for libaudio"){: target="_blank"}

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
