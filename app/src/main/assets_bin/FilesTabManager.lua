local FilesTabManager={}
setmetatable(FilesTabManager,FilesTabManager)

function FilesTabManager.__call(self)
  self=table.clone(self)
  return self
end
return FilesTabManager
