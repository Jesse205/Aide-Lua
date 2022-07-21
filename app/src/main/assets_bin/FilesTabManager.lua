local FilesTabManager={}
local openedFiles={}--已打开的文件列表，以lowerPath作为键
--[[openedFiles={
["/path1.lua"]={
  file=File(),
  path="/path1.lua",
  oldContent="content1",
  newContent="content2",
  lowerPath="/path1.lua",
  edited=true,
  }
}]]
local nowFileConfig
FilesTabManager.openedFiles=openedFiles

function FilesTabManager.openFile(file,reOpen)
  local filePath=file.getPath()
  local lowerFilePath=string.lower(filePath)--小写路径
  local fileConfig
  if reOpen then
    fileConfig=openedFiles[lowerFilePath]
   else
    fileConfig={
      file=file,
      path=filePath,
      lowerPath=lowerFilePath,
    }
    openedFiles[lowerFilePath]=fileConfig
  end

end

--保存当前打开的文件
function FilesTabManager.saveFile()
  if nowFileConfig.edited then
    local newContent=nowFileConfig.newContent
    io.open(nowFileConfig.path,"w")
    :write(newContent)
    :close()
    nowFileConfig.oldContent=newContent--讲旧内容设置为新的内容
    return true--保存成功
  end
end--return:true，保存成功 nil，未保存 false，保存失败

--保存所有文件
function FilesTabManager.saveAllFiles()
end

--关闭文件，由于文件的打开都由Tab管理，所以不存在已有文件打开但是当前当前打开的文件为空的情况
function FilesTabManager.closeFile(lowerFilePath,saveFile)
  lowerFilePath=lowerFilePath or nowFileConfig.lowerFilePath
end

--保存所有文件
function FilesTabManager.closeAllFiles(saveFiles)
  for index,content in pairs(openedFiles) do
    FilesTabManager.closeFile(index,saveFiles)
  end
end

function FilesTabManager.init(filesTabLay)
  filesTabLay.addOnTabSelectedListener(TabLayout.OnTabSelectedListener({
    onTabSelected=function(tab)
      local tag=tab.tag
      local file=tag.file
      --[[
    if (not(OpenedFile) or file.getPath()~=NowFile.getPath()) then
      openFile(file)
    end]]
    end,
    onTabReselected=function(tab)
      --[[
    if OpenedFile and IsEdtor then
      saveFile()
    end]]
    end,
    onTabUnselected=function(tab)
    end
  }))
  filesTabLay.onTouch=onFileTabLayTouch
end

function FilesTabManager.changeContent(content)
  nowFileConfig.newContent=content
end

return FilesTabManager

--[[
]]