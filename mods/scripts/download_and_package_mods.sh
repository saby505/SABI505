#!/usr/bin/env bash
set -euo pipefail

# تأكد تثبيت الأدوات المطلوبة: pkg install curl zip -y
OUTDIR="$(pwd)/mods_job"
DL_DIR="$OUTDIR/downloads"
mkdir -p "$DL_DIR"

urls=(
"https://www.mediafire.com/file/np0zcfj7dvrkap1/Ford_taurus_23.zip/file"
"https://www.dropbox.com/scl/fi/u7zlzj773b70l4v425nfg/ENF_Accord13.zip?rlkey=30c2c5eajirh8l35bhzovc47c&st=riw0ujpb&dl=1"
"https://modsfire.com/qbBmkhoDrJ1rWGf"
"https://www.dropbox.com/scl/fi/yltl4w6qkgnlknivp44h5/lands-g.zip?rlkey=xazj3d801m0xusbhfq49vtl0l&st=c361w4np&dl=1"
"https://www.dropbox.com/scl/fi/xxmctr3yvl8qmfy055oyz/Hyundai_Accent_Solaris_16-17.zip?rlkey=5xa153krnmtnzqfqc53ftr867&dl=1"
"https://www.dropbox.com/scl/fi/dm0pgeh3ontm2ucyyx8ln/Hyundai-Elantra-2025-2024.zip?rlkey=a69l08vhv617201728xwdvj1b&st=ijys3vkt&dl=1"
"https://www.dropbox.com/scl/fi/amzeivxf14arb74ooxs2d/Elantra_20151.zip?rlkey=3b3afa59z6bnkptoauo3xf44y&st=myjlsf0b&dl=1"
"https://www.dropbox.com/scl/fi/s6vcp3rzqleromx128mb8/Accord2023.zip?rlkey=6tvtp7j5kti3mky99iewhzgds&dl=1"
"https://www.dropbox.com/scl/fi/7o93o4wbngii2onkitxba/RB3_2024_KHwylD.zip?rlkey=li0avd9fl38ktz57fleg1t0ia&st=gkngtf0u&dl=1"
)

cd "$DL_DIR"
i=1
for url in "${urls[@]}"; do
  raw="$(basename "${url%%\?*}")"
  fname="$raw"
  if [[ -z "$fname" || "$fname" == "file" ]]; then
    fname="download_$i.zip"
  fi
  echo "[$i/${#urls[@]}] Downloading: $url -> $fname"
  # try download; continue on failure
  if ! curl -L -o "$fname" "$url"; then
    echo "Warning: curl failed for $url — please open the link in your browser and download it manually into $DL_DIR"
  fi
  ((i++))
done

cd "$OUTDIR"
zipname="combined_downloads_$(date +%Y%m%d%H%M%S).zip"

if command -v zip >/dev/null 2>&1; then
  zip -r -q "$zipname" downloads
  echo "Created archive: $OUTDIR/$zipname"
else
  echo "zip not found. Install it with: pkg install zip -y"
  echo "Downloaded files are in: $DL_DIR"
  exit 0
fi

# Upload to transfer.sh (اختياري). إذا لم ترد الرفع احذف السطرين التاليين.
if command -v curl >/dev/null 2>&1; then
  echo "Uploading to transfer.sh..."
  upload_url=$(curl --upload-file "$zipname" "https://transfer.sh/$(basename "$zipname")")
  echo "Upload complete:"
  echo "$upload_url"
fi

echo "All done. Downloads (as-is) are in: $DL_DIR"
