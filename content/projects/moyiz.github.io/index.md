---
toc: true
---

# moyiz.github.io

> [!NOTE]
> Most of the content on this page is subjected to possible changes. I will try
> to keep it up-to-date with the progression of this site, but dissimilarities
> might occur.

A nano-blog site standing on the shoulders of `pandoc` and Github Pages.

## Features
I will try to keep this list synchronized.
- [X] Content should be written in markdown (preferably Github variant).
- [X] A file-manager-like sidebar to navigate.
- [X] Underscore-prefixed markdown files should be excluded from the sidebar.
- [X] Dot-prefixed markdown files should be excluded from the sidebar and be
      marked as "draft".
- [X] Simple, trivial and predictable - black background` low line height and
      monospace font.
- [ ] It should be conveniently readable from terminal web browsers (`elinks`,
      `lynx`).
- [ ] It should be conveniently readable from mobile devices. Double-tap on
      content block to zoom once is OK.
- [X] No 3rd-party CSS stylesheets or JS.
- [ ] Publishing and editing timestamps.
- [X] Publish via Github Action when changes are pushed.
- [X] Syntax highlighting in code blocks.
- [X] Styled markdown alerts.
- [ ] Auto-publishing from other sources (e.g. update projects documentation).
- [ ] Link GitHub Discussions to specific pages to act as "comment sections".
- [ ] Support multiple layouts.
- [X] Color inversion toggle (notice that "dark mode" is the default theme)
- [X] Change view dimensions (great when some browser plugins hide portions of
      the viewport).
- [X] Persist toggles state to local / session storage.
- [ ] Support adding tags and viewing pages by tags.
- [X] Basic OpenGraph support.
- [ ] When building` generate only changed pages rather than all.
- [ ] Clean redundant html pages when their markdown source no longer exists.

At the time of writing, there is definitely more work to be done, but I plan to
progress with time.

Mainly for the fun of it, I have decided to not use any of the plethora of
static-site generators (e.g. `jekyll`, `hugo`, `gatsbyjs`, `nanoc`) or builtin
themes, but to settle for rolling my own solution based on `pandoc` and a custom
script.

`pandoc` checks few boxes without interfering with others and made its way to be
the heart of this project. It is being used to convert markdown to HTML
(including code block syntax highlighting) and it does that beautifully. With
the correct HTML template, CSS stylesheet and a custom generation script, it is
more than enough for this use-case.

## Structure
Let's start with an overview of the repository file structure and workflow.
Before I was aware of Github Pages supporting `/docs` as a root directory for
non Jekyll sites, every "public" page was stored on the root directory of this
repository. Since this is no longer the case, I will omit the previous reference
(which was never published anyway).

At the time of writing, the repository file structure is similar to (slightly
modified output of `tree --dirsfirst -a -I .git -F`):
```
./
├── content/
│   ├── projects/
│   │   └── moyiz.github.io/
│   │       └── index.md
│   ├── 404.md
│   ├── about.md
│   └── index.md
├── css/
│   └── layout.css
├── docs/
│   ├── _css/
│   │   └── layout.css
│   ├── _icons/
│   ├── _js/
│   │   └── state.js
│   ├── 404.html
│   ├── build.sh.html
│   ├── favicon.ico
│   ├── index.html
│   ├── .nojekyll
│   └── _preview.png
├── filters/
│   ├── link.lua
│   └── title.lua
├── .github/
│   └── workflows/
│       └── publish.yaml
├── icons/
├── js/
│   └── state.js
├── scripts/
│   └── generate_menu.py
├── templates/
│   └── page.html
├── build.sh*
├── favicon.bmp
├── .nojekyll
├── .prettierrc.yaml
└── README.md
```

Content is written in markdown and placed in `content` directory. The layout of
the content directory is replicated in the published site, e.g.
`content/dir/file.md` will be available at `SITE_URL/dir/file.html`. Files
beginning with a dot are conventionally treated as drafts.

`scripts/generate_menu.py` An helper script that accepts a file containing
a list of file paths and a base URI. It parses then outputs that list as
a hierarchical nested HTML unordered list of links to all non-excluded pages,
where each level of nesting corresponds to the depth of the directory in
`content` and each link target is prepended by the given base URI.

If a file is named `index.md`, it will be omitted from the menu and be added as
a link target of the containing directory entry.

Files beginning with a dot or underscore are excluded from the generated menu.
For example, A path to a file containing:

```
posts/test.md
projects/proj1/index.md
projects/proj1/design.md
projects/proj2/index.md
a b.md
.bla.md
```

Will yield a similar output to the following:
```html
<ul>
<li>
posts/
 <ul>
 <li>
 <a href="posts/test.html">test</a>
 </li>
 </ul>
</li>
<li>
projects/
 <ul>
 <li>
 <a href="projects/proj1/index.html">proj1/</a>
  <ul>
  <li>
  <a href="projects/proj1/design.html">design</a>
  </li>
  </ul>
 </li>
 <li>
 <a href="projects/proj2/index.html">proj2/</a>
 </li>
 </ul>
</li>
<li>
<a href="a b.html">a b</a>
</li>
</ul>
```

`filters/` contains filters for `pandoc`. Filters are small scripts that use
`pandoc` built-in filtering system. Their purpose is to transform elements in
`pandoc` generated pages.

`filters/link.lua` will look for links in the input markdown file, and will
change `md` suffix to `html` (e.g. `[some link](file.md)` -> `<a
href="file.html">some link</a>`).

`filters/title.lua` will promote the first header in markdown files to `title`
if it was not explicitly defined in metadata. Custom titles can be defined via
metadata block in a markdown file:

```md
---
title: "My custom title"
---
```

`templates/page.html` is the main template used by `pandoc` to generate each
page. It originally started from the default template used by `pandoc`, but
diverged drastically.

`css/layout.css` accompanies `templates/page.html` and acts as the main CSS file
for the generated site. Initially generated from `$styles.html()$` substitution
in the default `pandoc` HTML template. Notable changes:
- Layout related customizations.
- Markdown alerts (`.note`, `.important`, `.warning`).
- Icon related customizations (e.g. Inverting colors for using with black
background).

`icons/` contains icons that are being used by this site` all of them originated
from [Free Icons](https://free-icons.github.io/free-icons/).

`js/state.js` is used by `templates/page.html` to provide a less ugly way of
toggling CSS classes on elements and persisting their state.
I tried to avoid touching Javascript at all, but it seemed like the least evil
option to achieve persistence.

`css/`, `icons/` and `js/` are published as well, but prefixed with an
underscore to be excluded by `scripts/generate_menu.py` and better indicate that
they do not contain content.

`favicon.bmp` has been drawn with [mtpaint](https://mtpaint.sourceforge.net/).
A happy accident of not making sure that `mtpaint` can actually export `ico`
images, based `favicon.bmp` as the source for both `favicon.ico` and
`_preview.png` (used for `OpenGraph` image) by leveraging
[ImageMagick](https://imagemagick.org/).

`build.sh` is the script that orchestrates all of the above in order to generate
the site itself in `docs/`, which is used as the site's root directory
(`Settings` -> `Pages` -> `Branch` -> `master /docs`).

## build.sh
`build.sh` does quite a few things:
- Finds the repository root directory and verifies that it is actually a `git`
repository. This is a safety mechanism to prevent it from generating the site
elsewhere.
- Generates a markdown file containing the build script itself. You can view it
in [build.sh](build.sh.md). The generated markdown file is removed when the
script exits, after the page was created.
- Finds all pages in `content`.
- Generates a metadata file containing the output of `scripts/generate_menu.py`.
- Published `js/`, `icons/` and `css/` and prefixes them with underscore.
- Makes sure that `.nojekyll` exists. Its existence instructs Github Pages to
not invoke Jekyll related workflows.
- Generates HTML pages from each markdown file. Markdown file prefixed with
a dot (`.`) are provided with a `draft` variable, to notate that these pages are
in draft.
- Generates `favicon.ico` from `favicon.bmp` with `magick`.
- Generates `_preview.png` from `favicon.bmp` with `magick`. It upscales and
extends `favicon.bmp` to `400x200` (original file is `32x32`).

Executing `./build.sh` will generate the site with local paths (dev). Executing
`./build.sh release` will use the actual site URL in place of local paths.

## Layout

The site's chosen default layout is a variation of the [Holy Grail][hg] with
slight changes:
- No "ads" column.
- Fixed one line header.
- Fixed one line footer.
- Fixed (toggle-able) sidebar.

I initially planned to use HTML frameset, [but apparently they are
obsolete][frames]. So this layout is designed with [CSS flexbox
containers][cfc].

[hg]: https://en.wikipedia.org/wiki/Holy_grail_(web_design)
[frames]: https://html.com/frames/
[cfc]: https://www.w3schools.com/css/css3_flexbox_container.asp

### Header
Inspired by tiling window managers statusbars. Its components include:
- A sidebar toggle.
- Full path of current page.
- Page title.
- A toggle to reduce layout width.
- A toggle to reduce layout height.
- A toggle to invert all colors (dark / light mode).
- A link to my Github Profile.

### Footer
Inspired by `vim`/`neovim` status-line and displays information of the source
markdown file, such as:
- Filename
- Number of lines.
- Number of words.
- Number of bytes.
- Expected average reading time (assuming 238 words per minute).

### Sidebar
Inspired by `tree` command and file explorers in various IDEs (or `vim`/`neovim`
plugins such as [nvim-tree][nvt] and [neotree][net]).

It displays the output of `scripts/generate_menu.py` (described above).

[nvt]: https://github.com/nvim-tree/nvim-tree.lua
[net]: https://github.com/nvim-neo-tree/neo-tree.nvim

### Content
Contains the converted markdown file content and an optional table of contents,
if enabled for the specific page.

 
