local function read_items()
  local candidates = {
    "news/items.json",
    "../news/items.json",
  }

  local project_dir = os.getenv("QUARTO_PROJECT_DIR")
  if project_dir ~= nil then
    table.insert(candidates, 1, pandoc.path.join({ project_dir, "news", "items.json" }))
  end

  for _, path in ipairs(candidates) do
    local file = io.open(path, "r")
    if file ~= nil then
      local contents = file:read("*a")
      file:close()
      return pandoc.json.decode(contents)
    end
  end

  return {}
end

local function sort_items(items)
  table.sort(items, function(a, b)
    return a.sort > b.sort
  end)
  return items
end

local function normalize_photo_src(src, from_root)
  if src:match("^https?://") then
    return src
  end

  local path = src:gsub("\\", "/"):gsub("^/", "")

  if from_root then
    return path
  end

  -- news/index.html lives one directory below the site root
  return "../" .. path
end

local function render_photo_blocks(item, from_root)
  if item.photos == nil or #item.photos == 0 then
    return {}
  end

  local inner = {}
  for _, photo in ipairs(item.photos) do
    local img = pandoc.Image(
      photo.alt or "",
      normalize_photo_src(photo.src, from_root),
      "",
      pandoc.Attr("", {}, { width = photo.width or "520" })
    )
    table.insert(inner, pandoc.Para({ img }))
  end

  if item.photo_caption ~= nil and item.photo_caption ~= "" then
    for _, block in ipairs(pandoc.read(item.photo_caption, "markdown").blocks) do
      table.insert(inner, block)
    end
  end

  local class = #item.photos > 1 and "content-photo-pair" or "content-photo"
  return { pandoc.Div(inner, pandoc.Attr("", { class }, {})) }
end

local function render_item(item, show_photos, from_root)
  local blocks = {}
  local text = string.format("**%s:** %s", item.label, item.text)

  for _, block in ipairs(pandoc.read(text, "markdown").blocks) do
    table.insert(blocks, block)
  end

  if show_photos then
    for _, block in ipairs(render_photo_blocks(item, from_root)) do
      table.insert(blocks, block)
    end
  end

  return pandoc.Div(blocks, pandoc.Attr("", { "news-item" }, {}))
end

local function render_items(limit, show_photos, from_root)
  local items = sort_items(read_items())
  local blocks = {}

  if limit ~= nil then
    local trimmed = {}
    for i = 1, math.min(limit, #items) do
      trimmed[i] = items[i]
    end
    items = trimmed
  end

  for _, item in ipairs(items) do
    table.insert(blocks, render_item(item, show_photos, from_root))
  end

  return blocks
end

function Div(el)
  if not el.classes:includes("news-list") then
    return nil
  end

  local limit = el.attributes["limit"]
  if limit ~= nil then
    limit = tonumber(limit)
  end

  local show_photos = el.attributes["photos"] == "true"
  local from_root = el.attributes["root"] == "true"

  return pandoc.Div(
    render_items(limit, show_photos, from_root),
    pandoc.Attr("", { "news-list" }, {})
  )
end
