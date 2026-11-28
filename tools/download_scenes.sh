#!/usr/bin/env bash
# Download heavy scene assets on demand: the RoboCasa model suite or the
# car-scene meshes. Fresh clones only need the half they will actually run.
#
# Usage:
#   ./tools/download_scenes.sh             # interactive menu
#   ./tools/download_scenes.sh robocasa    # RoboCasa source + runtime + assets
#   ./tools/download_scenes.sh car         # car-scene asset pack (manifest + meshes)
#   ./tools/download_scenes.sh all
#
# The RoboCasa branch needs python3 + uv and takes a while (source checkout,
# Python 3.11 venv, robosuite pin, macro setup, HF assets). The car branch is
# a single stdlib-python download of one sha256-pinned zip.
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

# Car-scene asset pack source. Empty = the GitHub release pinned inside
# tools/blendscene_assets.py. To serve the zip from your own mirror, paste
# the download link here (and preferably its sha256), or export the env vars:
#   CAR_SCENE_ASSETS_URL=https://your-mirror/car_scene_assets_v2.zip \
#   CAR_SCENE_ASSETS_SHA256=<sha256> ./tools/download_scenes.sh car
CAR_SCENE_ASSETS_URL="${CAR_SCENE_ASSETS_URL:-}"
CAR_SCENE_ASSETS_SHA256="${CAR_SCENE_ASSETS_SHA256:-}"

download_car() {
  if [[ -n $CAR_SCENE_ASSETS_URL ]]; then
    export CAR_SCENE_ASSETS_URL
    [[ -n $CAR_SCENE_ASSETS_SHA256 ]] && export CAR_SCENE_ASSETS_SHA256
  fi
  python3 "$root/tools/blendscene_assets.py" download
}

download_robocasa() {
  "$root/tools/robocasasetup.sh"
}

choice="${1:-}"
if [[ -z $choice ]]; then
  printf 'Which scene assets should this clone download?\n'
  printf '  1) RoboCasa (source + runtime + kitchen assets)\n'
  printf '  2) Car scene  (0001.blend building meshes, one zip)\n'
  printf '  3) Both\n'
  printf '  0) Nothing\n'
  printf 'Choice [0-3]: '
  read -r reply
  case $reply in
    1) choice=robocasa ;;
    2) choice=car ;;
    3) choice=all ;;
    *) choice=none ;;
  esac
fi

case $choice in
  robocasa) download_robocasa ;;
  car) download_car ;;
  all) download_robocasa && download_car ;;
  none) echo 'No scene assets downloaded.' ;;
  *) echo "Usage: $0 [robocasa|car|all]" >&2; exit 2 ;;
esac
