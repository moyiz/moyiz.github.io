---
toc: true
---

# moyiz.github.io

> [!NOTE]
> Most of the content on this page is subjected to possible changes. I will try
> to keep it up-to-date with the progression of this site, but dissimilarities
> might occur.

A micro-blog like site with an emphasis on simplicity.

## Features
- [X] Content should be written in markdown (preferably Github variant).
- [X] A file-manager-like sidebar to navigate.
- [X] Underscore-prefixed markdown files should be excluded from the sidebar.
- [X] Dot-prefixed markdown files should be excluded from the sidebar and be
      marked as "draft".
- [X] Simple, trivial and predictable - black background, low line height and
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
- [ ] When building, generate only changed pages rather than all.
- [ ] Clean redundant html pages when their markdown source no longer exists.

At the time of writing, there is definitely more work to be done, but I plan to
progress with time.

Mainly for the fun of it, I have decided to not use any of the plethora of
static-site generators (e.g. `jekyll`, `hugo`, `gatsbyjs`, `nanoc`) or builtin
themes, but to settle for good old `pandoc`, templates and scriptology to build
a solution around it.

`pandoc` checks few boxes without interfering with others and made its way to be
the heart of this project. It is being used to convert markdown to HTML
(including code block syntax highlighting) and it does that beautifully. With
the correct HTML template, CSS stylesheet and a custom generation script, it is
more than enough for this use-case.

## Layout

The site's chosen default layout is a variation of the [Holy Grail][hg] with
slight changes:
- No "ads" column.
- Fixed one line header.
- Fixed one line footer.
- Fixed (toggle-able) menu.

I initially planned to use HTML framesets, [but apparenty they are
obsolete][frames]. So this layout is designed with [CSS flexbox
containers][cfc].

[hg]: https://en.wikipedia.org/wiki/Holy_grail_(web_design)
[frames]: https://html.com/frames/
[cfc]: https://www.w3schools.com/css/css3_flexbox_container.asp

## File Structure

### Repository root
Files and subdirectories in the repository root directory can be divided into 3
categories:
1. GitHub related (i.e. GitHub Actions and `README.md`)
2. HTML pages representing actual content.
3. Source (`_src`).

### content
Contains the actual markdown files that will be converted to HTML pages.

### build.sh
The core of the site generation is [`_src/build.sh`][bsh]. For a clean URL experience,
the HTML pages generation is targeting the root directory of this repository.

All HTML pages not in `_src` are generated from markdown files in `content` by
`build.sh`.
It does few things:
- Collects paths of all markdown files under `_src/content`.
- Calls `_src/scripts/generate_menu.py` to generate the HTML representation of
  the sidebar.
- Collects page metadata.
- Calls `pandoc` to generate the HTML pages.

[bsh]: build.sh.html

### scripts/generate_menu.py
An helper script that accepts a file containing a list of file paths. It parses
then outputs that list as a hierarchical nested HTML unordered list of links to
all non-excluded pages, where each level of nesting corresponds to the depth of
the directory in `content`.

If a file is named `index.md`, it will be omitted from the menu and be added as
a link target of the containing directory entry.

Files beginning with a dot or underscore are excluded from the generated menu.

#### Example
**Input**: A path to a file containing:
```
posts/test.md
projects/proj1/index.md
projects/proj1/design.md
projects/proj2/index.md
a b.md
.bla.md
```

**Output**:
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

### templates/page.html
Contains the page template and the accompanied CSS stylesheet.

### css/layout.css
Initially generated from `$styles.html()$` substitution in HTML template.
Notable changes:
- Layout related.
- Markdown alerts (`.note`, `.important`, `.warning`).
- Icon related.

### filters
Contains `pandoc` lua filters. Applied during page generation on the target
document elements.
- `link.lua` - Converts links that target markdown files into their HTML counterparts.
- `title.lua` - Promotes the first header to the page's title if it is not defined.


## Limitations
Generated HTML pages are not tracked in any way. Thus, renaming or removing
markdown would not be reflected on existing HTML pages.
