--格式化table中的内容}
local function keysTableFormater(key,content)
  if #content==0 then
    content=""
   else
    if key=="appDependencies" then
      content="\n    "..table.concat(content,"\n    ")
     elseif key=="appIncludeLua" then
      content="\""..table.concat(content,"\",\"").."\","
     elseif key=="appInclude" then
      content=",'"..table.concat(content,"','").."'"
     elseif key=="am_application" or key=="am_application_bottom" then
      content="\n"..table.concat(content,"\n\n").."\n"
     elseif key=="defaultImport" then
      content="\nimport \""..table.concat(content,"\"\nimport \"").."\"\n"
     elseif key=="am_welcome_info" then
      content="\n            "..table.concat(content,"\n            ")
    end
  end
  return content
end
return keysTableFormater