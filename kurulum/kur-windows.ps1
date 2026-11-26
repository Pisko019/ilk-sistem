# Video üretim araçları kurulumu (Windows) - PowerShell'de çalıştırın
$ErrorActionPreference = "Continue"
function Yenile { $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User") }
$wg = "--accept-source-agreements","--accept-package-agreements","-e"

# Windows'taki "python" kısayolu Microsoft Store'u açan sahte bir dosya olabilir.
# Gerçek Python'u "py" başlatıcısı ile tespit ediyoruz.
function PythonVar { try { $v = & py -3 --version 2>&1; return ($LASTEXITCODE -eq 0 -and "$v" -match "Python 3") } catch { return $false } }

Write-Host "==> PowerShell betik izni ayarlanıyor (npx için gerekli)..."
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

Write-Host "==> Python kontrol ediliyor (yoksa kurulacak)..."
if (-not (PythonVar)) { winget install Python.Python.3.12 @wg; Yenile }
Write-Host "==> Node.js kontrol ediliyor (yoksa kurulacak)..."
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { winget install OpenJS.NodeJS.LTS @wg; Yenile }

Write-Host "==> 1/5 FFmpeg kuruluyor...";   winget install Gyan.FFmpeg @wg
Write-Host "==> 2/5 yt-dlp kuruluyor (YouTube için Deno ile birlikte)..."
winget install yt-dlp.yt-dlp @wg
winget install DenoLand.Deno @wg
Yenile
Write-Host "==> 3/5 OpenAI Whisper kuruluyor (birkaç dakika sürebilir)..."; py -3 -m pip install -U openai-whisper
Write-Host "==> 4/5 HyperFrames skill'i ekleniyor..."; npx.cmd -y skills add heygen-com/hyperframes -g -y
Write-Host "==> 5/5 GSAP skill'leri ekleniyor...";   npx.cmd -y skills add greensock/gsap-skills -g -y

Write-Host "==> Testler çalıştırılıyor..."
$T = Join-Path $env:TEMP "video-test.wav"
ffmpeg -hide_banner -loglevel error -y -f lavfi -i "sine=frequency=440:duration=2" $T; if ($?) { "FFmpeg: OK (test sesi üretildi)" }
yt-dlp --simulate --quiet "https://www.youtube.com/watch?v=jNQXAC9IVRw"; if ($?) { "yt-dlp: OK" }
py -3 -c "import whisper; print('Whisper: OK, modeller:', whisper.available_models()[:3])"
npx.cmd -y skills list -g | Select-String -Pattern "hyperframes|gsap"

Write-Host "`n===== SÜRÜMLER ====="
"Python : $(py -3 --version)"
"Node   : $(node --version)"
"FFmpeg : $((ffmpeg -version)[0])"
"yt-dlp : $(yt-dlp --version)"
"Deno   : $((deno --version)[0])"
"Whisper: $(py -3 -m pip show openai-whisper | Select-String Version)"
"Skill  : $((npx.cmd -y skills list -g | Select-String 'gsap|hyperframes').Count) satir bulundu"
