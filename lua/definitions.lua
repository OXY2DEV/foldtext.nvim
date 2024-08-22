---@meta

--- Configuration table for foldtext.nvim
---@class foldtext.cofig
---
--- Filetypes to ignore
---@field ft_ignore string[]?
---
--- Buftypes to ignore
---@field bt_ignore string[]?
---
--- Default foldtext
---@field default (foldtext.config.raw | foldtext.config.size | foldtext.config.indent | foldtext.config.custom)[]
---
--- Custom foldtext
---@field custom? foldtext.custom[]


--- Configuration table for the custom foldtext
---@class foldtext.custom
---
--- List of filetypes where this will be used
---@field ft? string[]
---
--- List of buftypes where this will be used
---@field bt? string[]
---
--- Condition for this foldtext
---@field condition? fun(win: number, buf: number): boolean
---
--- Condition for the part
---@field config (foldtext.config.raw | foldtext.config.size | foldtext.config.indent | foldtext.config.custom)[]


--- Configuration table for raw text
---@class foldtext.config.raw
---
--- Condition for the part
---@field condition? fun(win: number, buf: number): boolean
---
--- Part type
---@field type string
---
--- The string to show
---@field text string | fun(win: number, buf: number): string
---
--- Highlight group for text
---@field hl (string | string[])?


--- Configuration table for fold size
---@class foldtext.config.size
---
--- Condition for the part
---@field condition? fun(win: number, buf: number): boolean
---
--- Part type
---@field type string
---
--- Prefix to add before the number
---@field prefix string?
---
--- Postfix to add after the number
---@field postfix string?
---
--- Highlight group for the part
---@field hl string?


--- Configuration table for indent
---@class foldtext.config.indent
---
--- Condition for the part
---@field condition? fun(win: number, buf: number): boolean
---
--- Part type
---@field type string
---
--- Highlight group for the indent
---@field hl string?


--- Configuration table for custom part
---@class foldtext.config.custom
---
--- Condition for the part
---@field condition? fun(win: number, buf: number): boolean
---
--- Part type
---@field type string
---
--- Handler for the foldtext
---@field handler fun(win: number, buf: number): [string, string] | [ string, string ][]
