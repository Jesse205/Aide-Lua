--module(...,package.seeall)
local ProjectUtil={}
import "Jesse205"
import "ReBuildTool"

ProjectUtil.SdPath=AppPath.Sdcard

xpcall(function()--防呆设计
  ProjectUtil.ProjectsPath=getSharedData("projectsDir")--所有项目路径
  ProjectUtil.ProjectsFile=File(ProjectUtil.ProjectsPath)
  ProjectUtil.ProjectsPath=ProjectUtil.ProjectsFile.getPath()--修复一下路径
end,
function()--手贱乱输造成报错
  ProjectUtil.ProjectsPath=ProjectUtil.SdPath.."/AppProjects"
  ProjectUtil.ProjectsFile=File(ProjectUtil.ProjectsPath)
  setSharedData("projectsDir",ProjectUtil.ProjectsFile)
  MyToast("项目路径出错，已为您恢复默认设置")
end)

ProjectUtil.FileIcons={--各种文件的图标
  lua=R.drawable.ic_language_lua,
  luac=R.drawable.ic_language_lua,
  aly=R.drawable.ic_language_lua,
  xml=R.drawable.ic_xml,
  json=R.drawable.ic_code_json,
  java=R.drawable.ic_language_java,
  html=R.drawable.ic_language_html5,
  htm=R.drawable.ic_language_html5,
  txt=R.drawable.ic_file_document_outline,
  zip=R.drawable.ic_zip_box_outline,
  rar=R.drawable.ic_zip_box_outline,
  ["7z"]=R.drawable.ic_zip_box_outline,
  pdf=R.drawable.ic_file_pdf_box_outline,
  ppt=R.drawable.ic_file_powerpoint_box_outline,
  pptx=R.drawable.ic_file_powerpoint_box_outline,
  doc=R.drawable.ic_file_word_box_outline,
  docx=R.drawable.ic_file_word_box_outline,
  xls=R.drawable.ic_file_table_box_outline,
  xlsx=R.drawable.ic_file_table_box_outline,
  png=R.drawable.ic_image_outline,
  jpg=R.drawable.ic_image_outline,
  gif=R.drawable.ic_image_outline,
  jpeg=R.drawable.ic_image_outline,
  svg=R.drawable.ic_image_outline,
  apk=R.drawable.ic_android_debug_bridge,
  py=R.drawable.ic_language_python,
  pyw=R.drawable.ic_language_python,
  pyc=R.drawable.ic_language_python,

}
ProjectUtil.FolderIconsByName={
  build=R.drawable.ic_folder_cog_outline,
  gradle=R.drawable.ic_folder_cog_outline,
  [".gradle"]=R.drawable.ic_folder_cog_outline,
  [".idea"]=R.drawable.ic_folder_cog_outline,
  [".aidelua"]=R.drawable.ic_folder_cog_outline,
  res=R.drawable.ic_folder_table_outline,
  assets=R.drawable.ic_folder_zip_outline,
  assets_bin=R.drawable.ic_folder_zip_outline,
  key=R.drawable.ic_folder_key_outline,
  keys=R.drawable.ic_folder_key_outline,
}

ProjectUtil.TextFileType={lua=true,aly=true,html=true,xml=true,java=true,py=true,pyw=true,txt=true,gradle=true,bat=true,json=true,svg=true}
ProjectUtil.CallCodeFileType={lua=true,aly=true,java=true,py=true,pyw=true}
ProjectUtil.SupportPreviewType={xml=true,aly=true,svg=true}

ProjectUtil.HideFiles={
  gradlew=true,
  ["gradlew.bat"]=true,
  ["luajava-license.txt"]=true,
  ["lua-license.txt"]=true,
  [".gitignore"]=true,
  gradle=true,
  build=true,
  ["init.lua"]=true,
  libs=true,
  cache=true,
  caches=true,
}

ProjectUtil.LibsRelativePathMatch={
  "^.-/src/main/assets_bin/(.+)%.",
  "^.-/src/main/luaLibs/(.+)%.",
  "^.-/src/main/jniLibs/.-/lib(.+)%.so",
  "^.-/src/main/java/(.+)%.",
  "^.-/src/main/assets/(.+)%.",
}
ProjectUtil.LibsRelativePathType={
  java=true,
  so=true,
  lua=true,
  luac=true,
  aly=true,
}


function ProjectUtil.shortPath(path,max,basePath)
  if OpenedProject then
    basePath=basePath or NowProjectDirectory.getPath()
  end
  basePath=basePath or ""
  if String(path).startsWith(basePath) then

    local projectPath
    if basePath then
      projectPath=string.sub(path,string.len(basePath)+1)
    end
    local relPath=(projectPath or path)
    if max==true then
      return relPath
    end

    local len=utf8.len(relPath)
    if len>(max or 15) then
      return "..."..utf8.sub(relPath,len-(max or 15)+1,len)
     else
      return relPath
    end
   else
    return path
  end
  --else
  --return ""
  --end

end


function ProjectUtil.getProjectIconForGlide(projectPath,config)
  local mainProjectPath=ReBuildTool.getMainProjectDirByConfig(projectPath,config)
  local adaptiveIcon--自适应图标
  --判断是不是table类型，如果是则进行夜间判断，如果是字符串则直接赋值
  if type(config.icon)=="table" then
    if ThemeUtil.NowAppTheme.night then
      adaptiveIcon=rel2AbsPath(config.icon.night,projectPath)
     else
      adaptiveIcon=rel2AbsPath(config.icon.day or config.icon.night,projectPath)
    end
   else
    adaptiveIcon=rel2AbsPath(config.icon,projectPath)
  end

  local icon=android.R.drawable.sym_def_app_icon
  --图标可能存在的目录
  local icons={
    adaptiveIcon,
    projectPath.."/ic_launcher-aidelua.png",
    projectPath.."/ic_launcher-playstore.png",
    mainProjectPath.."/ic_launcher-aidelua.png",
    mainProjectPath.."/ic_launcher-playstore.png",
    mainProjectPath.."/res/mipmap-xxxhdpi/ic_launcher_round.png",
    mainProjectPath.."/res/mipmap-xxxhdpi/ic_launcher.png",
    mainProjectPath.."/res/drawable/ic_launcher.png",
    mainProjectPath.."/res/drawable/icon.png",
  }
  for index,content in pairs(icons) do
    if content and File(content).isFile() then
      icon=content
      break--有图标，停止循环
    end
  end
  return icon
end

function ProjectUtil.getFileIconResIdByType(fileType)
  local icon=R.drawable.ic_file_outline
  if fileType then
    icon=ProjectUtil.FileIcons[fileType] or icon
  end
  return icon
end

function ProjectUtil.getFolderIconResIdByName(name)
  return ProjectUtil.FolderIconsByName[name] or R.drawable.ic_folder_outline
end


function ProjectUtil.getFileTypeByName(name)
  local _type=name:match(".+%.(.+)")
  if _type then
    return string.lower(_type)
  end
end


function ProjectUtil.isSelfFile(file1,file2)
  return string.lower(file1.getPath())==string.lower(file2.getPath())
end

function ProjectUtil.isTextFile(fileType)
  return ProjectUtil.TextFileType[fileType]
end



function ProjectUtil.isHideFile(fileName)
  return toboolean(ProjectUtil.HideFiles[fileName] or fileName:find("^%."))
end

local HideFileBoolean2Alpha={
  ["true"]=0.5,
  ["false"]=1
}
function ProjectUtil.getIconAlphaByFileName(fileName)
  return HideFileBoolean2Alpha[tostring(ProjectUtil.isHideFile(fileName))]
end

return ProjectUtil