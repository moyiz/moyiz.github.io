let s = sessionStorage

function toggleInvert(img) {
  document.body.classList.toggle("invert")
  if (document.body.classList.contains("invert")) {
    img.src = "_icons/sun-bright.svg"
    s.setItem("invert", true)
  } else {
    img.src = "_icons/moon-stars.svg"
    s.removeItem("invert")
  }
}

function toggleMenu(img) {
  const menu = document.querySelector(".menu")
  menu.classList.toggle("hide-menu")
  if (menu.classList.contains("hide-menu")) {
    img.src = "_icons/bars.svg"
    s.setItem("menu", true)
  } else {
    img.src = "_icons/list.svg"
    s.removeItem("menu")
  }
}

function toggleSmaller(img) {
  const layout = document.querySelector(".layout")
  layout.classList.toggle("smaller")
  if (layout.classList.contains("smaller")) {
    img.src = "_icons/arrows-from-line.svg"
    s.setItem("smaller", true)
  } else {
    img.src = "_icons/arrows-to-line.svg"
    s.removeItem("smaller")
  }
}

function toggleNarrower(img) {
  const layout = document.querySelector(".layout")
  layout.classList.toggle("narrower")
  if (layout.classList.contains("narrower")) {
    img.src = "_icons/arrows-left-right-to-line.svg"
    s.setItem("narrower", true)
  } else {
    img.src = "_icons/compress-wide.svg"
    s.removeItem("narrower")
  }
}

function recoverSettings() {
  if (s.getItem("invert") == "true") {
    toggleInvert(document.getElementById("toggle-invert"))
  }
  if (s.getItem("menu") == "true") {
    toggleMenu(document.getElementById("toggle-menu"))
  }
  if (s.getItem("smaller") == "true") {
    toggleSmaller(document.getElementById("toggle-smaller"))
  }
  if (s.getItem("narrower") == "true") {
    toggleNarrower(document.getElementById("toggle-narrower"))
  }
}

recoverSettings()
