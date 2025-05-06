---@meta


---@class foldtext.config Configuration for the foldtext.
---
---@field ignore_filetypes? string[]
---@field ignore_buftypes? string[]
---@field condition? fun(buffer: integer, window: integer): boolean
---
---@field styles foldtext.styles


---@class foldtext.styles A foldtext style.
---
---@field default foldtext_part[]
---@field [string] foldtext.custom_style


---@class foldtext.custom_style
---
---@field filetypes? string[]
---@field buftypes? string[]
---
---@field condition fun(buffer: integer, window: integer): boolean
---@field parts foldtext_part[]

------------------------------------------------------------------------------

---@class foldtext.fragment Fragment of the foldtext.
---
---@field [1] string Text to show.
---@field [2]? string Highlight group for the text.


---@alias foldtext_part
---| foldtext.bufline
---| foldtext.description
---| foldtext.section
---| foldtext.fold_size
---| foldtext.indent


---@class foldtext.bufline Configuration for the buffer-line component.
---
---@field kind "bufline"
---@field condition? fun(buffer: integer, window: integer, parts: foldtext_part[]): boolean
---
---@field delimiter string Text to put between the start & end line.
---@field hl string Highlight group for the delimiter.


---@class foldtext.description Configuration for the fold description component.
---
---@field kind "description"
---@field condition? fun(buffer: integer, window: integer, parts: foldtext_part[]): boolean
---
---@field pattern? string Pattern for detecting descriptions in a line.
---@field kinds? table<string, foldtext.description.kind>


---@class foldtext.description.kind Configuration for the conventional-commit style decorations.
---
---@field icon? string
---@field icon_hl? string
---
---@field scope_format? string Text format for showing the scope.
---@field scope_hl? string
---
---@field separator? string Separator between the scope and the text.
---@field separator_hl? string
---
---@field hl? string


---@class foldtext.section Configuration for a section of the foldtext.
---
---@field kind "section"
---@field condition? fun(buffer: integer, window: integer, parts: foldtext_part[]): boolean
---
---@field output foldtext.fragment[] | fun(buffer: integer, window: integer): foldtext.fragment[] Stuff to show on the foldtext.


---@class foldtext.fold_size Configuration for the fold size component.
---
---@field kind "fold_size"
---@field condition? fun(buffer: integer, window: integer, parts: foldtext_part[]): boolean
---
---@field padding_left? string
---@field padding_left_hl? string
---
---@field icon? string
---@field icon_hl? string
---
---@field padding_right? string
---@field padding_right_hl? string
---
---@field hl? string Main highlight group.


---@class foldtext.indent Configuration for the indentation component.
---
---@field kind "indent"
---@field condition? fun(buffer: integer, window: integer, parts: foldtext_part[]): boolean
---
---@field hl? string

