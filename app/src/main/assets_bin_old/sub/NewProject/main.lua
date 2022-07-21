require "import"
import "Jesse205"
import "com.google.android.material.chip.ChipGroup"
import "com.google.android.material.chip.Chip"

import "NewProject"
TemplatesDir=activity.getLuaDir("../../templates")--模板路径
BaseTemplateConfig=getConfigFromFile(TemplatesDir.."/baseTemplate/config.lua")

NotAllowStr={"/","\\",":","*","\"","<",">","|","?","%."}--不允许出现的文字

ProjectsPath=getSharedData("projectsDir")--项目路径

--默认的Key
defaultKeys=getConfigFromFile(TemplatesDir.."/default.lua")
openedCLibs={}
openedJarLibs={}
openedSLibs={}
libChips={}

activity.setTitle(R.string.app_name)
activity.setContentView(loadlayout2("layout"))
actionBar.setDisplayHomeAsUpEnabled(true)

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
end

function onChipCheckChanged(view,isChecked,libs)
  local config=view.tag
  local viewIndex=config.viewIndex
  if view.isEnabled() then
    setSharedData("newproject_"..config.path,isChecked)
    config.checked=isChecked
  end
  if isChecked then
    libs[viewIndex]=config
   else
    libs[viewIndex]=nil
  end
end

function onComplexLibrariesCheckChanged(view,isChecked)
  onChipCheckChanged(view,isChecked,openedCLibs)
end

function onJarLibCheckChanged(view,isChecked)
  onChipCheckChanged(view,isChecked,openedJarLibs)
end

function onSLibCheckChanged(view,isChecked)
  onChipCheckChanged(view,isChecked,openedSLibs)
end


--添加版本选择Chip
function addVerChip(config,group,key)
  local title=config[1]
  local chip=loadlayout2({
    Chip;
    text=title;
    tag=config;
    id=title;
    checkable=true;
    checkedIconEnabled=false;
    --checkedIconResource=R.drawable.ic_mtrl_chip_checked_black;
    --checkedIconVisible=false;
  },{})
  group.addView(chip)
  if activity.getSharedData("newproject_"..key)==title then
    _G[key]=config
    chip.setChecked(true)
    _G[key.."SelectedId"]=chip.getId()
  end
  return chip
end

--添加库Chip
function addLibChip(title,config,group)
  local chip=loadlayout2({
    Chip;
    text=title;
    tag=config;
    checkable=true;
    checkedIconResource=R.drawable.ic_check_accent;
  })
  group.addView(chip)
  local onCheckedChanged=config.onCheckedChanged
  --chip.onLongClick=removeLibDialog
  chip.setOnCheckedChangeListener{onCheckedChanged=onCheckedChanged}
  if getSharedData("newproject_"..config.path) then
    chip.setChecked(true)
    onCheckedChanged(chip,true)
  end
  config.chip=chip
  table.insert(libChips,config)
  return chip
end

function refreshState(refreshType,state)
  local notState=not(state)
  if refreshType=="androidx" then
    for index,content in ipairs(libChips) do
      local support=content.support
      local chip=content.chip
      if (support=="androidx" and state) or (support=="normal" and notState) then
        chip.setEnabled(true)
        .setChecked(content.checked or false)
       elseif (support=="androidx" and notState) or (support=="normal" and state) then
        chip.setEnabled(false)
        .setChecked(false)
      end
    end
  end
end

--整合keys
function buildkeys()
  local keys=table.clone(defaultKeys)
  local keysLists={}
  local pluginsList={}
  local androidX=androidXSwitch.isChecked()

  for index,content in pairs(openedCLibs) do
    table.insert(keysLists,content.keys)
    table.insert(pluginsList,index)
  end

  for index,content in pairs(keysLists) do--遍历列表
    for index,content in pairs(content) do--遍历Keys
      local oldContentList=keys[index]
      local _type=type(oldContentList)
      if _type=="table" then
        for index,content in ipairs(content) do
          table.insert(oldContentList,content)
        end--将新的值追加到原列表
       else
        keys[index]=content--覆盖原有值
      end
    end
  end
  keys.androidX=androidX
  keys.appName=appNameEdit.text
  keys.appPackageName=packageNameEdit.text
  keys.androluaVersion=androluaVersion[1]
  keys.androluaVersionCode=androluaVersion[2]

  return keys
end


local androluaVersions=BaseTemplateConfig.androluaVersions
if getSharedData("newproject_androluaVersion")==nil then
  setSharedData("newproject_androluaVersion",androluaVersions[#androluaVersions][1])
end

--Androlua版本
for index,content in ipairs(androluaVersions) do
  addVerChip(content,androluaVersionsGroup,"androluaVersion")
end

--复杂库
for viewIndex,content in ipairs(luajava.astable(File(TemplatesDir.."/complexLibraries").listFiles())) do
  if content.isDirectory() then
    for index,content in ipairs(luajava.astable(content.listFiles())) do
      if content.isDirectory() then
        local path=content.getPath()
        local config=getConfigFromFile(path.."/config.lua")
        config.path=path
        config.viewIndex=viewIndex
        config.onCheckedChanged=onComplexLibrariesCheckChanged
        addLibChip(("%s (%s)"):format(config.name,content.getName()),config,complexLibrariesGroup)
      end
    end
  end
end

--Jar库
for viewIndex,libraryFile in ipairs(luajava.astable(File(TemplatesDir.."/jarLibraries").listFiles())) do
  if libraryFile.isDirectory() then
    for index,content in ipairs(luajava.astable(libraryFile.listFiles())) do
      if content.isDirectory() then
        local path=content.getPath()
        local config={}
        config.path=path
        config.file=content
        config.viewIndex=viewIndex
        config.onCheckedChanged=onJarLibCheckChanged
        config.support="all"
        addLibChip(("%s (%s)"):format(libraryFile.getName(),content.getName()),config,jarLibrariesGroup)
      end
    end
  end
end

--简单库
for viewIndex,content in ipairs(luajava.astable(File(TemplatesDir.."/simpleLibraries").listFiles())) do
  if content.isDirectory() then
    local config={}
    local path=content.getPath()
    config.path=path
    config.viewIndex=viewIndex
    config.onCheckedChanged=onSLibCheckChanged
    config.support="all"
    addLibChip(content.getName(),config,simpleLibrariesGroup)
  end
end



androluaVersionsGroup.setOnCheckedChangeListener{
  onCheckedChanged=function(chipGroup, selectedId)
    --print(selectedId)
    if selectedId==-1 and androluaVersionSelectedId then
      local chip=chipGroup.findViewById(androluaVersionSelectedId)
      chip.setChecked(true)
      return
     else
      local chip=chipGroup.findViewById(selectedId)
      if chip then
        local config=chip.tag
        setSharedData("newproject_androluaVersion",config[1])
        androluaVersion=config
        androluaVersionSelectedId=selectedId
        return
      end
    end
    androluaVersion=nil
    androluaVersionSelectedId=nil
  end
}

noButton.onClick=function()--取消按钮
  activity.finish()
end

creativeButton.onClick=function()--新建按钮
  local keys=buildkeys()

  local appName=keys.appName--软件名
  local folderName=appName
  for index,content in ipairs(NotAllowStr) do
    folderName=folderName:gsub(content,"")
  end
  local projectPath=ProjectsPath.."/"..folderName
  if appName=="" then--软件名不能为空
    appNameLay
    .setError(cannotBeEmptyStr)
    .setErrorEnabled(true)
    return
   elseif File(projectPath).exists() then
    appNameLay
    .setError(activity.getString(R.string.project_exists))
    .setErrorEnabled(true)
    return
   else
    appNameLay.setErrorEnabled(false)
  end

  if keys.appPackageName=="" then--包名不能为空
    packageNameLay
    .setError(cannotBeEmptyStr)
    .setErrorEnabled(true)
    return
   else
    packageNameLay.setErrorEnabled(false)
  end

  if not(androluaVersion) then--必须选择一个Androlua版本
    MyToast("请选择一个AndroLua版本")
    return
  end
  AlertDialog.Builder(this)
  .setTitle(activity.getString(R.string.reminder))
  .setMessage(activity.getString(R.string.project_create_tip))
  .setPositiveButton(R.string.create,function()
    showLoadingDia(nil,R.string.creating)
    activity.newTask(NewProject.newProject,NewProject.update,NewProject.callback).execute({keys,BaseTemplateConfig,projectPath,TemplatesDir,openedSLibs,openedJarLibs,openedCLibs})
  end)
  .setNegativeButton(android.R.string.cancel,nil)
  .show()
end

--应用名与包名
appNameEdit.setText(defaultKeys.appName)
packageNameEdit.setText(defaultKeys.appPackageName)
local newproject_androidXSwitch=getSharedData("newproject_androidXSwitch")
local androidxState
if newproject_androidXSwitch~=nil then
  androidxState=newproject_androidXSwitch
 else
  androidxState=defaultKeys.androidX
end
androidXSwitch.setChecked(androidxState)
refreshState("androidx",androidxState)
androidxState=nil

androidXSwitchParent.onClick=function()
  local nowState=androidXSwitch.isChecked()
  local newState=not(nowState)
  androidXSwitch.setChecked(newState)
  setSharedData("newproject_androidXSwitch",newState)
  refreshState("androidx",newState)
end

--自动查空
appNameEdit.addTextChangedListener({
  onTextChanged=function(text,start,before,count)
    text=tostring(text)
    if text=="" then--文件夹名不能为空
      appNameLay
      .setError(cannotBeEmptyStr)
      .setErrorEnabled(true)
      return
    end
    appNameLay.setErrorEnabled(false)
  end
})

packageNameEdit.addTextChangedListener({
  onTextChanged=function(text,start,before,count)
    text=tostring(text)
    if text=="" then--文件夹名不能为空
      packageNameLay
      .setError(cannotBeEmptyStr)
      .setErrorEnabled(true)
      return
    end
    packageNameLay.setErrorEnabled(false)
  end
})

screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({

})

onConfigurationChanged(activity.getResources().getConfiguration())

