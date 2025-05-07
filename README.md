# 📂 Foldtext.nvim

>[!NOTE]
> `v2.0.0` is a **complete rewrite** of the original plugin. It is **not backwards compatible**.
>
> You can always tag the plugin's version to `1.0.0` from your package manager until you are ready to migrate. Also see [migration](#-migration).

*Fancy* foldtext for `Neovim`.

## ✨ Features

- Per window foldtext setup, allows showing different foldtext in different windows!
- Allows customizing the foldtext with built-in reusable parts to make the process easier. Each part can also be individually enabled/disabled.
- Completely different foldtext based on *filetype*, *buftype* & other conditions.

## 📦 Installation

`Foldtext.nvim` can be installed via your favourite package managers.

### 💤 Lazy.nvim

For `lazy.lua`/`plugins.lua` users.

```lua
{
    "OXY2DEV/foldtext.nvim",
    lazy = false
}
```

For `plugins/foldtext.lua` users.

```lua
return {
    "OXY2DEV/foldtext.nvim",
    lazy = false
}
```

### 🦠 Mini.deps

```lua
local MiniDeps = require("mini.deps");

MiniDeps.add({
    source = "OXY2DEV/foldtext.nvim"
});
```

### 🌒 Rocks.nvim

You can install the plugin via `rocks.nvim` with the following command.

```vim
:Rocks install foldtext.nvim
```

## 🔩 Configuration

The plugin can be configured via the `setup()` command. The configuration table has the following structure,

```lua
require("foldtext").setup({
    -- Ignore buffers with these buftypes.
    ignore_buftypes = {},
    -- Ignore buffers with these filetypes.
    ignore_filetypes = {},
    -- Ignore buffers/windows if the result
    -- is false.
    condition = function ()
        return true;
    end,

    styles = {
        default = {
            { kind = "bufline" }
        },

        -- Custom foldtext.
        custom_a = {
            -- Only on these filetypes.
            filetypes = {},
            -- Only on these buftypes.
            buftypes = {},

            -- Only if this condition is
            -- true.
            condition = function (win)
                return vim.wo[win].foldmethod == "manual";
            end,

            -- Parts to create the foldtext.
            parts = {
                { kind = "fold_size" }
            }
        }
    }
});
```

You can find the default configuration table [here]().

------

Description about each option is given below,

### ignore_buftypes

- Type: `string[]`
- Default: `{ "nofile" }`

Buffer types to ignore.

>[!NOTE]
> `nofile` buffers may use folds for various things, so we ignore them.

### ignore_filetypes

- Type: `string[]`

File types to ignore.

### condition

- Type: `fun(buffer: integer, window: integer): boolean`

Function to determine if a window should be attached to. Used for defining additional conditions.

### styles

- Type: `foldtext.styles`

Styles for different foldtexts.

#### default

- Type: `foldtext_part[]`

Parts for the default foldtext. See [parts](#-parts) for more info.

#### custom_a

- Type: `foldtext.custom_style`

Custom style for the foldtext. Here it's named `custom_a`.

##### filetypes

- Type: `string[]`

File types where this style should be enabled.

##### buftypes

- Type: `string[]`

Buffer types where this style should be enabled.

##### condition

- Type: `fun(buffer: integer, window: integer): boolean`

Addition conditions for this style.

##### parts

- Type: `foldtext_part[]`

Parts for this foldtext. See [parts](#-parts) for more info.

### 🔄 Migration

These are the option name changes for `v2.0.0`.

```diff
example.lua
 {
-    ft_ignore = {},
+    ignore_filetypes = {},

-    bt_ignore = {},
+    ignore_buftypes = {},

-    default = {},
-    custom = {},
+    styles = {
+        default = {},
+        a = {}
+    }
 }
```

Parts have also been changed. These are,

#### raw

Has been deprecated in favor of `section`.

```diff
raw.lua
 {
-    type = "raw",
+    kind = "section",

     condition = function ()
         return true;
     end

-    text = "abcd",
-    hl = "Comment"
+    output = {
+       { "abcd", "Comment" },
+    }
 }
```

#### fold_size

Has new options & option name changes,

```diff
fold_size.lua
 {
+    condition = function ()
+        return true;
+    end

-    type = "fold_size",
+    kind = "fold_size",
 
     hl = "Special",
 
+    padding_left = nil,
+    padding_left_hl = nil,

+    padding_right = nil,
+    padding_right_hl = nil,

+    icon = nil,
+    icon_hl = nil,
 }
```

#### indent

Has new option & option name change,

```diff
indent.lua
 {
+    condition = function ()
+        return true;
+    end

-    type = "indent",
+    kind = "indent",
 
     hl = "Comment"
 }
```

#### custom

Has been removed in favor of `section`,

```diff
custom.lua
 {
+    condition = function ()
+        return true;
+    end

-    type = "custom",
+    kind = "section",
 
-    handler = function (window, buffer)
-        return {
-            { "text" }
-        };
-    end
+    output = function (buffer, window)
+        return {
+            { "text" }
+        };
+    end
 }
```

## 🧩 Parts

Some built-in parts are provided in the plugin. These are,

### bufline

Shows the buffer line with tree-sitter syntax highlighting. Has the following options,

```lua
{
    kind = "bufline",
    -- Optional condition for this
    -- part.
    condition = function ()
        return true;
    end

    -- Delimiter between the start/end line.
    delimiter = "...",
    -- Highlight group for `delimiter`.
    hl = "@comment"
```

### description

Conventional commit styled fold description. Has the following options,

```lua
{
    kind = "description",
    -- Optional condition for this
    -- part.
    condition = function ()
        return true;
    end

    -- Pattern to detect the foldtext from the start line.
    -- Here I am using, "feat: Keymaps" & "fix, Something's not right here"
    pattern = '[\'"](.+)[\'"]',
    styles = {
        default = {
            hl = "@comment",
            icon = "💭 ",
            icon_hl = nil
        },

        -- Style for `doc`(case-insensitive).
        -- Options are merged with `default`
        -- before being used.
        doc = {
            -- hl, icon_hl are inherited from
            -- `default`.
            icon = "📚 ",
        }
    }
}
```

### section

A section of the foldtext. Has the following options,

```lua
{
    kind = "section",
    -- Optional condition for this
    -- part.
    condition = function ()
        return true;
    end

    -- Text to show for this section. Has
    -- the same structure as virtual text.
    -- [ text, highlight_group ][]
    output = {
        { "Hello, Neovim!", "Comment" }
    },
    -- Can also be a function!
    output = function (buffer, window)
        return {
            { "Buf: " .. buffer },
            { "Win: " .. window },
        };
    end
}
```

### fold_size

Shows the fold size. Has the following option,

```lua
{
    kind = "fold_size",
    -- Optional condition for this
    -- part.
    condition = function ()
        return true;
    end

    -- Highlight group for the entire
    -- part.
    hl = "@comment",

    icon = "←→ ",
    icon_hl = nil,

    padding_left = " ",
    padding_left_hl = nil,

    padding_right = " ",
    padding_right_hl = nil,
}
```

### indent

Adds the fold's starting line's indentation. Has the following options,

```lua
{
    kind = "indent",
    -- Optional condition for this
    -- part.
    condition = function ()
        return true;
    end

    hl = nil
}
```

