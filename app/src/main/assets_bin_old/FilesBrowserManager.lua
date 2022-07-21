local FilesBrowserManager={}
FilesBrowserManager._ENV=_ENV

--文件颜色
local fileColors={
  normal=0xFF9E9E9E,--普通颜色
  --active=theme.color.colorAccent,--一已打开文件颜色
  folder=0xFFF9A825,--文件夹颜色

  --按文件类型
  APK=0xFF00E676,--安卓应用程序
  LUA=0xFF448AFF,
  ALY=0xFF64B5F6,
  PNG=0xFFF44336,--图片文件
  GRADLE=0xFF0097A7,
  XML=0xffff6f00,--XML文件
  DEX=0xFF00BCD4,
  JAVA=0xFF2962FF,
  JAR=0xffe64a19,
  ZIP=0xFF795548,--压缩文件
  HTML=0xffff5722,
  JSON=0xffffa000,
}
FilesBrowserManager.fileColors=fileColors

fileColors.JPG=fileColors.PNG
fileColors["7Z"]=fileColors.ZIP
fileColors.tar=fileColors.ZIP
fileColors.RAR=fileColors.ZIP
fileColors.SVG=fileColors.XML

local libsRelativePathMatch={
  "^.-/src/main/assets_bin/(.+)%.",
  "^.-/src/main/luaLibs/(.+)%.",
  "^.-/src/main/jniLibs/.-/lib(.+)%.so",
  "^.-/src/main/java/(.+)%.",
  "^.-/src/main/assets/(.+)%.",
}
FilesBrowserManager.libsRelativePathMatch=libsRelativePathMatch
local libsRelativePathType={
  java=true,
  so=true,
  lua=true,
  luac=true,
  aly=true,
}
FilesBrowserManager.libsRelativePathType=libsRelativePathType

function FilesBrowserManager.open()
end
function FilesBrowserManager.close()
end
function FilesBrowserManager.switchState()
end

function FilesBrowserManager.init(pathsTabLay)
end

return FilesBrowserManager

--[[
pathsTabLay.addOnTabSelectedListener(TabLayout.OnTabSelectedListener({
  onTabSelected=function(tab)
    local tag=tab.tag
    local path=tag.path
    if path and path~=NowDirectory.getPath() then
      refresh(File(path),true)
    end
  end,
  onTabReselected=function(tab)
  end,
  onTabUnselected=function(tab)
  end
}))
]]