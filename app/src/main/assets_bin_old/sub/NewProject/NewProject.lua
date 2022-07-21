local NewProject={}

function NewProject.update(message)
  showLoadingDia(message)
end

function NewProject.callback(success,projectPath)
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
function NewProject.newProject(keys,BaseTemplateConfig,projectPath,TemplatesDir,openedSLibs,openedJarLibs,openedCLibs)
  require "import"
  import "java.io.File"
  import "net.lingala.zip4j.ZipFile"

  import "com.Jesse205.util.FileUtil"
  R=luajava.bindClass(activity.getPackageName()..".R")

  this.update(activity.getString(R.string.project_create_gathering))

  keys=luajava.astable(keys,true)
  BaseTemplateConfig=luajava.astable(BaseTemplateConfig,true)
  openedSLibs=luajava.astable(openedSLibs,true)--勾选的简单库
  openedJarLibs=luajava.astable(openedJarLibs,true)--勾选的Jar
  openedCLibs=luajava.astable(openedCLibs,true)--勾选的复杂库

  local formatFilesList=BaseTemplateConfig.format

  local androidX=keys.androidX
  local androluaVersion=keys.androluaVersion

  --各种路径
  local mainProjectPath=projectPath.."/app/src/main"
  local mainLibsPath=projectPath.."/app/libs"
  local mainLibsFile=File(mainLibsPath)

  local baseTemplateDirPath=TemplatesDir.."/baseTemplate"
  local androluaTemplatePath=baseTemplateDirPath.."/androluaTemplate/"..androluaVersion
  local androluaBaseTemplatePath=androluaTemplatePath.."/baseTemplate.zip"
  local appTemplatePath=baseTemplateDirPath.."/appTemplate/"..BaseTemplateConfig.appVersions[1]
  local supportBaseTemplatePath
  if androidX then
    androluaTemplatePath=androluaTemplatePath.."/AndroidX.zip"
    appTemplatePath=appTemplatePath.."/AndroidX.zip"
    supportBaseTemplatePath=baseTemplateDirPath.."/baseAndroidXTemplates.zip"
   else
    androluaTemplatePath=androluaTemplatePath.."/Normal.zip"
    appTemplatePath=appTemplatePath.."/Normal.zip"
    supportBaseTemplatePath=baseTemplateDirPath.."/baseNormalTemplates.zip"
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
    supportBaseTemplatePath,
    baseTemplateDirPath.."/baseTemplates.zip",
    androluaTemplatePath,
    androluaBaseTemplatePath,
    appTemplatePath,
  }
  for index,content in ipairs(unZipList) do
    unzip(content,projectPath)
  end
  unZipList=nil

  this.update(activity.getString(R.string.project_create_unzip_slibs))
  for index,content in pairs(openedSLibs) do
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
  for index,content in pairs(openedJarLibs) do
    FileUtil.copyDir(content.file,mainLibsFile,true)
  end

  this.update(activity.getString(R.string.project_create_unzip_clibs))
  for index,content in pairs(openedCLibs) do
    local deletePaths=content.delete
    if deletePaths then
      for index,content in pairs(deletePaths) do
        LuaUtil.rmDir(File(projectPath.."/"..content))
      end
    end
  end
  for index,content in pairs(openedCLibs) do
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
return NewProject
