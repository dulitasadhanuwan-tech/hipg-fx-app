import struct
import zlib

def make_png(width, height, r, g, b):
    # Minimal solid color PNG with border
    raw_data = bytearray()
    for y in range(height):
        raw_data.append(0) # filter type none
        for x in range(width):
            # Gold border
            if x < 2 or x >= width - 2 or y < 2 or y >= height - 2:
                raw_data.extend([245, 158, 11, 255]) # amber #f59e0b
            else:
                raw_data.extend([r, g, b, 255]) # navy #002B49
    
    def chunk(tag, data):
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xffffffff)
    
    png = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    png += chunk(b"IHDR", ihdr)
    compressed = zlib.compress(bytes(raw_data), 9)
    png += chunk(b"IDAT", compressed)
    png += chunk(b"IEND", b"")
    return png

def make_ico(png_data, width, height):
    ico_header = struct.pack("<HHH", 0, 1, 1) # reserved, type 1 (icon), 1 image
    png_size = len(png_data)
    # Entry: bWidth, bHeight, bColorCount, bReserved, wPlanes, wBitCount, dwBytesInRes, dwImageOffset
    ico_entry = struct.pack("<BBBBHHII", width, height, 0, 0, 1, 32, png_size, 6 + 16)
    return ico_header + ico_entry + png_data

png_32 = make_png(32, 32, 0, 43, 73)
ico_data = make_ico(png_32, 32, 32)

with open("c:/Users/HIPG-FIN/Documents/HIPG FX APP/frontend/favicon.ico", "wb") as f:
    f.write(ico_data)

with open("c:/Users/HIPG-FIN/Documents/HIPG FX APP/hipg_fx.ico", "wb") as f:
    f.write(ico_data)

print("Icons created successfully.")
