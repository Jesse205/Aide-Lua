require "import"
import "Jesse205"
import "android.text.SpannableString"
import "android.text.style.ForegroundColorSpan"
import "com.Jesse205.layout.util.SettingsLayUtil"
import "com.Jesse205.layout.innocentlayout.RecyclerViewLayout"
import "settings"
import "SettingsLayUtilPro"

appPluginsDir=AppPath.AppShareDir.."/plugins"
AppPath.AppPluginsDir=appPluginsDir
pluginsFile=File(appPluginsDir)

local PackInfo=activity.PackageManager.getPackageInfo(activity.getPackageName(),64)
local versionCode=PackInfo.versionCode

activity.setTitle(R.string.plugins_manager)
activity.setContentView(loadlayout2(RecyclerViewLayout))
actionBar.setDisplayHomeAsUpEnabled(true)

REQUEST_INSTALLPLUGIN=10
settings2={}

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
end

function onActivityResult(requestCode,resultCode,data)
  if resultCode==Activity.RESULT_OK then
    if requestCode==REQUEST_INSTALLPLUGIN then
      installPlugin(data.getData())
    end
  end
end

function onResume()
  refresh()
end

function getAlpInfo(path,data)
  local app = {}
  loadstring(tostring(String(LuaUtil.readZip(path, "init.lua"))), "bt", "bt", app)()
  local str = string.format("名称: %s\
版本: %s\
包名: %s\
作者: %s\
说明: %s\
路径: %s",
  app.appname,
  app.appver,
  app.packagename,
  app.developer,
  app.description,
  data)
  return str, app.mode
end

function installPlugin(uri)
  local scheme=uri.getScheme()
  local path
  if scheme=="content" then
    local inputStream=activity.getContentResolver().openInputStream(uri);
    path=AppPath.AppSdcardCacheDataDir.."/"..File(uri.getPath()).getName()
    local outputStream=FileOutputStream(path);
    LuaUtil.copyFile(inputStream,outputStream)
   else
    return
  end
  local message,mode=getAlpInfo(path,uri)
  if mode=="plugin" then
    AlertDialog.Builder(this)
    .setTitle("安装插件")
    .setMessage(message)
    .setPositiveButton("安装",function()
    end)
    .setNegativeButton(android.R.string.cancel,nil)
    .show()
  end
end

function onItemClick(view,views,key,data)
  if key=="plugin_item" then
    local config=data.config
    local newState=not(data.checked)
    if data.enableVer then
      if newState then
        PluginsUtil.setEnabled(data.dirName,versionCode)
       else
        PluginsUtil.setEnabled(data.dirName,false)
      end
     else
      PluginsUtil.setEnabled(data.dirName,newState)
    end
   elseif key=="install_plugin" then
    local intent=Intent(Intent.ACTION_GET_CONTENT)
    intent.setType("application/zip|application/alp")
    intent.putExtra(Intent.EXTRA_MIME_TYPES,{"application/zip","application/alp"})
    intent.addCategory(Intent.CATEGORY_OPENABLE)
    activity.startActivityForResult(intent, REQUEST_INSTALLPLUGIN)
  end
end

function addSummaryTextLine(summarySpanIndex,color,oldSummary,summary)
  local newSummary=oldSummary.."\n"..summary
  table.insert(summarySpanIndex,{theme.color[color] or color,utf8.len(oldSummary)+1,utf8.len(newSummary)})
  return newSummary
end

function refresh()
  table.clear(settings2)
  for index,content in ipairs(settings) do
    table.insert(settings2,content)
  end
  if pluginsFile.isDirectory() then--存在插件文件夹
    local fileList=pluginsFile.listFiles()
    for index=0,#fileList-1 do
      local file=fileList[index]
      if file.isDirectory() then
        local title,config,spannableSummary
        local summary=""
        local summarySpanIndex={}
        local enableVer=false
        local checked=false
        local enabled=true
        local path=file.getPath()
        local dirName=file.getName()
        local initPath=path.."/init.lua"
        local icon=path.."/icon.png"
        if File(initPath).isFile() then
          config=getConfigFromFile(initPath)--init.lua内容
          if config.appname then
            title=config.appname
           else
            title=dirName
          end
          local pluginVersionName=config.appver
          local pluginVersionCode=config.appcode
          if pluginVersionName then
            if versionCode then
              summary=("版本号：%s (%s)"):format(pluginVersionName,pluginVersionCode)
             else
              summary="版本号："..pluginVersionName
            end
           elseif pluginVersionCode then
            summary="版本号："..pluginVersionCode
           else
            summary="版本号：未知"
          end
          local packageName=config.packagename
          if packageName then
            if packageName==dirName then
              summary=summary.."\n包名："..packageName
             else
              summary=summary..("\n包名：%s (%s)"):format(packageName,dirName)
              summary=addSummaryTextLine(summarySpanIndex,"Orange",summary,"请确保模块的包名与文件夹名相同")
            end
           else
            summary=summary.."\n包名："..dirName
            summary=addSummaryTextLine(summarySpanIndex,"Orange",summary,"请填写包名")
          end

          local minVerCode=config.minemastercode
          local targetVerCode=config.targetmastercode
          if minVerCode==nil or minVerCode<=versionCode then
            checked=PluginsUtil.getEnabled(dirName)
            if targetVerCode and targetVerCode<versionCode then--版本号在允许的范围之内或者强制启用
              checked=checked==versionCode
              enableVer=true
              summary=addSummaryTextLine(summarySpanIndex,"Orange",summary,"此插件专为旧版本 "..application.get("appName").." 开发，请检查插件更新")
            end
           else
            enabled=false
            summary=addSummaryTextLine(summarySpanIndex,"Orange",summary,"您的 "..application.get("appName").." 版本不符合此插件最低要求，请检查软件更新")
          end
          if config.supported then
            if not(table.find(config.supported,apptype)) then
              summary=addSummaryTextLine(summarySpanIndex,"Red",summary,"此插件不适配本编辑器，请下载对应版本的插件")
            end
           else
            summary=addSummaryTextLine(summarySpanIndex,"Orange",summary,"此插件未指定支持的编辑器，因此可能无法正常加载")
          end
         else
          config={}
          enabled=false
          title=dirName
          summary="非法模块，建议删除"
          table.insert(summarySpanIndex,{theme.color.Red,0,utf8.len(summary)})
          --checked=false
        end

        if #summarySpanIndex~=0 then
          spannableSummary=SpannableString(summary)
          summary=nil
          for index,content in ipairs(summarySpanIndex) do
            spannableSummary.setSpan(ForegroundColorSpan(content[1]),content[2],content[3],0)
          end
        end
        if not(File(icon).isFile()) then
          icon=R.drawable.ic_puzzle_icon
          --icon=android.R.drawable.sym_def_app_icon
        end
        table.insert(settings2,{
          SettingsLayUtil.ITEM_AVATAR_SWITCH;
          icon=icon,
          title=title,
          summary=summary or spannableSummary,
          key="plugin_item",
          checked=toboolean(checked),
          config=config,
          enabled=enabled,
          enableVer=enableVer,
          dirName=dirName,
        })
      end
    end
  end
  table.insert(settings2,{
    SettingsLayUtil.ITEM_ONLYSUMMARY;
    summary="注：开关插件后需要程序启动本应用",
    --enabled=false
  })
  adp.notifyDataSetChanged()
end

--refresh()

adp=SettingsLayUtil.newAdapter(settings2,onItemClick)
recyclerView.setAdapter(adp)
layoutManager=LinearLayoutManager()
recyclerView.setLayoutManager(layoutManager)
recyclerView.addOnScrollListener(RecyclerView.OnScrollListener{
  onScrolled=function(view,dx,dy)
    MyAnimationUtil.RecyclerView.onScroll(view,dx,dy)
  end
})
recyclerView.getViewTreeObserver().addOnGlobalLayoutListener({
  onGlobalLayout=function()
    if activity.isFinishing() then
      return
    end
    MyAnimationUtil.RecyclerView.onScroll(recyclerView,0,0)
  end
})
mainLay.onTouch=function(view,...)
  recyclerView.onTouchEvent(...)
end


if scroll then
  scroll=luajava.astable(scroll)
  local pos=scroll[1] or 0
  recyclerView.scrollToPosition(pos)
end


screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({
  listViews={recyclerView},
})

onConfigurationChanged(activity.getResources().getConfiguration())

