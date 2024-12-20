---Prepends absolute page URL when link is anchor.
---Fixes TOC links when using <base>.
function Link(el)
	print(el.target)
	if el.target:sub(1, 1) == "#" then
		-- el.target = PANDOC_WRITER_OPTIONS.variables["pagepath"] .. el.target
		el.target = "/blabla" .. el.target
	end
	return el
end
