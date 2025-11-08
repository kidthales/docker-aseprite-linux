#!/bin/bash

set -o errexit
set -o pipefail
set -o noclobber
set -o nounset
#set -o xtrace

readonly DALC_DEFAULT_GIT_REF_ASEPRITE=main
readonly DALC_DEFAULT_BUILD_TYPE=RelWithDebInfo

DALC_GIT_REF_ASEPRITE="${DALC_GIT_REF_ASEPRITE:-${DALC_DEFAULT_GIT_REF_ASEPRITE}}"
DALC_BUILD_TYPE="${DALC_BUILD_TYPE:-${DALC_DEFAULT_BUILD_TYPE}}"

DALC_GIT_URL_ASEPRITE="${DALC_GIT_URL_ASEPRITE:-https://github.com/aseprite/aseprite.git}"

DALC_PATH_OUT="${DALC_PATH_OUT:-/output}"
readonly DALC_PATH_OUT_ASEPRITE="${DALC_PATH_OUT}/aseprite"

declare -A DALC_OPT_HELP=([DESC]='Outputs this help screen.' [LONG]=help [SHORT]=h)
declare -A DALC_OPT_GIT_REF_ASEPRITE=([DESC]="The git-ref to use when cloning ${DALC_GIT_URL_ASEPRITE}. Defaults to ${DALC_DEFAULT_GIT_REF_ASEPRITE}." [LONG]=git-ref-aseprite)
declare -A DALC_OPT_BUILD_TYPE=([DESC]="The value used for -DCMAKE_BUILD_TYPE. Defaults to ${DALC_DEFAULT_BUILD_TYPE}." [LONG]=build-type)

dalc_main() {
	local start end

	start="$(date +%s)"

	dalc_parse_args "$@"

	dalc_build_aseprite \
		"${DALC_PATH_OUT}" \
		"${DALC_PATH_OUT_ASEPRITE}" \
		"${DALC_GIT_URL_ASEPRITE}" \
		"${DALC_GIT_REF_ASEPRITE}" \
		"${DALC_BUILD_TYPE}"

	end="$(date +%s)"

	echo -e "\e[36mRuntime:\e[0m $((end-start))s"
	echo -e "\e[32mCompilation finished\e[0m"
}

dalc_parse_args() {
	local opts="${DALC_OPT_HELP[SHORT]}"
	local longopts="${DALC_OPT_HELP[LONG]},${DALC_OPT_GIT_REF_ASEPRITE[LONG]}:,${DALC_OPT_BUILD_TYPE[LONG]}:"

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
				printf '\nCompile headless Aseprite for Debian\n\n'
				dalc_print_usage
				exit 0
			;;
			"--${DALC_OPT_GIT_REF_ASEPRITE[LONG]}")
				DALC_GIT_REF_ASEPRITE="$2"
				shift 2
			;;
			"--${DALC_OPT_BUILD_TYPE[LONG]}")
				DALC_BUILD_TYPE="$2"
				shift 2
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
  $0 [-${DALC_OPT_HELP[SHORT]}|--${DALC_OPT_HELP[LONG]}] | [--${DALC_OPT_GIT_REF_ASEPRITE[LONG]} <git-ref>] [--${DALC_OPT_BUILD_TYPE[LONG]} <build-type>]

  -${DALC_OPT_HELP[SHORT]}, --${DALC_OPT_HELP[LONG]}
    ${DALC_OPT_HELP[DESC]}

  --${DALC_OPT_GIT_REF_ASEPRITE[LONG]} <git-ref>
    ${DALC_OPT_GIT_REF_ASEPRITE[DESC]}

  --${DALC_OPT_BUILD_TYPE[LONG]} <build-type>
    ${DALC_OPT_BUILD_TYPE[DESC]}
EOF
}

dalc_build_aseprite() {
	echo -e "\e[36mBuilding Aseprite...\e[0m"

	local path_out="$1"
	local path_out_aseprite="$2"
	local git_url_aseprite="$3"
	local git_ref_aseprite="$4"
	local build_type="$5"

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
	echo -e "\e[35m...with clang...\e[0m"

	export CC=clang
	export CXX=clang++

	# shellcheck disable=SC2086
	cmake \
		-DCMAKE_BUILD_TYPE="${build_type}" \
		-DCMAKE_CXX_FLAGS:STRING=-stdlib=libc++ \
		-DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libc++ \
		-DLAF_BACKEND=none \
		-G Ninja \
		..

	echo -e "\e[37mLinking Aseprite...\e[0m"
	ninja aseprite
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	dalc_main "$@"
fi
