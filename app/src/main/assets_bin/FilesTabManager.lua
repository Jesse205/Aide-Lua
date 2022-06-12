local FilesTabManager={}
local openedFiles={}
local nowFileConfig
FilesTabManager.openedFiles=openedFiles

function FilesTabManager.openFile(file)
  local filePath=file.getPath()
  local lowerFilePath=string.lower(filePath)
  nowFileConfig={}
  openedFiles[lowerFilePath]=nowFileConfig
end

--保存当前打开的文件
function FilesTabManager.saveFile()
end

--保存所有文件
function FilesTabManager.saveFiles()
end

return FilesTabManager
