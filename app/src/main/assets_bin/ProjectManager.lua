local ProjectManager={}
setmetatable(ProjectManager,{__index=_ENV})
ProjectManager._ENV=_ENV
local sdPath=AppPath.Sdcard
ProjectManager.projectsPath=nil
ProjectManager.projectsFile=nil
--ProjectManager.openStatus=false--是否已打开项目
--ProjectManager.nowConfig=nil--已打开的项目配置，对应 项目/.aidelua/config.lua文件
local openStatus,nowConfig=false,nil

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

--运行项目
function ProjectManager.runProject(path)
  local code,projectMainFile
  FilesTabManager.saveFiles()
  if nowConfig.packageName then
    local success,err=pcall(function()
      local intent=Intent(Intent.ACTION_VIEW,Uri.parse(nowConfig.projectMainPath))
      local componentName=ComponentName(nowConfig.packageName,nowConfig.debugActivity or "com.androlua.LuaActivity")
      intent.setComponent(componentName)
      activity.startActivity(intent)
    end)
    if not(success) then--无法通过调用其他app打开时
      showSnackBar(R.string.runCode_noApp)
    end
   else
    showSnackBar(R.string.runCode_noPackageName)
  end
end

--打开项目
function ProjectManager.openProject(path)

end

--更新当前项目配置
function updateNowConfig(config)
  --ProjectManager.nowConfig=config
  nowConfig=config
  --做一系列刷新
end
--local updateNowConfig=ProjectManager.updateNowConfig

--关闭项目
function ProjectManager.closeProject()
  FilesTabManager.closeAllFiles()
  --ProjectManager.openStatus=false
  openStatus=false
  updateNowConfig(nil)
end

--截取完整路径的后半，取相对路径
--[[
path: 绝对路径路径
max: 最大字符数，如果max为true，代表无限大
basePath: 当前路径
]]
function ProjectManager.shortPath(path,max,basePath)
  local newPath
  if String(path).startsWith(basePath) then
    newPath=string.sub(path,string.len(basePath)+1)
   else
    newPath=path
  end
  --开始检测字符串是否过长
  if max==true then
    return newPath
  end
  local len=utf8.len(newPath)
  if len>(max or 15) then
    return "..."..utf8.sub(newPath,len-(max or 15)+1,len)
   else
    return newPath
  end
end


return ProjectManager
