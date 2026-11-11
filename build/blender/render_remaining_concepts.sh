#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
DIR="${SCRIPT_DIR}"
DOCS_VIDEOS="${REPO_ROOT}/docs/assets/videos"
cd "$DIR"

echo "Waiting for Concept 2 background render to complete..."
while pgrep -f "palexus_concept2_cipher.blend" >/dev/null; do
    sleep 3
done

echo "Concept 2 complete! Converting / ensuring MP4..."
if [[ -d "$DIR/renders/concept2" ]] && [[ ! -f "$DIR/palexus_boot_concept2.mp4" ]]; then
    ffmpeg -y -framerate 30 -i "$DIR/renders/concept2/frame_%04d.png" -c:v libx264 -pix_fmt yuv420p "$DIR/palexus_boot_concept2.mp4"
fi

echo "======================================================="
echo " Starting Render: Concept 3 (Cortical Convolutions)..."
echo "======================================================="
mkdir -p "$DIR/renders/concept3"
blender -b "$DIR/palexus_concept3_cortical.blend" -o "$DIR/renders/concept3/frame_####" -F PNG -a
ffmpeg -y -framerate 30 -i "$DIR/renders/concept3/frame_%04d.png" -c:v libx264 -pix_fmt yuv420p "$DIR/palexus_boot_concept3.mp4"

echo "======================================================="
echo " Starting Render: Concept 4 (The Monolithic Prism)..."
echo "======================================================="
mkdir -p "$DIR/renders/concept4"
blender -b "$DIR/palexus_concept4_prism.blend" -o "$DIR/renders/concept4/frame_####" -F PNG -a
ffmpeg -y -framerate 30 -i "$DIR/renders/concept4/frame_%04d.png" -c:v libx264 -pix_fmt yuv420p "$DIR/palexus_boot_concept4.mp4"

echo "Copying MP4 and WebM assets to docs/assets/videos/..."
mkdir -p "${DOCS_VIDEOS}"
for c in concept2 concept3 concept4; do
    if [[ -f "$DIR/palexus_boot_${c}.mp4" ]]; then
        cp -af "$DIR/palexus_boot_${c}.mp4" "${DOCS_VIDEOS}/${c}.mp4"
        ffmpeg -y -v error -i "$DIR/palexus_boot_${c}.mp4" -c:v libvpx-vp9 -b:v 0 -crf 30 -an "${DOCS_VIDEOS}/${c}.webm"
    fi
done

echo "All boot video concepts rendered and converted successfully!"
