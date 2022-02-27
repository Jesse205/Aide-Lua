local PluginsUtil={}
local plugins

local activityName,appPluginsDir,appPluginsDataDir
local setEnabled,getEnabled,loadPlugins,getPluginDir,getAvailable

local PackInfo=activity.PackageManager.getPackageInfo(activity.getPackageName(),64)
local versionCode=PackInfo.versionCode

function PluginsUtil.callElevents(name,...)
  if activityName then
    if plugins==nil then
      loadPlugins()
    end
    local events=plugins.events[name]
    if events then
      for index,content in ipairs(events) do
        local callback={xpcall(content,function(err)
            print("Plugin",plugins.eventsName[name][index],"error: ",err)
        end,activityName,...)}
        table.remove(callback,1)
        if #callback>=0 then
          return table.unpack(callback)
        end
      end
    end
  end
  return PluginsUtil
end

function PluginsUtil.setPlugins(newPlugins)
  plugins=newPlugins
  return PluginsUtil
end

function PluginsUtil.setActivityName(name)--设置活动标识，否则无法加载插件
  activityName=name
  return PluginsUtil
end

function setEnabled(packageName,state,ver)
  setSharedData("plugin_"..packageName.."_enabled_"..(ver or "default"),state)
  return PluginsUtil
end
PluginsUtil.setEnabled=setEnabled

function getEnabled(packageName,ver)
  local state=getSharedData("plugin_"..packageName.."_enabled_"..(ver or "default"))
  if state==nil and ver==nil then
    setEnabled(packageName,true)
    return true
   else
    return state
  end
end
PluginsUtil.getEnabled=getEnabled

function PluginsUtil.getDataDir(packageName)--获取插件数据目录
  return appPluginsDir.."/"..packageName
end

function getPluginDir(packageName)--获取插件目录，如果文件夹名与真正的packageName请手动输入文件夹名
  return appPluginsDataDir.."/"..packageName
end
PluginsUtil.appPluginsDataDir=appPluginsDataDir

function getAvailable(packageName)--获取另一个插件是否可用
  local path=getPluginDir(packageName)
  if not(File(path).isDirectory()) then
    return false
  end
  return getEnabled(packageName)
end
PluginsUtil.getAvailable=getAvailable

function loadPlugins()
  appPluginsDir=AppPath.AppShareDir.."/plugins"
  appPluginsDataDir=AppPath.AppShareDir.."/data/plugins"
  AppPath.AppPluginsDir=appPluginsDir
  AppPath.AppPluginsDataDir=appPluginsDataDir

  plugins={}
  local pluginsEvents={}
  local pluginsEventsName={}
  local pluginsActivitys={}
  local pluginsActivitysName={}
  plugins.events=pluginsEvents
  plugins.eventsName=pluginsEventsName
  plugins.activitys=pluginsActivitys
  plugins.activitysName=pluginsActivitysName

  local pluginsFile=File(appPluginsDir)
  if pluginsFile.exists() then--存在插件文件夹
    local fileList=pluginsFile.listFiles()
    for index=0,#fileList-1 do
      local file=fileList[index]
      local path=file.getPath()
      local dirName=file.getName()

      if getEnabled(dirName) then--检测是否开启

        local initPath=path.."/init.lua"
        local mainPath="/main.lua"
        if File(initPath).isFile() then--存在init.lua
          xpcall(function()
            local config=getConfigFromFile(initPath,config)--init.lua内容
            setmetatable(config,{__index=function(self,key)--设置环境变量
                return _G[key]
              end
            })
            local minVerCode=config.mineditorcode
            local targetVerCode=config.targeteditorcode
            if (minVerCode<=versionCode) and (targetVerCode>=targetVerCode or getEnabled(dirName,versionCode)) then--版本号在允许的范围之内或者强制启用
              local thirdPlugins=config.thirdplugins
              local err=false
              if thirdPlugins then
                for index,content in ipairs(thirdPlugins) do
                  if not(getAvailable(content)) then
                    print("Plugin",dirName,"error: Plugin",content,"not found.")
                    err=true
                  end
                end
              end
              if err==false then
                local fileEvents=config.events
                local name=("%s(%s)"):format(config.appname,config.packagename)
                for index,content in pairs(fileEvents) do
                  local eventsList=pluginsEvents[index]
                  local eventsNameList=pluginsEventsName[index]
                  if eventsList==nil then
                    eventsList={}
                    eventsNameList={}
                    pluginsEvents[index]=eventsList
                    pluginsEventsName[index]=eventsNameList
                  end
                  table.insert(eventsList,content)
                  table.insert(eventsNameList,name)
                end

                if File(mainPath).isFile() then--可以使用单独的页面打开
                  table.insert(pluginsActivitys,mainPath)
                  table.insert(pluginsActivitysName,config.appname)
                end
              end

            end

          end,
          function(err)--语法错误，或者其他问题
            print("Plugin",dirName,"error: ",err)
          end)
         else--init.lua不存在
          print("Plugin",dirName,"error: init.lua missing.")
        end
      end
    end

  end
  return PluginsUtil
end
PluginsUtil.loadPlugins=loadPlugins

return PluginsUtil
