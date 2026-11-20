import struct
import zlib
import math

def make_pwa_png(size):
    raw_data = bytearray()
    w = size
    h = size
    # Navy background #002B49 (0, 43, 73)
    # Gold border #f59e0b (245, 158, 11)
    border_thickness = max(2, size // 24)
    radius = size // 5
    
    for y in range(h):
        raw_data.append(0) # filter type 0
        for x in range(w):
            # Check rounded corner
            dx = min(x, w - 1 - x)
            dy = min(y, h - 1 - y)
            is_corner = False
            if dx < radius and dy < radius:
                dist = math.sqrt((radius - dx)**2 + (radius - dy)**2)
                if dist > radius:
                    # Transparent outside corner
                    raw_data.extend([0, 0, 0, 0])
                    continue
            
            # Gold border
            if (x < border_thickness or x >= w - border_thickness or
                y < border_thickness or y >= h - border_thickness or
                (dx < radius and dy < radius and abs(dist - radius) < border_thickness)):
                raw_data.extend([245, 158, 11, 255])
            else:
                # Corporate navy fill
                raw_data.extend([0, 43, 73, 255])
    
    def chunk(tag, data):
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xffffffff)
    
    png = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
    png += chunk(b"IHDR", ihdr)
    compressed = zlib.compress(bytes(raw_data), 9)
    png += chunk(b"IDAT", compressed)
    png += chunk(b"IEND", b"")
    return png

with open("icon-192.png", "wb") as f:
    f.write(make_pwa_png(192))

with open("icon-512.png", "wb") as f:
    f.write(make_pwa_png(512))

print("Generated icon-192.png and icon-512.png successfully.")
