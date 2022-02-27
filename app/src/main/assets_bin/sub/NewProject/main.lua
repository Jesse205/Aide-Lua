require "import"
import "Jesse205"
import "com.google.android.material.chip.ChipGroup"
import "com.google.android.material.chip.Chip"

TemplatesDir=activity.getLuaDir("../../templates")
BaseTemplateDirPath=TemplatesDir.."/baseTemplate"
BaseTemplatePath=BaseTemplateDirPath.."/baseTemplates.zip"
BaseTemplateConfig=getConfigFromFile(BaseTemplateDirPath.."/config.lua")

NotAllowStr={"/","\\",":","*","\"","<",">","|","?","%."}--不允许出现的文字

ProjectsPath=getSharedData("projectsDir")
androluaVersion=nil
--[[
OpenedCLibs=getSharedData("newproject_openedCLibs") or {}
OpenedJarLibs=getSharedData("newproject_openedJarLibs") or {}
OpenedSLibs=getSharedData("newproject_openedSLibs") or {}
]]
OpenedCLibs={}
OpenedJarLibs={}
OpenedSLibs={}


local cannotBeEmptyStr=activity.getString(R.string.Jesse205_edit_error_cannotBeEmpty)

activity.setTitle(R.string.project_create)
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
  setSharedData("newproject_"..config.path,isChecked)
  if isChecked then
    libs[viewIndex]=config
   else
    libs[viewIndex]=nil
  end
end

function onComplexLibrariesCheckChanged(view,isChecked)
  onChipCheckChanged(view,isChecked,OpenedCLibs)
end

function onJarLibCheckChanged(view,isChecked)
  onChipCheckChanged(view,isChecked,OpenedJarLibs)
end

function onSLibCheckChanged(view,isChecked)
  onChipCheckChanged(view,isChecked,OpenedSLibs)
end

function addChip(title,config,group)
  local chip=loadlayout2({
    Chip;
    text=title;
    tag=config;
    checkable=true;
    checkedIconResource=R.drawable.ic_check_accent;
    --style=R.style.Widget_MaterialComponents_Chip_Choice;
  })
  group.addView(chip)
  local onCheckedChanged=config.onCheckedChanged
  chip.onLongClick=removeLibDialog
  chip.setOnCheckedChangeListener{onCheckedChanged=onCheckedChanged}
  if getSharedData("newproject_"..config.path) then
    chip.setChecked(true)
    onCheckedChanged(chip,true)
  end
end

function addChoiceChip(title,group,identification)
  local chip=loadlayout2({
    Chip;
    text=title;
    --tag=config;
    id=title;
    checkable=true;
    checkedIconEnabled=false;
    --checkedIconResource=R.drawable.ic_mtrl_chip_checked_black;
    --checkedIconVisible=false;
  },{})
  group.addView(chip)
  if activity.getSharedData("newproject_"..identification)==title then
    _G[identification]=title
    chip.setChecked(true)
    _G[identification.."SelectedId"]=chip.getId()
  end
end

function removeLibDialog(view)
  local config=view.tag
  local onCheckedChanged=config.onCheckedChanged
  if onCheckedChanged and (config.file or config.path) then
    AlertDialog.Builder(this)
    .setTitle(formatResStr(R.string.delete_withName,{view.text}))
    .setMessage(activity.getString(R.string.delete_warning))
    .setPositiveButton(android.R.string.ok,function()
      local succeed=LuaUtil.rmDir(config.file or File(config.path))
      if succeed then
        MyToast(R.string.delete_succeed)
        onCheckedChanged(view,false)
        view.getParent().removeView(view)
       else
        MyToast(R.string.delete_failed)
      end
    end)
    .setNegativeButton(android.R.string.no,nil)
    .show()
  end
end

function buildkeys()--整合keys
  local keys=table.clone(defaultKeys)
  local keysLists={}
  local pluginsList={}
  local androidX=androidXSwitch.isChecked()

  for index,content in pairs(OpenedCLibs) do
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
  keys.androluaVersion=androluaVersion
  return keys
end

function newProject(keys,BaseTemplateConfig,projectPath,TemplatesDir,BaseTemplateDirPath,BaseTemplatePath,OpenedSLibs,OpenedJarLibs,OpenedCLibs)
  require "import"
  import "java.io.File"
  import "java.io.FileInputStream"
  import "java.io.FileOutputStream"
  import "net.lingala.zip4j.ZipFile"

  import "com.Jesse205.util.FileUtil"

  this.update(activity.getString(R.string.project_create_gathering))

  keys=luajava.astable(keys,true)
  BaseTemplateConfig=luajava.astable(BaseTemplateConfig,true)
  OpenedSLibs=luajava.astable(OpenedSLibs,true)--勾选的简单库
  OpenedJarLibs=luajava.astable(OpenedJarLibs,true)--勾选的Jar
  OpenedCLibs=luajava.astable(OpenedCLibs,true)--勾选的复杂库

  local formatFilesList=BaseTemplateConfig.format

  local androidX=keys.androidX
  local androluaVersion=keys.androluaVersion

  --各种路径
  local mainProjectPath=projectPath.."/app/src/main"
  local mainLibsPath=projectPath.."/app/libs"
  local mainLibsFile=File(mainLibsPath)
  local androluaTemplatePath=BaseTemplateDirPath.."/androluaTemplate/"..androluaVersion
  local androluaBaseTemplatePath=androluaTemplatePath.."/baseTemplate.zip"
  local appTemplatePath=BaseTemplateDirPath.."/appTemplate/"..BaseTemplateConfig.appVersions[1]
  if androidX then
    androluaTemplatePath=androluaTemplatePath.."/AndroidX.zip"
    appTemplatePath=appTemplatePath.."/AndroidX.zip"
   else
    androluaTemplatePath=androluaTemplatePath.."/Normal.zip"
    appTemplatePath=appTemplatePath.."/Normal.zip"
  end

  function unzip(path,unzipPath)
    File(unzipPath).mkdirs()
    local zipFile=ZipFile(path)
    if zipFile.isValidZipFile() then
      zipFile.extractAll(unzipPath)
     else
      print("损坏的压缩包:",path)
    end
  end

  this.update(activity.getString(R.string.project_create_unzip_base))
  --解压基础工程
  local unZipList={
    {BaseTemplatePath,projectPath},
    {androluaTemplatePath,projectPath},
    {androluaBaseTemplatePath,projectPath},
    {appTemplatePath,projectPath},
  }
  for index,content in ipairs(unZipList) do
    unzip(content[1],content[2])
  end
  unZipList=nil

  this.update(activity.getString(R.string.project_create_unzip_slibs))
  for index,content in pairs(OpenedSLibs) do
    local path=content.path
    local file=File(path)
    if file.isFile() then
      unzip(path,mainProjectPath)
     else
      --通用模版
      local currencyPath=path.."/currency.zip"
      local currencyFile=File(currencyPath)
      if currencyFile.isFile()
        unzip(currencyPath,mainProjectPath)
      end

      --Androlua定制
      local customizedPath=("%s/%s.zip"):format(path,androluaVersion)
      local customizedFile=File(customizedPath)
      if customizedFile.isFile()
        unzip(customizedPath,mainProjectPath)
      end
    end
  end

  this.update(activity.getString(R.string.project_create_unzip_jarlibs))
  for index,content in pairs(OpenedJarLibs) do
    FileUtil.copyDir(content.file,mainLibsFile,true)
  end

  this.update(activity.getString(R.string.project_create_unzip_clibs))
  for index,content in pairs(OpenedCLibs) do
    local deletePaths=content.delete
    if deletePaths then
      for index,content in pairs(deletePaths) do
        LuaUtil.rmDir(File(projectPath.."/"..content))
      end
    end
  end
  for index,content in pairs(OpenedCLibs) do
    local path=content.path
    local libProjectPath=path.."/project.zip"
    local libProjectFile=File(libProjectPath)
    local libAssetsPath=path.."/assets.zip"
    local libAssetsFile=File(libAssetsPath)
    local libJarPath=path.."/jarLibs.zip"
    local libJarFile=File(libJarPath)
    local libLuaLibsPath=path.."/luaLibs.zip"
    local libLuaLibsFile=File(libLuaLibsPath)
    local libJniLibsPath=path.."/jniLibs.zip"
    local libJniLibsFile=File(libJniLibsPath)
    local libResPath=path.."/res.zip"
    local libResFile=File(libResPath)

    if libProjectFile.isFile() then
      unzip(libProjectPath,projectPath)
    end
    if libAssetsFile.isFile() then
      unzip(libAssetsPath,mainProjectPath.."/assets_bin")
    end
    if libJarFile.isFile() then
      unzip(libJarPath,mainLibsPath)
    end
    if libLuaLibsFile.isFile() then
      unzip(libLuaLibsPath,mainProjectPath.."/luaLibs")
    end
    if libJniLibsFile.isFile() then
      unzip(libJniLibsPath,mainProjectPath.."/jniLibs")
    end
    if libResFile.isFile() then
      unzip(libResPath,mainProjectPath.."/res")
    end

    local libFormatFilesList=content.format
    if libFormatFilesList then
      for index,content in ipairs(libFormatFilesList) do
        table.insert(formatFilesList,content)
      end
    end
  end

  this.update(activity.getString(R.string.project_create_write))

  local keysTableFormater=assert(loadfile(TemplatesDir.."/keysTableFormater.lua"))()
  local keysTableFormatTemp={}
  for index,content in ipairs(formatFilesList) do
    local path=projectPath.."/"..content
    --print(path)
    local fileContent=io.open(path):read("*a")
    for key,content in pairs(keys) do
      if type(content)=="table" then
        local tempContent=keysTableFormatTemp[key]
        if not(tempContent) then
          content=keysTableFormater(key,content)
          keysTableFormatTemp[key]=content
         else
          content=tempContent
        end
      end
      fileContent=fileContent:gsub("{{"..key.."}}",tostring(content))
    end
    io.open(path,"w"):write(fileContent):close()
  end

  activity.setSharedData("openedfilepath_"..projectPath,nil)--将已打开的文件路径设置为空
  return true,projectPath
end

function update(message)
  showLoadingDia(message)
end

function callback(success,projectPath)
  closeLoadingDia()
  if success then
    activity.result({"project_created_successfully",projectPath})
   else
    AlertDialog.Builder(activity)
    .setTitle(activity.getString(R.string.project_create_failed))
    .setMessage(activity.getString(R.string.unknowError))
    .setPositiveButton(android.R.string.ok,nil)
    .show()
  end
end

--默认的Key
defaultKeys=getConfigFromFile(TemplatesDir.."/default.lua")

local androluaVersions=BaseTemplateConfig.androluaVersions
if getSharedData("newproject_androluaVersion")==nil then
  setSharedData("newproject_androluaVersion",androluaVersions[#androluaVersions])
end

--Androlua版本
for index,content in ipairs(androluaVersions) do
  addChoiceChip(content,androluaVersionsGroup,"androluaVersion")
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
        local version=chip.text
        setSharedData("newproject_androluaVersion",version)
        androluaVersion=version
        androluaVersionSelectedId=selectedId
        return
      end
    end
    androluaVersion=nil
    androluaVersionSelectedId=nil
  end
}
--[[
for viewIndex,content in ipairs(luajava.astable(File(BaseTemplateDirPath.."/androluaTemplate").listFiles())) do
  if content.isDirectory() then
    for index,content in ipairs(luajava.astable(content.listFiles())) do
      if content.isDirectory() then
        local path=content.getPath()
        local config=getConfigFromFile(path.."/config.lua")
        config.path=path
        config.viewIndex=viewIndex
        config.onCheckedChanged=onComplexLibrariesCheckChanged
        addChip(("%s (%s)"):format(config.name,content.getName()),config,complexLibrariesGroup)
      end
    end
  end
end]]

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
        addChip(("%s (%s)"):format(config.name,content.getName()),config,complexLibrariesGroup)
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
        addChip(("%s (%s)"):format(libraryFile.getName(),content.getName()),config,jarLibrariesGroup)
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
    addChip(content.getName(),config,simpleLibrariesGroup)
  end
end



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



noButton.onClick=function()
  activity.finish()
end

creativeButton.onClick=function()
  local keys=buildkeys()

  local appName=keys.appName
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
    activity.newTask(newProject,update,callback).execute({keys,BaseTemplateConfig,projectPath,TemplatesDir,BaseTemplateDirPath,BaseTemplatePath,OpenedSLibs,OpenedJarLibs,OpenedCLibs})
  end)
  .setNegativeButton(android.R.string.no,nil)
  .show()

end

androidXSwitchParent.onClick=function()
  local nowState=androidXSwitch.isChecked()
  local newState=not(nowState)
  androidXSwitch.setChecked(newState)
  setSharedData("newproject_androidXSwitch",newState)
end

--应用名与包名
appNameEdit.setText(defaultKeys.appName)
packageNameEdit.setText(defaultKeys.appPackageName)
local newproject_androidXSwitch=getSharedData("newproject_androidXSwitch")
if newproject_androidXSwitch~=nil then
  androidXSwitch.setChecked(newproject_androidXSwitch)
 else
  androidXSwitch.setChecked(defaultKeys.androidX)
end

screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({

})

onConfigurationChanged(activity.getResources().getConfiguration())

