return {
  "neoclide/coc.nvim",
  branch = "release",
  -- Optional: Lazy load on specific events like file reading
  event = { "BufReadPre", "BufNewFile" },
  -- Ensure dependencies are installed and compiled
  build = ":CocInstall"
}   
