--module(...,package.seeall)
local ReBuildToolInit={}
setmetatable(ReBuildToolInit,ReBuildToolInit)

import "Jesse205"
ReBuildToolInit.ReBuildToolList=require "ReBuildTool.buildToolList"

--通过文件路径获取config(实质上是加载了文件)
function ReBuildToolInit.getConfigByFilePath(path)
  return getConfigFromFile(path)
end

if ReBuildTool then
  ReBuildToolInit.ReBuildToolList[ReBuildTool.ToolInformation.version]=ReBuildTool
 else
  --加载所有ReBuildTool
  for index,content in pairs(ReBuildToolInit.ReBuildToolList) do
    ReBuildToolInit.ReBuildToolList[index]=ReBuildToolInit.getConfigByFilePath(activity.getLuaPath("ReBuildTool/"..content))
  end
end

--通过项目目录获取.AideLua路径
function ReBuildToolInit.getAideLuaPathByProjectDir(projectDir)
  return ("%s/.aidelua"):format(projectDir)
end

--通过.AideLua路径获取config.lua路径
function ReBuildToolInit.getConfigPathByAideLuaDir(aideluaDir)
  return ("%s/config.lua"):format(aideluaDir)
end

--通过项目目录路径获取config
function ReBuildToolInit.getConfigByProjectDir(projectDir)
  local aideluaDir=ReBuildToolInit.getAideLuaPathByProjectDir(projectDir)
  local path=ReBuildToolInit.getConfigPathByAideLuaDir(aideluaDir)
  return ReBuildToolInit.getConfigByFilePath(path)
end


--通过项目名字获取主项目路径
function ReBuildToolInit.getProjectDir(projectDir,name)
  return ("%s/%s/src/main"):format(projectDir,name)
end

--通过工程路径获取.aidelua/config.lua路径
function ReBuildToolInit.getConfigPathByProjectDir(projectDir)
  return ReBuildToolInit.getConfigPathByAideLuaDir(ReBuildToolInit.getAideLuaPathByProjectDir(projectDir))
end
--[[
function getConfigFromFile(file)
  return getConfigFromFileByPath(file.getPath())
end]]

--通过工程路径获取.aidelua/config.lua的Config
function ReBuildToolInit.getConfigByProjectDir(projectDir)
  return ReBuildToolInit.getConfigByFilePath(ReBuildToolInit.getConfigPathByProjectDir(projectDir))
end


--通过Config获取工程所需二次打包工具版本
function ReBuildToolInit.getProjectReBuildToolVersion(config)
  if config.tool then
    return config.tool.version or "1.0"--万一里面没版本呢
   else
    return "1.0"--没有就返回1.0，为了兼容旧版本工程
  end
end

--通过版本获取ReBuildTool
function ReBuildToolInit.getReBuildToolByVersion(version)
  local reBuildTool=ReBuildToolInit.ReBuildToolList[version]
  if not(reBuildTool) then
    error(activity.getString(R.string.binpoject_cannotFindTool))
  end
  return reBuildTool
end

--通过Config获取ReBuildTool
function ReBuildToolInit.getReBuildToolByConfig(config)
  local toolVersion=ReBuildToolInit.getProjectReBuildToolVersion(config)
  local reBuildTool=ReBuildToolInit.getReBuildToolByVersion(toolVersion)
  return reBuildTool
end

--通过Config获取主项目名字
function ReBuildToolInit.getMainProjectName(config)
  local reBuildTool=ReBuildToolInit.getReBuildToolByConfig(config)
  local name=reBuildTool.getMainProjectName(config)
  return name
end

--通过Config获取主项目路径
function ReBuildToolInit.getMainProjectDirByConfig(projectDir,config)
  return ReBuildToolInit.getProjectDir(projectDir,ReBuildToolInit.getMainProjectName(config))
end

--二次打包log
local function buildProject_update(message)
  showLoadingDia(message)
end

--二次打包回调
local function buildProject_callback(success,apkPath,projectDir,install)
  closeLoadingDia()
  local showingText=""
  if success==true then
    local shortApkPath=activity.getString(R.string.project)..ProjectUtil.shortPath(apkPath,true,projectDir)--转换成相对路径
    if install then
      activity.installApk(apkPath)
      showingText=formatResStr(R.string.binpoject_state_succeed,{shortApkPath})
     else
      showingText=formatResStr(R.string.binpoject_state_succeed_needSign,{shortApkPath})
    end
    showSnackBar(showingText)
   else
    showingText=success or activity.getString(R.string.unknowError)
    AlertDialog.Builder(this)
    .setTitle(activity.getString(R.string.binpoject_state_failed))
    .setMessage(showingText)
    .setPositiveButton(android.R.string.ok,nil)
    .show()
  end
  if activityStopped then
    MyToast.showToast(showingText)
  end
end

--二次打包
--[[
projectDir：项目路径
install：自动签名与安装
]]
function ReBuildToolInit.buildProject(projectDir,install)
  local config=ReBuildToolInit.getConfigByProjectDir(projectDir)
  local reBuildTool=ReBuildToolInit.getReBuildToolByConfig(config)
  --print(dump(reBuildTool))
  showLoadingDia(nil,R.string.binpoject_loading)
  activity.newTask(reBuildTool.buildProject,buildProject_update,buildProject_callback).execute({projectDir,config,reBuildTool,install})
end

--二次打包
function ReBuildToolInit.__call(self,projectDir,install)
  ReBuildToolInit.buildProject(projectDir,install)
end
return ReBuildToolInit