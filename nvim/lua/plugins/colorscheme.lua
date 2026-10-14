return {
		"catppuccin/nvim",
		name = "catppuccin",
		opts = {
			term_colors = true,
			transparent_background = true,
			styles = {
				comments = {},
				conditionals = {},
				loops = {},
				functions = {},
				keywords = {},
				strings = {},
				variables = {},
				numbers = {},
				booleans = {},
				properties = {},
				types = {},
			},
			color_overrides = {
				mocha = {
					mantle = "#000000",
					base = "#000000",
				},
				latte = {
					mantle = "#FFFFFF",
					base = "#FFFFFF",
				}
			},
			integrations = {
				fzf = {
					enabled = true,
				},
				dropbar = {
					enabled = true,
					color_mode = true,
				},
			},
		},
	}
