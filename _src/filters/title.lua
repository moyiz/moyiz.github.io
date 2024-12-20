---Promote first level 1 header to `title` if `title` was not set explicitly.
---Do not discard the header.

local title

local function init_title(meta)
	title = meta.title
end

local function set_title(header)
	if header.level == 1 and not title then
		title = header.content
	end
	return header
end

local function set_meta_title(meta)
	if title then
		meta.title = title
	end
	return meta
end

return {
	{ Meta = init_title },
	{ Header = set_title },
	{ Meta = set_meta_title },
}
