require "import"
import "Jesse205"
import "com.Jesse205.FileInfoUtils"
import "com.Jesse205.layout.util.SettingsLayUtil"
import "com.Jesse205.layout.innocentlayout.RecyclerViewLayout"
import "com.Jesse205.app.dialog.EditDialogBuilder"
import "net.lingala.zip4j.ZipFile"

PackInfo=activity.getPackageManager().getPackageInfo(activity.getPackageName(),64)
PluginsUtil.setActivityName("settings")

import "settings"

activity.setTitle(R.string.settings)
activity.setContentView(loadlayout2(RecyclerViewLayout))

actionBar.setDisplayHomeAsUpEnabled(true)

oldTheme=ThemeUtil.getAppTheme()
scroll=...

REQUEST_ADDCLIB=10

function onCreate(savedInstanceState)
  PluginsUtil.callElevents("onCreate",savedInstanceState)
end

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

function onResume()
  if oldTheme~=ThemeUtil.getAppTheme() then
    activity.recreate()
  end
end

function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
end

function onActivityResult(requestCode,resultCode,data)
  if resultCode==Activity.RESULT_OK then
    if requestCode==REQUEST_ADDCLIB then
      addComplexLibrary(FileInfoUtils.getPath(activity,data.getData()))
    end
  end
end

function addComplexLibrary(path)

  local file=File(path)
  local name=file.getName():match("(.+)%.zip")
  local tempDirPath=AppPath.Temp.."/MyCustomComplexLibrary/"..name
  local tempDir=File(tempDirPath)
  if tempDir.exists() then
    LuaUtil.rmDir(tempDir)
  end
  local zipFile=ZipFile(path)
  if zipFile.isValidZipFile() then
    zipFile.extractAll(tempDirPath)
   else
    MyToast("压缩包已损坏")
  end

  for index,content in ipairs(luajava.astable(tempDir.listFiles())) do
    if content.isFile() or not(File(content.getPath().."/config.lua").isFile()) then
      MyToast(("文件（夹）“%s不合法”"):format(content.getName()))
      LuaUtil.rmDir(tempDir)--删除
      return
    end
  end
  LuaUtil.copyDir(tempDir,File(AppPath.AppDataDir.."/templates/complexLibraries/"..name))
  LuaUtil.rmDir(tempDir)--删除
  MyToast("导入成功")
end

function reloadActivity(closeView)
  local aRanim=android.R.anim
  local pos,scroll
  if recyclerView then
    closeView.setEnabled(false)
    pos=layoutManager.findFirstVisibleItemPosition()
    scroll=recyclerView.getChildAt(0).getTop()
  end
  newActivity("main",aRanim.fade_in,aRanim.fade_out,{{pos,scroll}})
  activity.finish()
end

function onItemClick(view,views,key,data)
  if key=="theme_picker" then
    newSubActivity("ThemePicker")
    --[[
   elseif key=="test" then
    settings[3].enabled=not(settings[3].enabled)
    adp.notifyItemChanged(2)]]
   elseif key=="about" then
    newSubActivity("About")
   elseif key=="theme_darkactionbar" then
    reloadActivity(view)
   elseif key=="addComplexLibrary" then
    local intent=Intent(Intent.ACTION_GET_CONTENT)
    intent.setType("application/zip")
    intent.addCategory(Intent.CATEGORY_OPENABLE)
    activity.startActivityForResult(intent, REQUEST_ADDCLIB)
   elseif key=="plugins_manager" then
    newSubActivity("PluginsManager")
   else
    if data.action=="editString" then
      EditDialogBuilder.settingDialog(adp,views,key,data)
    end
  end
  PluginsUtil.callElevents("onItemClick",views,key,data)
end
for index,content in ipairs(settings) do
  if content.title==R.string.plugins then
    local items={}
    PluginsUtil.callElevents("onLoadItemsList",items)
    for index2,content in ipairs(items) do
      table.insert(settings,index+index2,content)
    end
    break
  end
end

adp=SettingsLayUtil.newAdapter(settings,onItemClick)
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

