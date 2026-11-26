#!/usr/bin/env bash
# Video üretim araçları kurulumu (macOS)
set -e
[ "$(uname)" = "Darwin" ] || { echo "Bu betik macOS içindir."; exit 1; }

echo "==> Homebrew kontrol ediliyor..."
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
fi

echo "==> Python kontrol ediliyor (yoksa kurulacak)..."
command -v python3 >/dev/null || brew install python
echo "==> Node.js kontrol ediliyor (yoksa kurulacak)..."
command -v node >/dev/null || brew install node

echo "==> 1/5 FFmpeg kuruluyor..."
brew install ffmpeg
echo "==> 2/5 yt-dlp kuruluyor..."
brew install yt-dlp
echo "==> 3/5 OpenAI Whisper kuruluyor..."
python3 -m pip install -U openai-whisper || python3 -m pip install -U --user --break-system-packages openai-whisper
echo "==> 4/5 HyperFrames skill'i ekleniyor..."
npx -y skills add heygen-com/hyperframes -g -y
echo "==> 5/5 GSAP skill'leri ekleniyor..."
npx -y skills add greensock/gsap-skills -g -y

echo "==> Testler çalıştırılıyor..."
T=$(mktemp -d)
ffmpeg -hide_banner -loglevel error -f lavfi -i "sine=frequency=440:duration=2" "$T/test.wav" && echo "FFmpeg: OK (test sesi üretildi)"
yt-dlp --simulate --quiet "https://www.youtube.com/watch?v=jNQXAC9IVRw" && echo "yt-dlp: OK"
python3 -c "import whisper; print('Whisper: OK, modeller:', whisper.available_models()[:3])"
npx -y skills list -g 2>/dev/null | grep -Ei "hyperframes|gsap" || echo "Skill listesi: yukarıdaki npx çıktısını kontrol edin"

echo; echo "===== SÜRÜMLER ====="
echo "Python : $(python3 --version)"
echo "Node   : $(node --version)"
echo "FFmpeg : $(ffmpeg -version | head -1)"
echo "yt-dlp : $(yt-dlp --version)"
echo "Whisper: $(python3 -m pip show openai-whisper | grep Version)"
