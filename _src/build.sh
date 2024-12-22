#!/bin/bash
set -ex

REPO_DIR=$(dirname "$(dirname "$(realpath "$0")")")
[[ ! -d $REPO_DIR/.git ]] && echo "REPO_DIR=$REPO_DIR seems invalid." && exit 1

SRC_DIR=${REPO_DIR}/_src
PAGES_DIR=${SRC_DIR}/content
FILTERS_DIR=${SRC_DIR}/filters
PAGE_LIST_FILE=$(mktemp)
MENU_FILE=$(mktemp)
PAGE_METADATA_FILE=$(mktemp)
BUILD_SCRIPT_PAGE="${PAGES_DIR}/build.sh.md"

# Clean temp files
function cleanup {
	[[ -f ${MENU_FILE} ]] && rm -f "${MENU_FILE}"
	[[ -f ${PAGE_LIST_FILE} ]] && rm -f "${PAGE_LIST_FILE}"
	[[ -f ${PAGE_METADATA_FILE} ]] && rm -f "${PAGE_METADATA_FILE}"
	[[ -f ${BUILD_SCRIPT_PAGE} ]] && rm -f "${BUILD_SCRIPT_PAGE}"
}
trap cleanup EXIT

# Build Script page
{
	echo '# Bulid Script'
	echo '```bash'
	cat "$0"
	echo '```'
} > "${BUILD_SCRIPT_PAGE}"

# All pages (without PAGES_DIR prefix)
find "${PAGES_DIR}" -type f -name '*.md' -printf '%P\n' > "${PAGE_LIST_FILE}"

# Load all pages into `MAPFILE`
readarray -t < "${PAGE_LIST_FILE}"

# Generate menu
{
	echo '---'
	echo 'menu: |'
	# Pandoc parses string literals in metadata files as markdown.
	# The following will notate HTML as raw text in a markdown code block.
	echo '  ```{=html}'
	echo -n '  '
	python "${SRC_DIR}/scripts/generate_menu.py" "${PAGE_LIST_FILE}"
	echo '  ```'
	echo '---'
} > "${MENU_FILE}"

cat "${MENU_FILE}"

shopt -s extglob
# Generate all pages
for page in "${MAPFILE[@]}"; do
	# Generate page metadata
	{
		read -a count <<< "$(wc "${PAGES_DIR}/${page}")"
		echo '---'
		echo "pagelines: '${count[0]}'"
		echo "pagewords: '${count[1]}'"
		echo "pagechars: '${count[2]}'"
		echo "pagepath: '${page}'"
		echo "pagetitle: '${page/@(index.md|.md)/}'"
		[[ ${page##*/} =~ ^\. ]] && echo "pagedraft: '1'"
		[[ ${page##*/} =~ ^_ ]] && echo "pagehidden: '1'"
		echo "pagereadtime: '<$((count[1] / 238 + 1))min'" # Avg: 238 WPM
		echo '---'
	} > "${PAGE_METADATA_FILE}"
	# gfm -> Github-Flavored Markdown
	pandoc \
		-f gfm -t html \
		--standalone \
		--lua-filter "${FILTERS_DIR}/title.lua" \
		--lua-filter "${FILTERS_DIR}/link_html.lua" \
		--lua-filter "${FILTERS_DIR}/link_anchor.lua" \
		--highlight-style=breezedark \
		--metadata-file "${MENU_FILE}" \
		--metadata-file "${PAGE_METADATA_FILE}" \
		--template "${SRC_DIR}/templates/page.html" \
		--css "_src/css/layout.css" \
		-V defaultauthor:moyiz \
		-V "description-meta:Testing description" \
		"${PAGES_DIR}/${page}" \
		-o "${REPO_DIR}/${page/%md/html}"
done
shopt -u extglob

# Generate favicon
magick "${SRC_DIR}/favicon.bmp" "${REPO_DIR}/favicon.ico"
magick "${SRC_DIR}/favicon.bmp" -scale 128x128 -monochrome "${REPO_DIR}/preview.png"

