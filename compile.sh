#!/bin/bash

set -o errexit
set -o pipefail
set -o noclobber
set -o nounset
#set -o xtrace

readonly DALC_DEFAULT_GIT_REF_SKIA=aseprite-m124
readonly DALC_DEFAULT_GIT_REF_ASEPRITE=main
readonly DALC_DEFAULT_BUILD_TYPE=RelWithDebInfo
readonly DALC_DEFAULT_ENABLE_UI=ON
readonly DALC_DEFAULT_COMPILER_CHAIN=clang

DALC_GIT_REF_SKIA="${DALC_GIT_REF_SKIA:-${DALC_DEFAULT_GIT_REF_SKIA}}"
DALC_GIT_REF_ASEPRITE="${DALC_GIT_REF_ASEPRITE:-${DALC_DEFAULT_GIT_REF_ASEPRITE}}"
DALC_BUILD_TYPE="${DALC_BUILD_TYPE:-${DALC_DEFAULT_BUILD_TYPE}}"
DALC_ENABLE_UI="${DALC_ENABLE_UI:-${DALC_DEFAULT_ENABLE_UI}}"
DALC_COMPILER_CHAIN="${DALC_COMPILER_CHAIN:-${DALC_DEFAULT_COMPILER_CHAIN}}"

DALC_GIT_URL_DEPOT_TOOLS="${DALC_GIT_URL_DEPOT_TOOLS:-https://chromium.googlesource.com/chromium/tools/depot_tools.git}"
DALC_GIT_URL_SKIA="${DALC_GIT_URL_SKIA:-https://github.com/aseprite/skia.git}"
DALC_GIT_URL_ASEPRITE="${DALC_GIT_URL_ASEPRITE:-https://github.com/aseprite/aseprite.git}"

DALC_PATH_DEPS="${DALC_PATH_DEPS:-/dependencies}"
readonly DALC_PATH_DEPS_DEPOT_TOOLS="${DALC_PATH_DEPS}/depot_tools"
readonly DALC_PATH_DEPS_SKIA="${DALC_PATH_DEPS}/skia"

DALC_PATH_OUT="${DALC_PATH_OUT:-/output}"
readonly DALC_PATH_OUT_ASEPRITE="${DALC_PATH_OUT}/aseprite"

declare -A DALC_OPT_HELP=([DESC]='Outputs this help screen.' [LONG]=help [SHORT]=h)
declare -A DALC_OPT_GIT_REF_SKIA=([DESC]="The git-ref to use when cloning ${DALC_GIT_URL_SKIA}. Defaults to ${DALC_DEFAULT_GIT_REF_SKIA}." [LONG]=git-ref-skia)
declare -A DALC_OPT_GIT_REF_ASEPRITE=([DESC]="The git-ref to use when cloning ${DALC_GIT_URL_ASEPRITE}. Defaults to ${DALC_DEFAULT_GIT_REF_ASEPRITE}." [LONG]=git-ref-aseprite)
declare -A DALC_OPT_BUILD_TYPE=([DESC]="The value used for -DCMAKE_BUILD_TYPE. Defaults to ${DALC_DEFAULT_BUILD_TYPE}." [LONG]=build-type)
declare -A DALC_OPT_HEADLESS=([DESC]="Sets value used for -DENABLE_UI to OFF. Default is ${DALC_DEFAULT_ENABLE_UI}." [LONG]=headless)
declare -A DALC_OPT_WITH_GPP=([DESC]="Use the g++ compiler toolchain. Default is ${DALC_DEFAULT_COMPILER_CHAIN}." [LONG]=with-g++)

dalc_main() {
	local start end

	start="$(date +%s)"

	dalc_parse_args "$@"

	dalc_build_deps \
		"${DALC_PATH_DEPS}" \
		"${DALC_PATH_DEPS_DEPOT_TOOLS}" \
		"${DALC_GIT_URL_DEPOT_TOOLS}" \
		"${DALC_PATH_DEPS_SKIA}" \
		"${DALC_GIT_URL_SKIA}" \
		"${DALC_GIT_REF_SKIA}" \
		"${DALC_COMPILER_CHAIN}"

	dalc_build_aseprite \
		"${DALC_PATH_OUT}" \
		"${DALC_PATH_OUT_ASEPRITE}" \
		"${DALC_GIT_URL_ASEPRITE}" \
		"${DALC_GIT_REF_ASEPRITE}" \
		"${DALC_BUILD_TYPE}" \
		"${DALC_ENABLE_UI}" \
		"${DALC_PATH_DEPS_SKIA}" \
		"${DALC_COMPILER_CHAIN}"

	end="$(date +%s)"

	echo -e "\e[36mRuntime:\e[0m $((end-start))s"
	echo -e "\e[32mCompilation finished\e[0m"
}

dalc_parse_args() {
	local opts="${DALC_OPT_HELP[SHORT]}"
	local longopts="${DALC_OPT_HELP[LONG]},${DALC_OPT_GIT_REF_SKIA[LONG]}:,${DALC_OPT_GIT_REF_ASEPRITE[LONG]}:,${DALC_OPT_BUILD_TYPE[LONG]}:,${DALC_OPT_HEADLESS[LONG]},${DALC_OPT_WITH_GPP[LONG]}"

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
			"--${DALC_OPT_WITH_GPP[LONG]}")
				DALC_COMPILER_CHAIN=g++
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
  $0 [-${DALC_OPT_HELP[SHORT]}|--${DALC_OPT_HELP[LONG]}] | [--${DALC_OPT_GIT_REF_SKIA[LONG]} <git-ref>] [--${DALC_OPT_GIT_REF_ASEPRITE[LONG]} <git-ref>] [--${DALC_OPT_BUILD_TYPE[LONG]} <build-type>] [--${DALC_OPT_HEADLESS[LONG]}] [--${DALC_OPT_WITH_GPP[LONG]}]

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

  --${DALC_OPT_WITH_GPP[LONG]}
    ${DALC_OPT_WITH_GPP[DESC]}
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

	local compiler_chain="$7"

	mkdir -p "${path_deps}"
	cd "${path_deps}"

	if [ ! -d "${path_deps_depot_tools}" ]; then
		git clone "${git_url_depot_tools}"
	fi

	if [ -d "${path_deps_skia}" ]; then
		local tag_candidate branch_candidate short_candidate

		cd "${path_deps_skia}"

		tag_candidate="$(git describe --tags --exact-match 2> /dev/null || echo '')"
		branch_candidate="$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"
		short_candidate="$(git rev-parse --short HEAD)"

		if [ "${tag_candidate}" != "${git_ref_skia}" ] && [ "${branch_candidate}" != "${git_ref_skia}" ] && [ "${short_candidate}" != "${git_ref_skia}" ]; then
			echo -e "\e[37mCleaning skia dependencies...\e[0m"
			cd "${path_deps}"
			rm -rf "${path_deps_skia}"
		fi
	fi

	if [ ! -d "${path_deps_skia}" ]; then
		git clone -b "${git_ref_skia}" "${git_url_skia}"
	fi

	export PATH="${path_deps_depot_tools}:${PATH}"

	# Fix for error:
	# python3_bin_reldir.txt not found. need to initialize depot_tools by
	# running gclient, update_depot_tools or ensure_bootstrap.
	cd "${path_deps_depot_tools}"
	./update_depot_tools

	cd "${path_deps_skia}"

	echo -e "\e[37mSyncing skia dependencies...\e[0m"
	python3 tools/git-sync-deps

	echo -e "\e[37mCompiling skia...\e[0m"

	if [ "${compiler_chain}" = g++ ]; then
		echo -e "\e[35m...with g++...\e[0m"
		gn gen out/Release-x64 --args="is_debug=false is_official_build=true skia_use_system_expat=false skia_use_system_icu=false skia_use_system_libjpeg_turbo=false skia_use_system_libpng=false skia_use_system_libwebp=false skia_use_system_zlib=false skia_use_sfntly=false skia_use_freetype=true skia_use_harfbuzz=true skia_pdf_subset_harfbuzz=true skia_use_system_freetype2=false skia_use_system_harfbuzz=false"
	else
		echo -e "\e[35m...with clang...\e[0m"
		gn gen out/Release-x64 --args='is_debug=false is_official_build=true skia_use_system_expat=false skia_use_system_icu=false skia_use_system_libjpeg_turbo=false skia_use_system_libpng=false skia_use_system_libwebp=false skia_use_system_zlib=false skia_use_sfntly=false skia_use_freetype=true skia_use_harfbuzz=true skia_pdf_subset_harfbuzz=true skia_use_system_freetype2=false skia_use_system_harfbuzz=false cc="clang" cxx="clang++" extra_cflags_cc=["-stdlib=libc++"] extra_ldflags=["-stdlib=libc++"]'
	fi

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

	local compiler_chain="$8"

	mkdir -p "${path_out}"
	cd "${path_out}"

	if [ -d "${path_out_aseprite}" ]; then
		local tag_candidate branch_candidate short_candidate

		cd "${path_out_aseprite}"

		tag_candidate="$(git describe --tags --exact-match 2> /dev/null || echo '')"
		branch_candidate="$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"
		short_candidate="$(git rev-parse --short HEAD)"

		if [ "${tag_candidate}" != "${git_ref_aseprite}" ] && [ "${branch_candidate}" != "${git_ref_aseprite}" ] && [ "${short_candidate}" != "${git_ref_aseprite}" ]; then
			echo -e "\e[37mCleaning Aseprite dependencies...\e[0m"
			cd "${path_out}"
			rm -rf "${path_out_aseprite}"
		fi
	fi

	if [ ! -d "${path_out_aseprite}" ]; then
		git clone -b "${git_ref_aseprite}" --recursive "${git_url_aseprite}"
	fi

	cd "${path_out_aseprite}"

	mkdir -p build
	cd build

	echo -e "\e[37mCompiling Aseprite...\e[0m"

	local stdlib_flags=''

	if [ "${compiler_chain}" = g++ ]; then
		echo -e "\e[35m...with g++...\e[0m"
	else
		echo -e "\e[35m...with clang...\e[0m"

		export CC=clang
		export CXX=clang++

		stdlib_flags='-DCMAKE_CXX_FLAGS:STRING=-stdlib=libc++ -DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libc++'
	fi

	# shellcheck disable=SC2086
	cmake \
		-DCMAKE_BUILD_TYPE="${build_type}" \
		-DENABLE_UI="${enable_ui}" \
		${stdlib_flags} \
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
