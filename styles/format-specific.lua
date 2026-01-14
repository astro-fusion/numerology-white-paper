-- Format-specific processing filter for Quarto
-- Handles format-dependent content modifications

function Pandoc(doc)
  -- Set global FORMAT variable for other filters
  FORMAT = FORMAT or doc.meta.format or "html"

  -- Format-specific document processing
  if FORMAT == "html" then
    return process_html(doc)
  elseif FORMAT == "pdf" then
    return process_pdf(doc)
  elseif FORMAT == "docx" then
    return process_docx(doc)
  elseif FORMAT == "epub" then
    return process_epub(doc)
  else
    return doc
  end
end

function process_html(doc)
  -- HTML-specific processing
  -- Add viewport meta tag, improve accessibility, etc.

  -- Ensure proper heading structure
  local blocks = {}
  for i, block in ipairs(doc.blocks) do
    if block.t == "Header" then
      -- Ensure proper heading hierarchy
      if block.level > 1 and i > 1 and doc.blocks[i-1].t ~= "Header" then
        -- Add anchor for navigation
        block.attributes = block.attributes or {}
        block.attributes.id = block.attributes.id or generate_anchor(block.content)
      end
    end
    table.insert(blocks, block)
  end

  doc.blocks = blocks
  return doc
end

function process_pdf(doc)
  -- PDF-specific processing
  -- Optimize for print, handle page breaks, etc.

  local blocks = {}
  for i, block in ipairs(doc.blocks) do
    if block.t == "Header" and block.level == 1 then
      -- Add page break before major sections
      table.insert(blocks, pandoc.RawBlock("latex", "\\clearpage"))
    elseif block.t == "Header" and block.level == 2 then
      -- Add small space before subsections
      table.insert(blocks, pandoc.RawBlock("latex", "\\vspace{1em}"))
    end
    table.insert(blocks, block)
  end

  doc.blocks = blocks
  return doc
end

function process_docx(doc)
  -- DOCX-specific processing
  -- Handle Word-specific formatting

  local blocks = {}
  for i, block in ipairs(doc.blocks) do
    -- Ensure proper spacing in Word
    if block.t == "Header" then
      table.insert(blocks, pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'))
    end
    table.insert(blocks, block)
  end

  doc.blocks = blocks
  return doc
end

function process_epub(doc)
  -- EPUB-specific processing
  -- Optimize for e-readers

  local blocks = {}
  for i, block in ipairs(doc.blocks) do
    if block.t == "Header" and block.level == 1 then
      -- Add chapter break for EPUB
      table.insert(blocks, pandoc.RawBlock("html", '<div style="page-break-before: always;"></div>'))
    end
    table.insert(blocks, block)
  end

  doc.blocks = blocks
  return doc
end

function generate_anchor(content)
  -- Generate URL-safe anchor from header content
  local text = ""
  for i, inline in ipairs(content) do
    if inline.t == "Str" then
      text = text .. inline.text
    elseif inline.t == "Space" then
      text = text .. "-"
    end
  end

  -- Clean up the anchor
  text = text:lower():gsub("[^%w-]", ""):gsub("-+", "-"):gsub("^-+", ""):gsub("-+$", "")
  return text
end

-- Utility functions
function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function string.startswith(str, prefix)
  return str:sub(1, #prefix) == prefix
end

function string.endswith(str, suffix)
  return suffix == "" or str:sub(-#suffix) == suffix
end