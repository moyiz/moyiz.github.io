'''
Example

Input:
"""
posts/test.md
projects/proj1/index.md
projects/proj1/design.md
projects/proj2/index.md
a b.md
.bla.md
"""

Output:
"""
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
"""
'''

from __future__ import annotations
from dataclasses import dataclass, field
from pathlib import Path
import re
import sys

EXCLUDE_REGEX = [re.compile(r) for r in (r"^\.", r"^_", r"^404$")]


@dataclass
class Item:
    label: str
    target: str | None = None
    parent: Item | None = None
    items: list[Item] = field(default_factory=list)
    set_class: bool = True

    def get_item(self, label: str) -> Item | None:
        for it in self.items:
            if it.label == label:
                return it


def parse_pages(pages: str) -> Item:
    paths = pages.splitlines()
    root = Item("~/", target="", set_class=False)
    for path in paths:
        p = Path(path.removesuffix(".md"))
        target = f"{p}.html"
        if any(r.match(p.name) for r in EXCLUDE_REGEX):
            continue
        if len(p.parts) == 1 and p.name != "index":
            root.items.append(Item(p.name, target=target))
        else:
            item = root
            for part in p.parent.parts:
                part = f"{part}/"
                if not (it := item.get_item(part)):
                    item.items.append(it := Item(part))
                item = it
            if p.name != "index":
                item.items.append(it := Item(p.name))
                item = it
            item.target = target
    return root


def generate_html(items: list[Item], base_url: str) -> str:
    s = ""
    if items:
        s = "<ul>"
        for i, item in enumerate(items, start=1):
            if item.set_class:
                if i == len(items):
                    s += '<li class="last">'
                else:
                    s += '<li class="item">'
            else:
                s += "<li>"
            if item.target:
                s += f'<a href="{base_url}/{item.target}">{item.label}</a>'
            else:
                s += item.label
            s += generate_html(item.items, base_url=base_url)
            s += "</li>"
        s += "</ul>"
    return s


if __name__ == "__main__":
    if len(sys.argv) != 3:
        _ = sys.stderr.write(f"Usage: {sys.argv[0]} <FILE>")
        sys.exit(1)
    print(
        generate_html(
            items=Item(
                label="dummy",
                items=[parse_pages(Path(sys.argv[1]).read_text())],
            ).items,
            base_url=sys.argv[2],
        )
    )
