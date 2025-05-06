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

