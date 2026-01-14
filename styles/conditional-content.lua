-- Conditional content filter for Quarto
-- Based on The-Cosmic-Counselor patterns

function Div(el)
  -- Handle format-specific content
  if el.classes:includes("html-only") and FORMAT ~= "html" then
    return {} -- Remove for non-HTML formats
  elseif el.classes:includes("pdf-only") and FORMAT ~= "pdf" then
    return {} -- Remove for non-PDF formats
  elseif el.classes:includes("print-only") and not (FORMAT == "pdf" or FORMAT == "docx") then
    return {} -- Remove for non-print formats
  elseif el.classes:includes("web-only") and FORMAT ~= "html" then
    return {} -- Remove for non-web formats
  end

  -- Handle interactive elements
  if el.classes:includes("interactive") and FORMAT ~= "html" then
    -- Convert interactive elements to static for non-HTML formats
    if el.classes:includes("quiz") then
      -- Replace quiz with note about interactivity
      return pandoc.Div({
        pandoc.Para({
          pandoc.Str("📝 Interactive quiz available in the HTML version of this document.")
        })
      }, pandoc.Attr("", {"alert", "alert-info"}))
    elseif el.classes:includes("chart") then
      -- Replace interactive chart with note
      return pandoc.Div({
        pandoc.Para({
          pandoc.Str("📊 Interactive chart available in the HTML version of this document.")
        })
      }, pandoc.Attr("", {"alert", "alert-info"}))
    end
  end

  return el
end

function CodeBlock(el)
  -- Handle code execution based on format
  if el.classes:includes("no-execute") and FORMAT ~= "html" then
    -- Remove execution for non-interactive formats
    return pandoc.CodeBlock(el.text, pandoc.Attr(el.attr.identifier, {}, {}))
  end

  return el
end

function Image(el)
  -- Handle image optimization based on format
  if FORMAT == "html" then
    -- Add lazy loading for HTML
    el.attributes.loading = "lazy"
  elseif FORMAT == "pdf" then
    -- Ensure high DPI for PDF
    if not el.attributes.dpi then
      el.attributes.dpi = "300"
    end
  end

  return el
end