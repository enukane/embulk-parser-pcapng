# Pcapng parser plugin for Embulk

TODO: Write short description here

## Overview

* **Plugin type**: parser
* **Load all or nothing**: yes
* **Resume supported**: no

## Configuration

- **property1**: description (string, required)
- **property2**: description (integer, default: default-value)

## Example

```yaml
in:
  type: any file input plugin type
  parser:
    type: pcapng
    property1: example1
    property2: example2
```

## Build

```
$ rake
```
