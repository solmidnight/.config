
    -- --------------------------------------------------------
    -- Readability
    -- --------------------------------------------------------

    vim.o.guifont = "Menlo:h16"
    vim.opt.linespace = 2

    -- Opaque window for maximum code contrast
    vim.g.neovide_theme = "dark"

    -- Comfortable editor margins
    vim.g.neovide_padding_top = 12
    vim.g.neovide_padding_bottom = 8
    vim.g.neovide_padding_left = 14
    vim.g.neovide_padding_right = 14

    -- --------------------------------------------------------
    -- Cursor animation
    -- --------------------------------------------------------

    vim.g.neovide_cursor_animation_length = 0.10
    vim.g.neovide_cursor_short_animation_length = 0.025
    vim.g.neovide_cursor_trail_size = 0.65

    vim.g.neovide_cursor_antialiasing = true
    vim.g.neovide_cursor_animate_in_insert_mode = false
    vim.g.neovide_cursor_animate_command_line = true
    vim.g.neovide_cursor_smooth_blink = false

    -- --------------------------------------------------------
    -- Wireframe cursor VFX
    -- --------------------------------------------------------

    vim.g.neovide_cursor_vfx_mode = "wireframe"
    vim.g.neovide_cursor_vfx_opacity = 160.0
    vim.g.neovide_cursor_vfx_particle_lifetime = 0.45
    vim.g.neovide_cursor_vfx_particle_highlight_lifetime = 0.12
    vim.g.neovide_cursor_vfx_particle_density = 0.45
    vim.g.neovide_cursor_vfx_particle_speed = 8.0

    -- --------------------------------------------------------
    -- Scrolling
    -- --------------------------------------------------------

    vim.g.neovide_scroll_animation_length = 0.15
    vim.g.neovide_scroll_animation_far_lines = 3

    -- --------------------------------------------------------
    -- Window behavior
    -- --------------------------------------------------------

    vim.g.neovide_hide_mouse_when_typing = true
    vim.g.neovide_confirm_quit = true
    vim.g.neovide_remember_window_size = true

    -- --------------------------------------------------------
    -- Presentation scaling
    -- --------------------------------------------------------

    vim.g.neovide_scale_factor = 1.0

    vim.keymap.set("n", "<D-=>", function()
        vim.g.neovide_scale_factor =
            (vim.g.neovide_scale_factor or 1.0) + 0.1
    end, {
        desc = "Increase Neovide presentation scale",
    })

    vim.keymap.set("n", "<D-->", function()
        vim.g.neovide_scale_factor = math.max(
            0.7,
            (vim.g.neovide_scale_factor or 1.0) - 0.1
        )
    end, {
        desc = "Decrease Neovide presentation scale",
    })
