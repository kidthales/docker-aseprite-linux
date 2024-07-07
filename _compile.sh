#!/bin/bash

set -o errexit
set -o pipefail
set -o noclobber
set -o nounset
#set -o xtrace

readonly DALC_DEFAULT_GIT_REF_SKIA=aseprite-m102
readonly DALC_DEFAULT_GIT_REF_ASEPRITE=main
readonly DALC_DEFAULT_BUILD_TYPE=RelWithDebInfo
readonly DALC_DEFAULT_ENABLE_UI=ON

readonly DALC_GIT_URL_DEPOT_TOOLS=https://chromium.googlesource.com/chromium/tools/depot_tools.git
readonly DALC_GIT_URL_SKIA=https://github.com/aseprite/skia.git
readonly DALC_GIT_URL_ASEPRITE=https://github.com/aseprite/aseprite.git

declare -A DALC_OPT_HELP=([DESC]='Outputs this help screen.' [LONG]=help [SHORT]=h)
declare -A DALC_OPT_GIT_REF_SKIA=([DESC]="The git-ref to use when cloning ${DALC_GIT_URL_SKIA}. Defaults to ${DALC_DEFAULT_GIT_REF_SKIA}." [LONG]=git-ref-skia)
declare -A DALC_OPT_GIT_REF_ASEPRITE=([DESC]="The git-ref to use when cloning ${DALC_GIT_URL_ASEPRITE}. Defaults to ${DALC_DEFAULT_GIT_REF_ASEPRITE}." [LONG]=git-ref-aseprite)
declare -A DALC_OPT_BUILD_TYPE=([DESC]="The value used for -DCMAKE_BUILD_TYPE. Defaults to ${DALC_DEFAULT_BUILD_TYPE}." [LONG]=build-type)
declare -A DALC_OPT_HEADLESS=([DESC]="Sets value used for -DENABLE_UI to OFF. Defaults to ${DALC_DEFAULT_ENABLE_UI}." [LONG]=headless)

DALC_GIT_REF_SKIA="${DALC_DEFAULT_GIT_REF_SKIA}"
DALC_GIT_REF_ASEPRITE="${DALC_DEFAULT_GIT_REF_ASEPRITE}"
DALC_BUILD_TYPE="${DALC_DEFAULT_BUILD_TYPE}"
DALC_ENABLE_UI="${DALC_DEFAULT_ENABLE_UI}"

dalc_main() {
	local start end

	start="$(date +%s)"

	dalc_parse_args "$@"

	dalc_build_deps \
		/dependencies \
		/dependencies/depot_tools \
		"${DALC_GIT_URL_DEPOT_TOOLS}" \
		/dependencies/skia \
		"${DALC_GIT_URL_SKIA}" \
		"${DALC_GIT_REF_SKIA}"

	dalc_build_aseprite \
		/output \
		/output/aseprite \
		"${DALC_GIT_URL_ASEPRITE}" \
		"${DALC_GIT_REF_ASEPRITE}" \
		"${DALC_BUILD_TYPE}" \
		"${DALC_ENABLE_UI}" \
		/dependencies/skia

	end="$(date +%s)"

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
  $0 [-${DALC_OPT_HELP[SHORT]}|--${DALC_OPT_HELP[LONG]}] | [--${DALC_OPT_GIT_REF_SKIA[LONG]} <git-ref>] [--${DALC_OPT_GIT_REF_ASEPRITE[LONG]} <git-ref>] [--${DALC_OPT_BUILD_TYPE[LONG]} <build-type>] [--${DALC_OPT_HEADLESS[LONG]}]

  -${DALC_OPT_HELP[SHORT]}, --${DALC_OPT_HELP[LONG]}
    ${DALC_OPT_HELP[DESC]}

  --${DALC_OPT_GIT_REF_SKIA[LONG]} <git-ref>
    ${DALC_OPT_GIT_REF_SKIA[DESC]}

  --${DALC_OPT_GIT_REF_ASEPRITE[LONG]} <git-ref>
    ${DALC_OPT_GIT_REF_ASEPRITE[DESC]}

  --${DALC_OPT_BUILD_TYPE[LONG]} <build-type>
    ${DALC_OPT_BUILD_TYPE[DESC]}

  --${DALC_OPT_HEADLESS[LONG]}
    ${DALC_OPT_HEADLESS[DESC]}
EOF
}

dalc_build_deps() {
	echo -e "\e[36mBuilding dependencies...\e[0m"

	local path_deps="$1"

	local path_deps_depot_tools="$2"
	local git_url_depot_tools="$3"

	local path_deps_skia="$4"
	local git_url_skia="$5"
	local git_ref_skia="$6"

	mkdir -p "${path_deps}"
	cd "${path_deps}"

	if [ ! -d "${path_deps_depot_tools}" ]; then
		git clone "${git_url_depot_tools}"
	fi

	if [ ! -d "${path_deps_skia}" ]; then
		git clone -b "${git_ref_skia}" "${git_url_skia}"
	fi

	export PATH="${path_deps_depot_tools}:${PATH}"

	cd "${path_deps_skia}"

	echo -e "\e[37mSyncing skia dependencies...\e[0m"
	python3 tools/git-sync-deps

	echo -e "\e[37mCompiling skia...\e[0m"
	gn gen out/Release-x64 --args=" \
		is_debug=false \
		is_official_build=true \
		skia_use_system_expat=false \
		skia_use_system_icu=false \
		skia_use_system_libjpeg_turbo=false \
		skia_use_system_libpng=false \
		skia_use_system_libwebp=false \
		skia_use_system_zlib=false \
		skia_use_sfntly=false \
		skia_use_freetype=true \
		skia_use_harfbuzz=true \
		skia_pdf_subset_harfbuzz=true \
		skia_use_system_freetype2=false \
		skia_use_system_harfbuzz=false \
	"
	ninja -C out/Release-x64 skia modules
}

dalc_build_aseprite() {
	echo -e "\e[36mBuilding Aseprite...\e[0m"

	local path_out="$1"

	local path_out_aseprite="$2"
	local git_url_aseprite="$3"
	local git_ref_aseprite="$4"

	local build_type="$5"
	local enable_ui="$6"
	local path_deps_skia="$7"

	mkdir -p "${path_out}"
	cd "${path_out}"

	if [ ! -d "${path_out_aseprite}" ]; then
		git clone -b "${git_ref_aseprite}" --recursive "${git_url_aseprite}"
	fi

	cd "${path_out_aseprite}"

	mkdir -p build
	cd build

	echo -e "\e[37mCompiling Aseprite...\e[0m"
	cmake \
		-DCMAKE_BUILD_TYPE="${build_type}" \
		-DENABLE_UI="${enable_ui}" \
		-DLAF_BACKEND=skia \
		-DSKIA_DIR="${path_deps_skia}" \
		-DSKIA_LIBRARY_DIR="${path_deps_skia}/out/Release-x64" \
		-DSKIA_LIBRARY="${path_deps_skia}/out/Release-x64/libskia.a" \
		-G Ninja \
		..

	echo -e "\e[37mLinking Aseprite...\e[0m"
	ninja aseprite
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	dalc_main "$@"
fi
