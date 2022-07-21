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

function FilesTabManager.openFile(file)
  local filePath=file.getPath()
  local lowerFilePath=string.lower(filePath)--小写路径
  nowFileConfig={
    file=file,
    path=filePath,
    lowerPath=lowerFilePath,
  }
  openedFiles[lowerFilePath]=nowFileConfig
  
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
function FilesTabManager.saveFiles()
end

function FilesTabManager.init(filesTabLay)
end

function FilesTabManager.changeContent(content)
  nowFileConfig.newContent=content
end

return FilesTabManager

--[[
filesTabLay.addOnTabSelectedListener(TabLayout.OnTabSelectedListener({
  onTabSelected=function(tab)
    local tag=tab.tag
    local file=tag.file
    if (not(OpenedFile) or file.getPath()~=NowFile.getPath()) then
      openFile(file)
    end
  end,
  onTabReselected=function(tab)
    if OpenedFile and IsEdtor then
      saveFile()
    end
  end,
  onTabUnselected=function(tab)
  end
}))
filesTabLay.onTouch=onFileTabLayTouch]]