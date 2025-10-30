return {
  {
    'nvim-mini/mini.cursorword',
    version = false,
    event = "VeryLazy",
    opts = {}
  },
  {
    'nvim-mini/mini.comment',
    version = false,
    event = "VeryLazy",
    opts = {}
  },
  {
    'nvim-mini/mini.ai',
    version = false,
    event = "VeryLazy",
    opts = {}
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {}
  },
  {
    'nacro90/numb.nvim',
    event = "VeryLazy",
    config = function()
      require('numb').setup()
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "^3.0.0", 
    event = "VeryLazy",
    opts = {}
  },
  {
    'andymass/vim-matchup',
    event = "VeryLazy",
    ---@type matchup.Config
    opts = {
      treesitter = {
        stopline = 500,
      }
    }
  },
}
