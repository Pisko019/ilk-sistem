# Whisper ve skill kurulumunu tamamlar (Windows)
$ErrorActionPreference = "Continue"
function Yenile { $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User") }
$wg = "--accept-source-agreements","--accept-package-agreements","-e"
$log = Join-Path $env:TEMP "whisper-kurulum.log"

$bos = [math]::Round((Get-PSDrive C).Free / 1GB, 1)
Write-Host "==> C: diskinde bos yer: $bos GB"
if ($bos -lt 4) { Write-Host "UYARI: Whisper icin en az 4 GB bos yer gerekir. Yer acmaniz gerekebilir." -ForegroundColor Yellow }

Write-Host "==> Git kontrol ediliyor (skill'ler icin gerekli)..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { winget install Git.Git @wg; Yenile }

Write-Host "==> pip guncelleniyor..."
py -3 -m pip install -U pip *> $null

Write-Host "==> Whisper kuruluyor (10-20 dakika surebilir, ekran donmus gibi gorunebilir)..."
py -3 -m pip install -U openai-whisper *> $log

Write-Host "==> HyperFrames skill'i ekleniyor..."
npx.cmd -y skills add heygen-com/hyperframes -g -y
Write-Host "==> GSAP skill'leri ekleniyor..."
npx.cmd -y skills add greensock/gsap-skills -g -y

Write-Host "`n================ SONUC ================"
py -3 -c "import whisper" 2>$null
if ($LASTEXITCODE -eq 0) {
  Write-Host "Whisper : TAMAM ($(py -3 -m pip show openai-whisper | Select-String Version))" -ForegroundColor Green
} else {
  Write-Host "Whisper : KURULAMADI. Hatanin son satirlari:" -ForegroundColor Red
  Get-Content $log -Tail 12
}
$sk = npx.cmd -y skills list -g 2>$null
$g = ($sk | Select-String "greensock/gsap-skills").Count
$h = ($sk | Select-String "heygen-com/hyperframes").Count
if ($g -gt 0) { Write-Host "GSAP    : TAMAM ($g skill)" -ForegroundColor Green } else { Write-Host "GSAP    : KURULAMADI" -ForegroundColor Red }
if ($h -gt 0) { Write-Host "HyperFrames: TAMAM ($h skill)" -ForegroundColor Green } else { Write-Host "HyperFrames: KURULAMADI" -ForegroundColor Red }
Write-Host "Disk    : $([math]::Round((Get-PSDrive C).Free / 1GB, 1)) GB bos kaldi"
Write-Host "======================================="
