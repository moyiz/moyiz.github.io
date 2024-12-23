#!/bin/bash
set -ex

REPO_DIR=$(dirname "$(realpath "$0")")
[[ ! -d $REPO_DIR/.git ]] && echo "REPO_DIR=$REPO_DIR seems invalid." && exit 1

PAGES_DIR=${REPO_DIR}/content
FILTERS_DIR=${REPO_DIR}/filters
DIST_DIR=${REPO_DIR}/docs
PAGE_LIST_FILE=$(mktemp)
MENU_FILE=$(mktemp)
PAGE_METADATA_FILE=$(mktemp)
BUILD_SCRIPT_PAGE="${PAGES_DIR}/build.sh.md"

# Clean temp files on exit
function cleanup {
	[[ -f ${MENU_FILE} ]] && rm -f "${MENU_FILE}"
	[[ -f ${PAGE_LIST_FILE} ]] && rm -f "${PAGE_LIST_FILE}"
	[[ -f ${PAGE_METADATA_FILE} ]] && rm -f "${PAGE_METADATA_FILE}"
	[[ -f ${BUILD_SCRIPT_PAGE} ]] && rm -f "${BUILD_SCRIPT_PAGE}"
}
trap cleanup EXIT

if [[ $1 == "release" ]]; then
	BASE_URL=https://moyiz.github.io
else
	BASE_URL=${DIST_DIR}
fi

# Generate a page for the build script
{
	echo '# Bulid Script'
	echo '```bash'
	cat "$0"
	echo '```'
} > "${BUILD_SCRIPT_PAGE}"

# Create directories
find "${PAGES_DIR}" -mindepth 1 -type d -printf "${DIST_DIR}/%P\n" | xargs --no-run-if-empty mkdir -p

# All pages (without PAGES_DIR prefix)
find "${PAGES_DIR}" -type f -name '*.md' -printf '%P\n' > "${PAGE_LIST_FILE}"
cat "${PAGE_LIST_FILE}"

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
	python "${REPO_DIR}/scripts/generate_menu.py" "${PAGE_LIST_FILE}" "${BASE_URL}"
	echo '  ```'
	echo '---'
} > "${MENU_FILE}"

cat "${MENU_FILE}"

# Publish css
DIST_CSS_DIR="${DIST_DIR}/_css"
[[ -e "${DIST_CSS_DIR}" ]] && rm -rf "${DIST_CSS_DIR}"
cp -rv "${REPO_DIR}/css" "${DIST_CSS_DIR}"

# Publish JS
DIST_JS_DIR="${DIST_DIR}/_js"
[[ -e "${DIST_JS_DIR}" ]] && rm -rf "${DIST_JS_DIR}"
cp -rv "${REPO_DIR}/js" "${DIST_JS_DIR}"

# Publish icons
DIST_ICONS_DIR="${DIST_DIR}/_icons"
[[ -e "${DIST_ICONS_DIR}" ]] && rm -rf "${DIST_ICONS_DIR}"
cp -rv "${REPO_DIR}/icons" "${DIST_ICONS_DIR}"

shopt -s extglob
# Generate all pages
for page in "${MAPFILE[@]}"; do
	# Get the relative path from the current page to the root directory
	reporelpath=$(realpath -m "${REPO_DIR}" --relative-to="$(dirname "${page}")")

	# Generate page metadata
	{
		read -a count <<< "$(wc "${PAGES_DIR}/${page}")"
		echo '---'
		echo "toc: false" # off by default toc generation
		echo "pagelines: '${count[0]}'"
		echo "pagewords: '${count[1]}'"
		echo "pagechars: '${count[2]}'"
		echo "pagepath: '${page}'"
		echo "pagetitle: '${page/@(index.md|.md)/}'"
		[[ ${page##*/} =~ ^\. ]] && echo "pagedraft: '1'"
		[[ ${page##*/} =~ ^_ ]] && echo "pagehidden: '1'"
		echo "pagereadtime: '<$((count[1] / 238 + 1))min'" # Avg: 238 WPM
		echo "baseurl: '${BASE_URL}'"
		echo '---'
	} > "${PAGE_METADATA_FILE}"

	# Generate the page
	# gfm -> Github-Flavored Markdown
	pandoc \
		-f gfm -t html \
		--standalone \
		--lua-filter "${FILTERS_DIR}/title.lua" \
		--lua-filter "${FILTERS_DIR}/link.lua" \
		--highlight-style=breezedark \
		--metadata-file "${MENU_FILE}" \
		--metadata-file "${PAGE_METADATA_FILE}" \
		--template "${REPO_DIR}/templates/page.html" \
		--toc \
		-V defaultauthor:moyiz \
		-V "description-meta:Now is better than never. Although never is often better than *right* now." \
		"${PAGES_DIR}/${page}" \
		-o "${DIST_DIR}/${page/%md/html}"
done
shopt -u extglob

# Generate favicon
magick "${REPO_DIR}/favicon.bmp" "${DIST_DIR}/favicon.ico"

# Generate OpenGraph image
magick "${REPO_DIR}/favicon.bmp" -scale 175x175 -monochrome -background black \
	-gravity center -extent 400x200 "${DIST_DIR}/_preview.png"
