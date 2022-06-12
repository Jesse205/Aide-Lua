local BuildToolUtil={}
setmetatable(BuildToolUtil,BuildToolUtil)

function BuildToolUtil.__call(self)
  self=table.clone(self)
  return self
end
return BuildToolUtil
