local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- Create a single, persistent item that represents the active workspace
local active_space = sbar.add("item", "active_space", {
  icon = {
    font = { family = settings.font.numbers },
    padding_left = 15, padding_right = 8,
    color = colors.white,
  },
  label = {
    padding_right = 20,
    color = colors.grey,
    font = "sketchybar-app-font:Regular:16.0",
    y_offset = -1,
  },
  background = {
    color = colors.bg1,
    border_width = 1,
    height = 26,
    border_color = colors.black,
  }
})

-- Update the item based on the active workspace and its windows
local function updateActiveSpace(workspace_name)
  -- Get apps for this workspace
  local get_windows = "aerospace list-windows --workspace " .. workspace_name .. " --format '%{app-name}' --json"
  sbar.exec(get_windows, function(windows)
    local icon_line = ""
    if #windows == 0 then
      icon_line = " —"
    else
      local processed = {}
      for _, entry in ipairs(windows) do
        local app = entry["app-name"]
        if not processed[app] then
          local lookup = app_icons[app]
          icon_line = icon_line .. ((lookup == nil) and app_icons["Default"] or lookup)
          processed[app] = true
        end
      end
    end
    
    active_space:set({
      icon = { string = workspace_name },
      label = { string = icon_line }
    })
  end)
end

-- Listen for workspace changes
local workspace_observer = sbar.add("item", { drawing = false, updates = true })
workspace_observer:subscribe("aerospace_workspace_change", function(env)
  updateActiveSpace(env.FOCUSED_WORKSPACE)
end)

-- Initial state
sbar.exec("aerospace list-workspaces --focused", function(ws)
  updateActiveSpace(ws:gsub("%s+", ""))
end)

-- (Keep your existing spaces_indicator and mouse event code here)
