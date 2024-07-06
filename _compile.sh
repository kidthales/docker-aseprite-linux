#!/bin/bash

set -o errexit
set -o pipefail
set -o noclobber
set -o nounset
#set -o xtrace

declare -A DALC_OPT_HELP=([NAME]=help [LONG]=help [SHORT]=h)
declare -A DALC_OPT_GIT_REF_SKIA=([NAME]=git-ref-skia [LONG]=git-ref-skia)
declare -A DALC_OPT_GIT_REF_ASEPRITE=([NAME]=git-ref-aseprite [LONG]=git-ref-aseprite)
declare -A DALC_OPT_BUILD_TYPE=([NAME]=build-type [LONG]=build-type)
declare -A DALC_OPT_HEADLESS=([NAME]=headless [LONG]=headless)

readonly DALC_DEFAULT_GIT_REF_SKIA=aseprite-m102
readonly DALC_DEFAULT_GIT_REF_ASEPRITE=main
readonly DALC_DEFAULT_BUILD_TYPE=RelWithDebInfo
readonly DALC_DEFAULT_ENABLE_UI=ON

DALC_GIT_REF_SKIA="${DALC_DEFAULT_GIT_REF_SKIA}"
DALC_GIT_REF_ASEPRITE="${DALC_DEFAULT_GIT_REF_ASEPRITE}"
DALC_BUILD_TYPE="${DALC_DEFAULT_BUILD_TYPE}"
DALC_ENABLE_UI="${DALC_DEFAULT_ENABLE_UI}"

dalc_main() {
	local start=$(date +%s)

	dalc_parse_args "$@"
	#dalc_build_deps "${DALC_GIT_REF_SKIA}"
	#dalc_build_aseprite "${DALC_GIT_REF_ASEPRITE}" "${DALC_BUILD_TYPE}" "${DALC_ENABLE_UI}"

	local end=$(date +%s)

	echo -e "\e[36mRuntime:\e[0m $((end-start))s"
	echo -e "\e[32mCompilation finished\e[0m"
}

dalc_parse_args() {
	local opts="${DALC_OPT_HELP[SHORT]}"
	local longopts="${DALC_OPT_HELP[LONG]},${DALC_OPT_GIT_REF_SKIA[LONG]}:,${DALC_OPT_GIT_REF_ASEPRITE[LONG]}:,${DALC_OPT_BUILD_TYPE[LONG]}:,${DALC_OPT_HEADLESS[LONG]}"

	! PARSED=$(getopt --options="$opts" --longoptions="$longopts" --name "$0" -- "$@")

	if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
		# getopt has complained about wrong arguments to stdout.
		dalc_print_usage
		exit 1
	fi

	# Handle quoting in getopt output.
	eval set -- "$PARSED"

	while true; do
		case "$1" in
			"-${DALC_OPT_HELP[SHORT]}"|"--${DALC_OPT_HELP[LONG]}")
				printf '\nCompile Aseprite for Linux\n\n'
				dalc_print_usage
				exit 0
			;;
			"--${DALC_OPT_GIT_REF_SKIA[LONG]}")
				DALC_GIT_REF_SKIA="$2"
				shift 2
			;;
			"--${DALC_OPT_GIT_REF_ASEPRITE[LONG]}")
				DALC_GIT_REF_ASEPRITE="$2"
				shift 2
			;;
			"--${DALC_OPT_BUILD_TYPE[LONG]}")
				DALC_BUILD_TYPE="$2"
				shift 2
			;;
			"--${DALC_OPT_HEADLESS[LONG]}")
				DALC_ENABLE_UI=OFF
				shift 1
			;;
			--)
				shift
				break
			;;
		esac
	done

	if [ "$#" -gt 0 ]; then
		echo -e "\e[33mWarning: unknown args detected:\e[0m $*"
	fi
}

dalc_print_usage() {
	cat <<EOF
Usage:
  $0 [<todo>]...

  TODO
EOF
}

dalc_build_deps() {
	echo -e "\e[36mBuilding dependencies...\e[0m"

	mkdir -p /dependencies
	cd /dependencies

	if [ ! -d "/dependencies/depot_tools" ]; then
		git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
	fi

	if [ ! -d "/dependencies/skia" ]; then
		git clone -b aseprite-m102 https://github.com/aseprite/skia.git
	fi

	export PATH="/dependencies/depot_tools:${PATH}"

	cd /dependencies/skia

	echo -e "\e[37mSyncing skia dependencies...\e[0m"
	python3 tools/git-sync-deps

	echo -e "\e[37mCompiling skia...\e[0m"
	gn gen out/Release-x64 --args="is_debug=false is_official_build=true skia_use_system_expat=false skia_use_system_icu=false skia_use_system_libjpeg_turbo=false skia_use_system_libpng=false skia_use_system_libwebp=false skia_use_system_zlib=false skia_use_sfntly=false skia_use_freetype=true skia_use_harfbuzz=true skia_pdf_subset_harfbuzz=true skia_use_system_freetype2=false skia_use_system_harfbuzz=false"
	ninja -C out/Release-x64 skia modules
}

dalc_build_aseprite() {
	echo -e "\e[36mBuilding Aseprite...\e[0m"

	mkdir -p /output
	cd /output

	if [ ! -d "/output/aseprite" ]; then
		git clone -b v1.3.7 --recursive https://github.com/aseprite/aseprite.git
	fi

	cd /output/aseprite

	mkdir -p build

	cd build

	echo -e "\e[37mCompiling Aseprite...\e[0m"
	cmake \
		-DCMAKE_BUILD_TYPE=RelWithDebInfo \
		-DENABLE_UI=OFF \
		-DLAF_BACKEND=skia \
		-DSKIA_DIR=/dependencies/skia \
		-DSKIA_LIBRARY_DIR=/dependencies/skia/out/Release-x64 \
		-DSKIA_LIBRARY=/dependencies/skia/out/Release-x64/libskia.a \
		-G Ninja \
		..

	echo -e "\e[37mLinking Aseprite...\e[0m"
	ninja aseprite
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	dalc_main "$@"
fi
