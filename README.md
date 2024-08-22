# 📂 Foldtext.nvim

![demo_1](https://github.com/OXY2DEV/foldtext.nvim/blob/images/images/foldtext_demo_1.jpg)
![demo_2](https://github.com/OXY2DEV/foldtext.nvim/blob/images/images/foldtext_demo_2.jpg)
![demo_3](https://github.com/OXY2DEV/foldtext.nvim/blob/images/images/foldtext_demo_3.jpg)
![demo_4](https://github.com/OXY2DEV/foldtext.nvim/blob/images/images/foldtext_demo_4.jpg)

A *fancier* way to fold your code.

## ✨ Features

- Dynamic foldtext. Can be customised *per-buffer* & *per-window*.
- Allows customizing the foldtext with parts to make the process easier. Each part can also be individually enabled/disabled.
- Completely different foldtext based on *filetype*, *buftype* & conditions.

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

## 🧭 Example usage

### 📜 Markdown

Folds in markdown starting with a line containing `<summary></summary>` will show the text inside it.

Try setting your `foldmethod` to `indent` and see what this code block looks like.

```md
<detail>
    <summary>An example summary</summary>

    Some text
</detail>
```

This also works in other `foldme.s` too!

### 📜 Lua

In a `lua` file, if a fold's starting line contains `${}` with some text inside this will render as a custom fold.

For example, folding this text

```lua
-- ${default}
vim.print("Hello neovim");
```

Results in something like this.

You can also add titles to your folds.

```lua
-- ${func, A helper function}
local function test()
    vim.print("Test");
end
```

This becomes something like this,


They also have various options,

- default, shows the lua logo
- conf, shows a cog
- ui, shows a phone
- func, shows a function symbol
- hl, shows a palette symbol
- calc, shows a calculator
- dep, shows a box

## 🔩 Configuration options

Foldtext's configuration table is as follows

```lua
{
    ft_ignore = {}, -- file types to ignore
    bt_ignore = {}, -- buf types to ignore

    default = {}, -- default fold text configuration
    custom = {} -- Condition based fold text configurations
}
```

Foldtexts are created with *parts*. Each part is a table that shows some text in the foldtext.

## 🧩 Parts

Foldtext come with a few parts to get you started with creating foldtexts.

```lua
{
    type = "raw", -- Part type
    condition = function (win, buf)
        -- Condition for the part
        return true;
    end
}
```

### 🧩 Part: raw

Shows some string in the fold text.

```lua
{
    type = "raw",
    text = "Fold",
    hl = "Folded"
}
```

### 🧩 Part: fold_size

Shows the number of lines folded.

```lua
{
    type = "fold_size",
    hl = "Special"
}
```

### 🧩 Part: indent

Indents the foldtext to match the original text.

>[!Note]
> Fold texts do not scroll horizontally.

```lua
{
    type = "indent",
    hl = "CursorLine"
}
```

### 🧩 Part: custom

Allows writing a custom handler for the foldtext.

```lua
{
    type = "custom",
    handler = function (window, buffer)
        -- { text, highlight_group }
        return { "Hello world", "Special" };
    end
}
```

The function can also return a *list* of tables.

```lua
{
    type = "custom",
    handler = function (window, buffer)
        -- { { text, highlight_group } }
        return {
            { "Hello", "Special" },
            { "world", "Normal" },
        };
    end
}
```

## ✨ Custom foldtext

The `custom` option can be used to make `condition-based` foldtext.

```lua
custom = {
    {
        ft = {}, -- file types where it will be used
        bt = {}, -- buf types where it will be used
        condition = function (win, buf)
            -- Additional conditions
            return true;
        end,

        -- Configuration table
        config = {}
    }
}
```

>[!Tip]
> You can use *ft*, *bt* & *cond* together for more control over the foldtext.

### 👾 Example usage

This foldtext is used in *markdown* files when the fold starts on a line containing a `<summary>` tag.

It display whatever is used as the summary(kinda, like how Github does)

```lua
{
    ft = { "markdown" },
    condition = function (_, buf)
        local ln = table.concat(vim.fn.getbufline(buf, vim.v.foldstart))

        if ln:match("^%s*<summary>(.-)</summary>") then
            return true;
        else
            return false;
        end
    end,
    config = {
        {
            type = "indent",
            hl = "TabLineSel"
        },
        {
            type = "raw",
            text = " ",
            hl = "Title"
        },
        {
            type = "custom",
            handler = function (_, buf)
                local ln = table.concat(vim.fn.getbufline(buf, vim.v.foldstart))

                return { ln:match("^%s*<summary>(.-)</summary>"), "Title" };
            end
        }
    }
}
```

