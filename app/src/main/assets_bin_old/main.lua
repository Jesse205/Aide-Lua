require "import"
initApp=true--首页面，初始化
require "Jesse205"

--检测是否需要进入欢迎页面
import "agreements"
welcomeAgain=not(getSharedData("welcome"))
if not(welcomeAgain) then
  for index,content in ipairs(agreements) do
    if getSharedData(content.name)~=content.date then
      welcomeAgain=true
    end
  end
end
if welcomeAgain then
  pcall(function()--百度移动统计稍微有一点bug
    StatService.setAuthorizedState(activity,false)
  end)
  newSubActivity("Welcome")
  activity.finish()
  return
end

--开启百度统计
pcall(function()
  StatService.setAuthorizedState(activity,true)
end)
StatService.start(activity)

--安全模式
safeModeEnable=File("/sdcard/aidelua_safemode").exists()
notSafeModeEnable=not(safeModeEnable)
application.set("safeModeEnable",safeModeEnable)

import "android.text.TextUtils$TruncateAt"
import "android.content.ComponentName"
import "android.provider.DocumentsContract"
import "androidx.drawerlayout.widget.DrawerLayout"

import "com.google.android.material.tabs.TabLayout"
import "com.google.android.material.chip.Chip"
import "com.google.android.material.chip.ChipGroup"

import "com.bumptech.glide.request.RequestOptions"
import "com.bumptech.glide.load.engine.DiskCacheStrategy"
--import "com.bumptech.glide.load.resource.drawable.DrawableTransitionOptions"

import "com.nwdxlgzs.view.photoview.PhotoView"
import "com.pixplicity.sharp.Sharp"

import "com.Jesse205.layout.MyEditDialogLayout"
import "com.Jesse205.app.actionmode.SearchActionMode"
import "com.Jesse205.app.dialog.EditDialogBuilder"
import "com.Jesse205.util.FileUtil"
import "com.Jesse205.util.ScreenFixUtil"
import "com.Jesse205.FileInfoUtils"

import "AppFunctions"
import "DialogFunctions"
import "CreateFile"

import "getImportCode"

import "FilesBrowserManager"
import "EditorsManager"
import "FilesTabManager"
import "layouts.item"

import "sub.LayoutHelper2.loadpreviewlayout"

import "adapter.FileListAdapter"

PluginsUtil.setActivityName("main")
PluginsUtil.loadPlugins()
plugins=PluginsUtil.getPlugins()

--申请存储权限
PermissionUtil.smartRequestPermission({"android.permission.WRITE_EXTERNAL_STORAGE","android.permission.READ_EXTERNAL_STORAGE"})

DefaultPakcagePath=package.path



--subWindow_ProjectPath,subWindow_FilePath=...

DirData=nil

--FilesDataList={}

FilesTabList={}
FilesListScroll={}

PathsTabList={}
PathsTabShowList={}

magnifierPosition={}

oldJesse205LibHl=getSharedData("Jesse205Lib_Highlight")
oldAndroidXHl=getSharedData("AndroidX_Highlight")
oldTheme=ThemeUtil.getAppTheme()
oldDarkActionBar=getSharedData("theme_darkactionbar")
oldRichAnim=getSharedData("richAnim")
oldTabIcon=getSharedData("tab_icon")
oldEditorSymbolBar=getSharedData("editor_symbolBar")
oldEditorPreviewButton=getSharedData("editor_previewButton")

--editor_magnify=getSharedData("editor_magnify")

lastBackTime=0

SDK_INT=Build.VERSION.SDK_INT

activityStopped=false

activity.setTitle(R.string.app_name)
activity.setContentView(loadlayout2("layout"))
actionBar.setTitle(R.string.app_name)
actionBar.setDisplayHomeAsUpEnabled(true)


EditorUtil.switchEditor("NoneView")

--[[
previewChipGroupSelectedId=editChip.getId()
editChip.setChecked(true)
]]
LuaReservedCharacters={"switch","if","then","and","break","do",
  "else","elseif","end","false",
  "for","function","in","local","nil","not",
  "or","repeat","return","true","until","while"}--lua关键字

if notSafeModeEnable then
  pcall(function()--放大镜
    import "android.widget.Magnifier"
    magnifier=Magnifier(editorGroup)
    magnifierUpdateTi=Ticker()--放大镜的定时器，定时刷新放大镜
    magnifierUpdateTi.setPeriod(200)
    magnifierUpdateTi.onTick=function()
      magnifier.update()
    end
    magnifierUpdateTi.setEnabled(false)--先禁用放大镜
  end)
end

function onCreate(savedInstanceState)
  --[[
  local openedProject=subWindow_ProjectPath or getSharedData("openedproject")
  openedProject=tostring(openedProject)
  if openedProject=="nil" then
    openedProject=nil
  end
  if openedProject and openedProject~=ProjectsPath then
    --print(openedProject,type(openedProject))
    local projectDirectory=File(tostring(openedProject))
    if projectDirectory.isDirectory() then
      --NowProjectDirectory=projectDirectory
      --NowDirectory=NowProjectDirectory
      local openFile=tostring(subWindow_FilePath)
      if openFile=="nil" then
        openFile=nil
       else
        openFile=File(openFile)
      end
      openProject(projectDirectory,openFile)
      --refresh(NowProjectDirectory)
      NowEditor.setScrollY(0)
    end
   else
    closeProject()
    refresh()
    editorFunc.open(true)
    toggle.syncState()
  end]]
  PluginsUtil.callElevents("onCreate",savedInstanceState)
end

function onCreateOptionsMenu(menu)
  local inflater=activity.getMenuInflater()
  inflater.inflate(R.menu.menu_main_aidelua,menu)
  --获取一下Menu
  closeFileMenu=menu.findItem(R.id.menu_file_close)
  saveFileMenu=menu.findItem(R.id.menu_file_save)
  binMenu=menu.findItem(R.id.menu_project_bin)
  binRunMenu=menu.findItem(R.id.menu_bin_run)
  closeProjectMenu=menu.findItem(R.id.menu_project_close)

  codeMenu=menu.findItem(R.id.subMenu_code)
  toolsMenu=menu.findItem(R.id.subMenu_tools)
  fileMenu=menu.findItem(R.id.subMenu_file)
  projectMenu=menu.findItem(R.id.subMenu_project)
  moreMenu=menu.findItem(R.id.subMenu_more)
  pluginsMenu=menu.findItem(R.id.subMenu_plugins)

  --菜单组
  StateByFileAndEditorMenus={saveFileMenu}
  StateByFileMenus={closeFileMenu}
  StateByEditorMenus={codeMenu}
  StateByProjectMenus={binMenu,closeProjectMenu,binRunMenu}

  screenConfigDecoder.events.menus={--自动刷新菜单显示
    [600]={codeMenu,toolsMenu},
    [800]={fileMenu,projectMenu,moreMenu,pluginsMenu},
  }

  --添加插件菜单
  local pluginsActivities=plugins.activities
  local pluginsActivitiesName=plugins.activitiesName
  if #pluginsActivities==0 then
    pluginsMenu.setVisible(false)
   else
    local pluginsMenuBuilder=pluginsMenu.getSubMenu()
    for index,content in ipairs(pluginsActivities) do
      pluginsMenuBuilder.add(pluginsActivitiesName[index])
      .onMenuItemClick=function()
        --[[
        local rootPath,filePath
        if OpenedProject then
          rootPath=NowProjectDirectory.getPath()
          if OpenedFile then
            filePath=NowFile.getPath()
          end
        end
        newActivity(content,{rootPath,filePath})]]
      end
    end
  end
  PluginsUtil.callElevents("onCreateOptionsMenu",menu)

  LoadedMenu=true
  refreshMenusState()--刷新Menu状态
end

function onOptionsItemSelected(item)
  local id=item.getItemId()
  local Rid=R.id
  local aRid=android.R.id
  local editorActions=EditorsManager.action
  if id==aRid.home then--菜单键
    FilesBrowserManager.switchState()
   elseif id==Rid.menu_undo then--撤销
    editorActions.undo()
   elseif id==Rid.menu_redo then--重装
    editorActions.redo()
   elseif id==Rid.menu_run then--运行
    ProjectManager.runProject()
   elseif id==Rid.menu_bin_run then--二次打包
    --[[
    local succeed
    if OpenedFile and IsEdtor then
      succeed=saveFile()
     else
      succeed=true
    end
    if succeed then
      ReBuildTool(NowProjectDirectory.getPath(),true)
    end]]
   elseif id==Rid.menu_project_bin then--二次打包
    --[[
    local succeed
    if OpenedFile and IsEdtor then
      succeed=saveFile()
     else
      succeed=true
    end
    if succeed then
      ReBuildTool(NowProjectDirectory.getPath())
    end]]
   elseif id==Rid.menu_project_close then--关闭项目
    ProjectManager.closeProject()
    --closeProject()
    --refresh(ProjectsFile)--打开项目文件夹，就自动关闭了项目
   elseif id==Rid.menu_file_save then--保存
    --editorFunc.save()
   elseif id==Rid.menu_file_close then--关闭文件
    editorFunc.closeFile()
   elseif id==Rid.menu_code_format then--格式化
    editorFunc.format()
   elseif id==Rid.menu_code_search then--代码搜索
    EditorsManager.startSearch()
   elseif id==Rid.menu_code_checkImport then--检查导入
    --[[
    local packageName=activity.getPackageName()
    if OpenedProject then--打开了工程
      local projectPath=NowProjectDirectory.getPath()
      local configPath=projectPath.."/.aidelua/config.lua"
      local configFile=File(configPath)
      if configFile.isFile() then--如果有文件
        local config=getConfigFromFile(configPath)
        if config.packageName then
          packageName=config.packageName
        end
      end
    end
    newSubActivity("FixImport",{NowEditor.text,packageName})]]
   elseif id==Rid.menu_tools_javaApiViewer then--JavaAPI浏览器
    newSubActivity("JavaApi")
   elseif id==Rid.menu_tools_javaApiViewer_windmill then--JavaAPI浏览器
    startWindmillActivity("Java API")
   elseif id==Rid.menu_tools_logCat then--日志猫
    --newSubActivity("LogCat")
    --editorFunc.run(sdLogCatPath)
    if OpenedProject then
      editorFunc.run(checkSharedActivity("LogCat"))
     else
      newSubActivity("LogCat")
    end
   elseif id==Rid.menu_tools_httpDebugging_windmill then--Http 调试
    startWindmillActivity("Http 调试")
   elseif id==Rid.menu_tools_luaManual_windmill then--Lua 手册
    startWindmillActivity("手册")
   elseif id==Rid.menu_tools_manual then--Lua 手册
    openUrl("https://gitee.com/Jesse205/AideLua/blob/master/README.md")
   elseif id==Rid.menu_more_settings then--设置
    newSubActivity("Settings")
   elseif id==Rid.menu_more_about then--关于
    newSubActivity("About")
   elseif id==Rid.menu_code_checkCode then--代码查错
    editorFunc.check()
   elseif id==Rid.menu_tools_layoutHelper then--布局助手
    --[[
    local prjPath,layoutContent
    if OpenedProject then
      local configPath=ReBuildTool.getConfigPathByProjectDir(NowProjectDirectory)
      local configFile=File(configPath)
      local config=ReBuildTool.getConfigByFilePath(configPath)
      prjPath=ReBuildTool.getMainProjectDirByConfig(NowProjectDirectory,config).."/assets_bin"
      if OpenedFile and ProjectUtil.getFileTypeByName(NowFile.getName())=="aly" then
        layoutContent=NowEditor.getText()
      end
    end
    newSubActivity("LayoutHelper2",{prjPath,layoutContent})]]--新的布局助手没做完
    --[[
    if OpenedProject then
      if OpenedFile then
        newSubActivity("LayoutHelper",{NowProjectDirectory.getPath().."/app/src/main/assets_bin",NowFile.getPath()})
       else
        newSubActivity("LayoutHelper",{NowProjectDirectory.getPath().."/app/src/main/assets_bin"})
      end
     else
      newSubActivity("LayoutHelper")
    end
]]
   elseif id==Rid.menu_more_openNewWindow then--打开新窗口
    activity.newActivity("main",{ProjectManager.ProjectsPath},true)
  end
  PluginsUtil.callElevents("onOptionsItemSelected",item)
end

function onKeyShortcut(keyCode,event)
  local filteredMetaState = event.getMetaState() & ~KeyEvent.META_CTRL_MASK;
  if (KeyEvent.metaStateHasNoModifiers(filteredMetaState)) then
    local editorActions=EditorsManager.action
    if keyCode==KeyEvent.KEYCODE_O then
      editorActions.open()
      return true
     elseif keyCode==KeyEvent.KEYCODE_S then
      FilesTabManager.saveFiles()
      return true
     elseif keyCode==KeyEvent.KEYCODE_L then
      EditorsManager.startSearch()
      return true
     elseif keyCode==KeyEvent.KEYCODE_E then
      editorActions.check()
      return true
     elseif keyCode==KeyEvent.KEYCODE_R then
      ProjectManager.runProject()
      return true
     elseif keyCode==KeyEvent.KEYCODE_Z then
      editorActions.undo()
      return true
     elseif keyCode==KeyEvent.KEYCODE_F then
      editorActions.format()
      return true
    end
  end
  PluginsUtil.callElevents("onKeyShortcut",keyCode,event)
end


function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
  local smallestScreenWidthDp=config.smallestScreenWidthDp
  local screenWidthDp=config.screenWidthDp
  ScreenWidthDp=screenWidthDp
  local drawerChildLinearParams=drawerChild.getLayoutParams()
  if screenConfigDecoder.device=="pad" then
    if screenWidthDp>384 then
      drawerChildLinearParams.width=math.dp2int(328)
     else
      drawerChildLinearParams.width=-1
    end
   else
    if screenWidthDp>448 then
      drawerChildLinearParams.width=math.dp2int(392)
     else
      drawerChildLinearParams.width=-1
    end
  end
  drawerChild.setLayoutParams(drawerChildLinearParams)
  MyAnimationUtil.ScrollView.onScrollChange(NowEditor,NowEditor.getScrollX(),NowEditor.getScrollY(),0,0,appBarLayout,nil)
  refreshSubTitle()
  refreshMoveCloseHeight(config.screenHeightDp)
  PluginsUtil.callElevents("onConfigurationChanged",config)
end

notFirstOnResume=false
function onResume()
  local reload=false
  if oldJesse205LibHl~=getSharedData("Jesse205Lib_Highlight")
    or oldAndroidXHl~=getSharedData("AndroidX_Highlight")
    then
    reload=true
    application.set("luaeditor_initialized",false)
  end
  if reload
    or (oldTheme~=ThemeUtil.getAppTheme())
    or (oldDarkActionBar~=getSharedData("theme_darkactionbar"))
    or oldRichAnim~=getSharedData("richAnim")
    or ProjectsPath~=File(getSharedData("projectsDir")).getPath()
    then
    --[[
    activity.finish()
    local intent=Intent(activity,Main)
    activity.startActivity(intent)
    local aRanim=android.R.anim
    activity.overridePendingTransition(aRanim.fade_in,aRanim.fade_out)
    ]]
    activity.recreate()
    return
  end
  if magnifier then--刷新放大镜状态
    editor_magnify=getSharedData("editor_magnify")
  end

  if notFirstOnResume then
    if notSafeModeEnable then
      --task(500,refresh)--刷新列表
      refresh()--因为已经重写了，所以应该没有闪退bug了

      local newTabIcon=getSharedData("tab_icon")--刷新标签栏按钮状态
      if oldTabIcon~=newTabIcon then
        oldTabIcon=newTabIcon
        if newTabIcon then
          for index,content in pairs(FilesTabList) do
            local tab=content.tab
            tab.setIcon(ProjectUtil.getFileIconResIdByType(content.fileType))
            initFileTabView(tab,content)--再次初始化一下标签栏，下方同理
          end
         else
          for index,content in pairs(FilesTabList) do
            local tab=content.tab
            tab.setIcon(nil)
            initFileTabView(tab,content)
          end
        end
      end
      local newEditorSymbolBar=getSharedData("editor_symbolBar")
      if oldEditorSymbolBar~=newEditorSymbolBar then
        oldEditorSymbolBar=newEditorSymbolBar
        refreshSymbolBar(newEditorSymbolBar)
      end
      local newEditorPreviewButton=getSharedData("editor_previewButton")
      if oldEditorPreviewButton~=newEditorPreviewButton then
        if newEditorPreviewButton then
          if ProjectUtil.SupportPreviewType[NowFileType] then
            previewChipCardView.setVisibility(View.VISIBLE)
           else
            previewChipCardView.setVisibility(View.GONE)
          end
         else
          previewChipCardView.setVisibility(View.GONE)
          EditorUtil.switchPreview(false)
        end
        oldEditorPreviewButton=newEditorPreviewButton
      end

      if OpenedFile and EditorUtil.isPreviewing then
        EditorUtil.switchPreview(false)
        if IsEdtor then
          reOpenFile()
        end
        EditorUtil.switchPreview(true)
       elseif OpenedFile and IsEdtor then
        reOpenFile()
      end

    end
  end
  notFirstOnResume=true
end

function onResult(name,action,content)
  if action=="project_created_successfully" then
    showSnackBar(R.string.create_success)
    .setAction(R.string.open,function()
      if OpenedProject then--已打开项目
        closeProject()
      end
      openProject(File(content))
    end)
   else
    showSnackBar(action)
  end
end

function onPause()
  if OpenedFile and IsEdtor then
    saveFile()
  end
end

function onStart()
  activityStopped=false
end

function onStop()
  activityStopped=true
end

function onDestroy()
  if magnifierUpdateTi and magnifierUpdateTi.isRun() then
    magnifierUpdateTi.stop()
  end
end

function onKeyDown(KeyCode,event)
  TouchingKey=true
end

function onKeyUp(KeyCode,event)
  if TouchingKey then
    TouchingKey=false
    if KeyCode==KeyEvent.KEYCODE_BACK then--返回键事件
      if drawerOpened and screenConfigDecoder.device=="phone" then--没有打开键盘且已打开侧滑，且设备为手机
        if NowDirectory then
          if OpenedProject then--已打开项目
            refresh(NowDirectory.getParentFile(),true)--返回上一个路径
           else--未打开项目
            drawer.closeDrawer(Gravity.LEFT)--关闭侧滑
          end
         else
          drawer.closeDrawer(Gravity.LEFT)--没有当前文件夹，当做啥时也没发生，关闭侧滑
        end
        return true
       elseif EditorUtil.isPreviewing then
        EditorUtil.switchPreview(false)
        return true
       else--啥都没打开
        if (System.currentTimeMillis()-lastBackTime)> 2000 then
          showSnackBar(R.string.exit_toast)
          lastBackTime=System.currentTimeMillis()
          return true
        end
      end
    end
  end
end

function onVersionChanged()
  checkUpdateSharedActivity("LogCat")
end

function onRestoreInstanceState(savedInstanceState)
  toggle.syncState()
end
--onConfigurationChanged(activity.getResources().getConfiguration())

drawerOpened=drawer.isDrawerOpen(Gravity.LEFT)
if drawerOpened==false then
  drawerOpened=nil
end
drawer.addDrawerListener(DrawerLayout.DrawerListener({
  onDrawerSlide=function(view,slideOffset)
    if screenConfigDecoder.device=="phone" then
      if slideOffset>0.5 and not(drawerOpened) then
        drawerOpened=true
       elseif slideOffset<=0.5 and drawerOpened then
        drawerOpened=false
      end
    end
  end,
  onDrawerOpened=function(view)
    if OpenedFile and IsEdtor then
      saveFile()
    end
  end,
  onDrawerClosed=function(view)
  end,
  onDrawerStateChanged=function(newState)
  end
}))


toggle=ActionBarDrawerToggle(activity,drawer,R.string.drawer_open, R.string.drawer_close)
drawer.addDrawerListener(toggle)
toggle.syncState()

swipeRefresh.setOnRefreshListener(SwipeRefreshLayout.OnRefreshListener{onRefresh=function()
    refresh(nil,nil,true)
  end
})
MyStyleUtil.applyToSwipeRefreshLayout(swipeRefresh)

DirData={}
adp=FileListAdapter(DirData,item)
recyclerView.setAdapter(adp)
layoutManager=LinearLayoutManager()
recyclerView.setLayoutManager(layoutManager)
recyclerView.addOnScrollListener(RecyclerView.OnScrollListener{
  onScrolled=function(view,dx,dy)
    MyAnimationUtil.RecyclerView.onScroll(view,dx,dy,sideAppBarLayout,"LastSideActionBarElevation")
  end
})
--[[

if notSafeModeEnable then
  recyclerView.getViewTreeObserver().addOnGlobalLayoutListener({
    onGlobalLayout=function()
      if activity.isFinishing() then
        return
      end
      MyAnimationUtil.RecyclerView.onScroll(recyclerView,0,0,sideAppBarLayout,"LastSideActionBarElevation")
    end
  })
end

task(500,function()
  if safeModeEnable then
    appBarLayout.setElevation(0)
   else
    MyAnimationUtil.ScrollView.onScrollChange(NowEditor,NowEditor.getScrollX(),NowEditor.getScrollY(),0,0,appBarLayout,nil,true)
  end
end)]]

if safeModeEnable then
  editorGroup.addView(loadlayout2({
    TextView;
    text="Aide Lua 安全模式";
    textSize="16sp";
    padding="4dp";
    paddingLeft="6dp";
    paddingRight="6dp";
    layout_gravity="left|bottom";
    id="safeModeText";
    textColor=0xff000000;
    backgroundColor=0xcceeeeee;
    clickable=true;
    tooltip="安全模式可以屏蔽很多效果，可以解决很多问题。如要退出安全模式，请删除 /sdcard/aidelua_safemode ，然后重启应用";
  },nil,CoordinatorLayout))
end









refreshSymbolBar(oldEditorSymbolBar)



recyclerView.onDrag=function(view,event)
  local action=event.getAction()
  if action==DragEvent.ACTION_DRAG_STARTED then
    local desc=event.getClipDescription()--必须有描述，必须为文件
    if not(desc and desc.getMimeTypeCount()~=0 and desc.getMimeType(0)~="text/plain") then
      return false
    end
   elseif action==DragEvent.ACTION_DRAG_ENTERED then
    view.setBackgroundColor(theme.color.rippleColorAccent)
   elseif action==DragEvent.ACTION_DRAG_EXITED then
    view.setBackgroundColor(0)
   elseif action==DragEvent.ACTION_DROP then
    view.setBackgroundColor(0)
    local dropPermissions=activity.requestDragAndDropPermissions(event)
    local data=event.getClipData()
    local count=data.getItemCount()
    if count>0 then
      for index=0,count-1 do
        local nameFile
        local uri=data.getItemAt(index).getUri()
        local inputStream=activity.getContentResolver().openInputStream(uri)
        if DocumentsContract.isDocumentUri(activity, uri) then
          nameFile=File(FileInfoUtils.getPath(activity,uri))
         else
          nameFile=File(uri.getPath())
        end
        local newPath=NowDirectory.getPath().."/"..nameFile.getName()
        if File(newPath).exists() then
          showSnackBar(R.string.file_exists)
         else
          local outStream=FileOutputStream(newPath)
          LuaUtil.copyFile(inputStream, outStream)
          outStream.close()
          refresh()
        end
        --print(DocumentsContract.isDocumentUri(activity, uri))
        --print(FileInfoUtils.getPath(activity,uri))
      end
    end
    dropPermissions.release()
  end
  return true
end

screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({
  onDeviceChanged=function(device,oldDevice)
    if device=="phone" then--切换为手机时
      local LDLayoutTransition,LMLlayoutTransition=largeDrawerLay.getLayoutTransition(),largeMainLay.getLayoutTransition()
      largeDrawerLay.setLayoutTransition(nil)
      largeMainLay.setLayoutTransition(nil)

      largeDrawerLay.removeView(drawerChild)
      largeMainLay.removeView(mainEditorLay)
      drawer.addView(mainEditorLay)
      drawer.addView(drawerChild)

      local linearParams=drawerChild.getLayoutParams()
      linearParams.gravity=Gravity.LEFT
      drawerChild.setLayoutParams(linearParams)

      if drawerOpened then
        Handler().postDelayed(Runnable({
          run=function()
            drawer.openDrawer(Gravity.LEFT)
          end
        }),50)
      end
      largeMainLay.setVisibility(View.GONE)
      drawer.setVisibility(View.VISIBLE)
      if drawerOpened==nil then
        drawerOpened=false
      end
      drawerChild.setVisibility(View.VISIBLE)
      toggle.syncState()

      largeDrawerLay.setLayoutTransition(LDLayoutTransition)
      largeMainLay.setLayoutTransition(LMLlayoutTransition)
     elseif oldDevice=="phone" then--切换为平板或电脑时
      local LDLayoutTransition,LMLlayoutTransition=largeDrawerLay.getLayoutTransition(),largeMainLay.getLayoutTransition()
      largeDrawerLay.setLayoutTransition(nil)
      largeMainLay.setLayoutTransition(nil)

      drawer.removeView(mainEditorLay)
      drawer.removeView(drawerChild)
      largeDrawerLay.addView(drawerChild)
      largeMainLay.addView(mainEditorLay)

      largeMainLay.setVisibility(View.VISIBLE)
      drawer.setVisibility(View.GONE)
      if drawerOpened or drawerOpened==nil then
        drawerOpened=true
        drawerChild.setVisibility(View.VISIBLE)
       else
        drawerChild.setVisibility(View.GONE)
      end
      toggle.syncState()

      largeDrawerLay.setLayoutTransition(LDLayoutTransition)
      largeMainLay.setLayoutTransition(LMLlayoutTransition)
    end
  end,
})
--screenConfigDecoder.device="phone"--默认为手机




onConfigurationChanged(activity.getResources().getConfiguration())
if drawerOpened==nil then
  drawerOpened=false
end

local nowYear=os.date("%Y")
local nowDate=os.date("%m-%d")
if nowDate=="11-25" then
  if getSharedData("festival_11-25")~=nowYear then
    MyToast.showToast("Father And Mother I Love You")
    setSharedData("festival_11-25",nowYear)
  end
end