local ProjectManager={}
ProjectManager._ENV=_ENV
local sdPath=AppPath.Sdcard
ProjectManager.projectsPath=nil
ProjectManager.projectsFile=nil
ProjectManager.openedProject=false
local openedProject=false

xpcall(function()--防呆设计
  ProjectManager.projectsPath=getSharedData("projectsDir")--所有项目路径
  ProjectManager.projectsFile=File(ProjectManager.projectsPath)
  ProjectManager.projectsPath=ProjectManager.projectsFile.getPath()--修复一下路径
end,
function()--手贱乱输造成报错
  ProjectManager.projectsPath=sdPath.."/AppProjects"
  ProjectManager.projectsFile=File(ProjectManager.projectsPath)
  setSharedData("projectsDir",ProjectManager.projectsPath)
  MyToast("项目路径出错，已为您恢复默认设置")
end)

function ProjectManager.runProject(path)
  local code,projectMainFile
  code=EditorsManager.actions.getText()
  if openedProject then--打开了工程
    local projectPath=NowProjectDirectory.getPath()
    FilesTabManager.saveFiles()
    --[[
    if configFile.isFile() then--如果有文件
      local config=ReBuildTool.getConfigByFilePath(configPath)
      local projectMainPath=path or ReBuildTool.getMainProjectDirByConfig(projectPath,config).."/assets_bin/main.lua"
      projectMainFile=File(projectMainPath)
]]
    if config.packageName then--如果可以使用另一个他自己打开就是用他自己，不能的话使用IDE
      local success,err=pcall(function()
        local intent=Intent(Intent.ACTION_VIEW,Uri.parse(projectMainPath))
        local componentName=ComponentName(config.packageName,config.debugActivity or "com.androlua.LuaActivity")
        intent.setComponent(componentName)
        activity.startActivity(intent)
      end)
      if not(success) then--无法通过调用其他app打开时
        showSnackBar(R.string.runCode_noApp)
      end
     else
      showSnackBar(R.string.runCode_noPackageName)
    end
    --end
   else
    if path then
      projectMainFile=File(path)
    end
    runLuaFile(projectMainFile,code)
  end
end

function ProjectManager.openProject(path)
end

function ProjectManager.closeProject()
  ProjectManager.openedProject=false
  openedProject=false
end

function ProjectManager.shortPath(path,max,basePath)
  if ProjectManager.openedProject and String(path).startsWith(basePath) then
    basePath=basePath or ProjectManager.projectsFile.getPath()
    local projectPath
    local relPath=string.sub(path,string.len(basePath)+1)
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
end


return ProjectManager
