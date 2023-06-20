# aes

|                           |               |
| ------------------------- | ------------- |
| **Description**           | AES registers |
| **Default base address**  | `0x0`         |
| **Register width**        | 32 bits       |
| **Default address width** | 32 bits       |
| **Register count**        | 2             |
| **Range**                 | 20 bytes      |
| **Revision**              | 5             |

## Overview

| Offset | Name    | Description        | Type   |
| ------ | ------- | ------------------ | ------ |
| `0x0`  | control | modes of operation | REG    |
| `0x4`  | key     |                    | ARR[4] |

## Registers

| Offset | Name         | Description        | Type   | Access | Attributes | Reset |
| ------ | ------------ | ------------------ | ------ | ------ | ---------- | ----- |
| `0x0`  | control      | modes of operation | REG    | R/W    |            | `0x0` |
|        | [0] mode     |                    |        |        |            | `0x0` |
| `0x4`  | key          |                    | ARR[4] | W      |            | `0x0` |
|        | [31:0] value |                    |        |        |            | `0x0` |

