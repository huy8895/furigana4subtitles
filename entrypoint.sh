#!/bin/bash
set -e

# Nếu không truyền đối số, in hướng dẫn sử dụng
if [ "$#" -lt 1 ]; then
    echo "=================================================================="
    echo "         Furigana4Subtitles Docker Burn-in Tool                   "
    echo "=================================================================="
    echo "Cú pháp sử dụng:"
    echo "  docker run --rm -v \$(pwd):/data furigana4subtitles <file_srt> [file_video] [file_output]"
    echo ""
    echo "Chế độ 1: Chỉ tạo file phụ đề .ass (không ghép vào video)"
    echo "  docker run --rm -v \$(pwd):/data furigana4subtitles /data/sub.srt"
    echo ""
    echo "Chế độ 2: Tạo file phụ đề .ass và tự động Burn-in vào video"
    echo "  docker run --rm -v \$(pwd):/data furigana4subtitles /data/sub.srt /data/video.mp4"
    echo ""
    echo "Chế độ 3: Chỉ định rõ tên file video đầu ra mong muốn"
    echo "  docker run --rm -v \$(pwd):/data furigana4subtitles /data/sub.srt /data/video.mp4 /data/output_hardsub.mp4"
    echo "=================================================================="
    exit 1
fi

SRT_FILE="$1"
VIDEO_FILE="$2"
OUTPUT_FILE="$3"

# Xác định đường dẫn file .ass sẽ sinh ra (cùng thư mục và cùng tên với file .srt)
SRT_DIR=$(dirname "$SRT_FILE")
SRT_BASE=$(basename "$SRT_FILE")
SRT_RAW="${SRT_BASE%.*}"
ASS_FILE="${SRT_DIR}/${SRT_RAW}.ass"

echo "==== [1/2] Đang tạo phụ đề .ass có Furigana (Font: Osaka-Mono)... ===="
./furigana4subtitles "$SRT_FILE"

if [ ! -f "$ASS_FILE" ]; then
    echo "Lỗi: Không tìm thấy file .ass được tạo tại $ASS_FILE"
    exit 1
fi
echo "Đã tạo phụ đề thành công tại: $ASS_FILE"

# Nếu người dùng cung cấp file video, tiến hành burn-in
if [ -n "$VIDEO_FILE" ]; then
    if [ ! -f "$VIDEO_FILE" ]; then
        echo "Lỗi: Không tìm thấy file video đầu vào tại $VIDEO_FILE"
        exit 1
    fi

    # Tự động tạo tên file output nếu không chỉ định
    if [ -z "$OUTPUT_FILE" ]; then
        VIDEO_DIR=$(dirname "$VIDEO_FILE")
        VIDEO_BASE=$(basename "$VIDEO_FILE")
        VIDEO_RAW="${VIDEO_BASE%.*}"
        VIDEO_EXT="${VIDEO_BASE##*.}"
        OUTPUT_FILE="${VIDEO_DIR}/${VIDEO_RAW}_furigana.${VIDEO_EXT}"
    fi

    echo "==== [2/2] Đang tiến hành Burn-in phụ đề vào video bằng FFmpeg... ===="
    echo "-> Video gốc: $VIDEO_FILE"
    echo "-> File phụ đề: $ASS_FILE"
    echo "-> Video đầu ra: $OUTPUT_FILE"

    # Thực hiện lệnh burn-in phụ đề bằng FFmpeg dùng filter subtitles
    # filter subtitles sẽ tự động lấy font Osaka-Mono đã được cài đặt trong container để render
    ffmpeg -y -i "$VIDEO_FILE" -vf "subtitles='$ASS_FILE'" -c:a copy "$OUTPUT_FILE"

    echo "==== HOÀN THÀNH! Video hardsub đã được lưu tại: $OUTPUT_FILE ===="
else
    echo "==== HOÀN THÀNH! Đã tạo xong file .ass tại: $ASS_FILE (Không có video đầu vào để burn-in) ===="
fi
