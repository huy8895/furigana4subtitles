FROM ubuntu:22.04

# Tránh các câu hỏi tương tác trong quá trình cài đặt package
ENV DEBIAN_FRONTEND=noninteractive

# Cài đặt các gói phụ thuộc cần thiết cho dự án và thiết lập locale tiếng Nhật
RUN apt-get update && apt-get install -y \
    build-essential \
    mecab \
    libmecab-dev \
    mecab-ipadic-utf8 \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt locale ja_JP.UTF-8 (cần thiết cho chương trình xử lý ký tự tiếng Nhật UTF-8)
RUN locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8

WORKDIR /app

# Sao chép toàn bộ mã nguồn vào container
COPY . .

# Biên dịch chương trình
RUN make clean && make

# Điểm chạy mặc định của container sẽ là chương trình command-line
ENTRYPOINT ["./furigana4subtitles"]
