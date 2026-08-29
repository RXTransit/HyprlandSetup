-- Pin workspaces to monitors

for workspace = 6, 10 do
  hl.workspace_rule({workspace = tostring(workspace),monitor = "HDMI-A-1",persistent = true,})
end
for workspace = 1, 5 do
  hl.workspace_rule({workspace = tostring(workspace),monitor = "HDMI-A-2",persistent = true,})
end
