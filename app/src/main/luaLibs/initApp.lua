import "android.os.Build"
import "android.os.Environment"

local SDK_INT=Build.VERSION.SDK_INT
if getSharedData("richAnim")==nil then
  if SDK_INT>=28 then
    setSharedData("richAnim",true)
   else
    setSharedData("richAnim",false)
  end
end
if getSharedData("Jesse205Lib_Highlight")==nil then
  setSharedData("Jesse205Lib_Highlight",false)
end
if getSharedData("AndroidX_Highlight")==nil then
  setSharedData("AndroidX_Highlight",true)
end
if getSharedData("editor_magnify")==nil then
  if SDK_INT>=28 then
    setSharedData("editor_magnify",true)
   else
    setSharedData("editor_magnify",false)
  end
end
if getSharedData("editor_previewButton")==nil then
  if SDK_INT>=28 then
    setSharedData("editor_previewButton",true)
   else
    setSharedData("editor_previewButton",false)
  end
end
if getSharedData("editor_symbolBar")==nil then
  setSharedData("editor_symbolBar",true)
end
if getSharedData("tab_icon")==nil then
  setSharedData("tab_icon",true)
end


if getSharedData("projectsDir")==nil then
  setSharedData("projectsDir",Environment.getExternalStorageDirectory().getPath().."/AppProjects")
end
