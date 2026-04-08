#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POLICY_PATH="${1:-$ROOT_DIR/Documentation/flagship-media-policy.json}"
MEDIA_README_PATH="${2:-$ROOT_DIR/Documentation/Assets/Flagship-Demo/README.md}"

if [[ "$POLICY_PATH" != /* ]]; then
  POLICY_PATH="$ROOT_DIR/$POLICY_PATH"
fi

if [[ "$MEDIA_README_PATH" != /* ]]; then
  MEDIA_README_PATH="$ROOT_DIR/$MEDIA_README_PATH"
fi

ruby - "$ROOT_DIR" "$POLICY_PATH" "$MEDIA_README_PATH" <<'RUBY'
require "json"
require "open3"
require "pathname"

root_dir, policy_path, media_readme_path = ARGV

abort("Missing flagship media policy: #{policy_path}") unless File.exist?(policy_path)
abort("Missing flagship media README: #{media_readme_path}") unless File.exist?(media_readme_path)

policy = JSON.parse(File.read(policy_path))
asset_root = File.expand_path(policy.fetch("assetRoot"), root_dir)
abort("Missing flagship media asset root: #{asset_root}") unless Dir.exist?(asset_root)

status_values = Array(policy.fetch("statusValues"))
required_files = Array(policy.fetch("requiredFilesWhenPublished"))

readme = File.read(media_readme_path)
status = readme[/Current status: `([^`]+)`/, 1]
abort("Flagship media README must declare current status.") unless status
abort("Invalid flagship media status: #{status}") unless status_values.include?(status)

existing_files = Dir.children(asset_root)
  .reject { |name| name == "README.md" || name.start_with?(".") }
  .select { |name| File.file?(File.join(asset_root, name)) }
  .sort

errors = []

def validate_png_truth(path)
  script = <<~PY
    import struct
    import sys
    import zlib

    path = sys.argv[1]
    with open(path, "rb") as handle:
        data = handle.read()

    if data[:8] != b"\\x89PNG\\r\\n\\x1a\\n":
        print(f"Flagship screenshot is not a valid PNG: {path}")
        sys.exit(1)

    offset = 8
    idat = b""
    width = height = None
    bit_depth = color_type = None

    while offset < len(data):
        length = struct.unpack(">I", data[offset:offset + 4])[0]
        offset += 4
        chunk_type = data[offset:offset + 4]
        offset += 4
        chunk_data = data[offset:offset + length]
        offset += length + 4

        if chunk_type == b"IHDR":
            width, height, bit_depth, color_type, _, _, _ = struct.unpack(">IIBBBBB", chunk_data)
        elif chunk_type == b"IDAT":
            idat += chunk_data
        elif chunk_type == b"IEND":
            break

    if width is None or height is None:
        print(f"Flagship screenshot is missing PNG header metadata: {path}")
        sys.exit(1)

    channels = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}.get(color_type)
    if bit_depth not in (8, 16) or channels is None:
        print(f"Flagship screenshot uses unsupported PNG format for validation: {path}")
        sys.exit(1)

    raw = zlib.decompress(idat)
    bytes_per_sample = 1 if bit_depth == 8 else 2
    bytes_per_pixel = channels * bytes_per_sample
    stride = width * bytes_per_pixel
    previous = [0] * stride
    cursor = 0
    non_transparent = 0
    brightness_total = 0.0
    brightness_samples = 0

    def paeth(a, b, c):
        predictor = a + b - c
        pa = abs(predictor - a)
        pb = abs(predictor - b)
        pc = abs(predictor - c)
        if pa <= pb and pa <= pc:
            return a
        if pb <= pc:
            return b
        return c

    for _ in range(height):
        filter_type = raw[cursor]
        cursor += 1
        row = bytearray(raw[cursor:cursor + stride])
        cursor += stride

        if filter_type == 1:
            for index in range(bytes_per_pixel, stride):
                row[index] = (row[index] + row[index - bytes_per_pixel]) & 255
        elif filter_type == 2:
            for index in range(stride):
                row[index] = (row[index] + previous[index]) & 255
        elif filter_type == 3:
            for index in range(stride):
                left = row[index - bytes_per_pixel] if index >= bytes_per_pixel else 0
                up = previous[index]
                row[index] = (row[index] + ((left + up) // 2)) & 255
        elif filter_type == 4:
            for index in range(stride):
                left = row[index - bytes_per_pixel] if index >= bytes_per_pixel else 0
                up = previous[index]
                up_left = previous[index - bytes_per_pixel] if index >= bytes_per_pixel else 0
                row[index] = (row[index] + paeth(left, up, up_left)) & 255

        previous = list(row)

        step = max(1, width // 64)
        for x in range(0, width, step):
            pixel = row[x * bytes_per_pixel:(x + 1) * bytes_per_pixel]
            components = []
            for channel_index in range(channels):
                start = channel_index * bytes_per_sample
                if bytes_per_sample == 1:
                    components.append(pixel[start])
                else:
                    value = (pixel[start] << 8) | pixel[start + 1]
                    components.append(value / 257)

            alpha = components[3] if channels == 4 else 255
            if alpha > 0:
                non_transparent += 1
            brightness_total += sum(components[:3]) / 3
            brightness_samples += 1

    average_brightness = brightness_total / max(1, brightness_samples)

    if non_transparent == 0:
        print(f"Flagship screenshot is fully transparent: {path}")
        sys.exit(1)

    if average_brightness <= 1:
        print(f"Flagship screenshot appears visually empty: {path}")
        sys.exit(1)
  PY

  output, status = Open3.capture2e("python3", "-", path, stdin_data: script)
  status.success? ? nil : output.strip
end

def validate_video_truth(path)
  unless system("command -v ffprobe >/dev/null 2>&1")
    warn "Flagship media video duration validation skipped because ffprobe is unavailable."
    return nil
  end

  output, status = Open3.capture2e(
    "ffprobe",
    "-v",
    "error",
    "-show_entries",
    "format=duration",
    "-of",
    "default=noprint_wrappers=1:nokey=1",
    path
  )

  return "Could not read flagship media video duration: #{path}" unless status.success?

  duration = output.to_f
  return "Flagship media video is too short to be a real run capture: #{path}" if duration < 2.0

  nil
end

if status == "published"
  required_files.each do |name|
    errors << "Missing required published media asset #{name} in #{asset_root}" unless existing_files.include?(name)
  end

  screenshot_path = File.join(asset_root, "intelligent-camera-success.png")
  video_path = File.join(asset_root, "intelligent-camera-run.mp4")

  if File.exist?(screenshot_path)
    png_error = validate_png_truth(screenshot_path)
    errors << png_error if png_error
  end

  if File.exist?(video_path)
    video_error = validate_video_truth(video_path)
    errors << video_error if video_error
  end
else
  if existing_files.any?
    errors << "Flagship media status is not-published but media files already exist: #{existing_files.join(', ')}"
  end
end

if errors.empty?
  puts "Flagship media assets validated with status '#{status}'."
  exit 0
end

warn "Flagship media asset validation failed:"
errors.each { |error| warn "- #{error}" }
exit 1
RUBY
