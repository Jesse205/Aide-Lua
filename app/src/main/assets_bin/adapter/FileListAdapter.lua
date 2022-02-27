local function onClick(view)
  local data=view.tag._data
  local file=data.file
  local action=data.action
  switch action do
   case "createProject" then
    newSubActivity("NewProject")
    --CreateProject()
   case "openProject" then
    openProject(file)
   case "openFolder" then
    refresh(file,data.upFile)
   case "openFile" then
    local succeed,_,inThirdPartySoftware=openFile(file)
    if succeed and not(inThirdPartySoftware) and screenConfigDecoder.device=="phone" then
      drawer.closeDrawer(Gravity.LEFT)
    end
  end
  --binProject(data.file.getPath())
end
local function onLongClick(view)
  local data=view.tag._data

  if data.position~=0 then
    local file=data.file
    local title=data.title
    local Rid=R.id

    local parentFile,parentName
    local action=data.action
    local fileName
    local filePath=data.filePath
    local isFile,fileType,fileRelativePath

    if OpenedProject then
      fileName=data.fileName
      isFile=file.isFile()
      fileType=data.fileType
      fileRelativePath=ProjectUtil.shortPath(filePath,true,NowProjectDirectory.getPath())
    end

    local pop=PopupMenu(activity,view)
    local menu=pop.Menu
    if OpenedProject and fileType and LibsRelativePathType[fileType] then--已经打开了项目并且文件类型受支持

      local inLibDir,inLibDirIndex=data.inLibDir,data.inLibDirIndex
      if not(inLibDir) then
        for index,content in ipairs(LibsRelativePathMatch) do
          inLibDir=fileRelativePath:match(content)
          inLibDirIndex=index
          if inLibDir then
            data.inLibDir,data.inLibDirIndex=inLibDir,inLibDirIndex
            break
          end
        end
      end
      if inLibDir then--是库目录
        pop.inflate(R.menu.menu_javaapi_item_package)
        local callFilePath=inLibDir:gsub("/",".")
        local noTypeFileName=fileName:match("(.+)%.")--没有扩展名的文件名

        local copyNameMenu=menu.findItem(R.id.menu_copy_className)
        local copyClassPathMenu=menu.findItem(R.id.menu_copy_classPath)
        local copyClassPath2Menu=menu.findItem(R.id.menu_copy_classPath2)
        local copyImportMenu=menu.findItem(R.id.menu_copy_import)
        copyImportMenu.title=getImportCode(callFilePath)
        copyNameMenu.setVisible(fileType~="so")
        copyClassPathMenu.setVisible(callFilePath~=noTypeFileName)
        copyClassPath2Menu.setVisible(fileType=="java")--smali仅在java目录下支持
        if fileType~="so" then
          copyNameMenu.title=noTypeFileName
        end
        if callFilePath~=noTypeFileName then--有重复的时候
          copyClassPathMenu.title=callFilePath
        end
        if fileType=="java" then
          copyClassPath2Menu.title="L"..inLibDir..";"
        end
      end
    end
    pop.inflate(R.menu.menu_main_file)
    --local reNameMenu=menu.findItem(R.id.menu_rename)
    --local deleteMenu=menu.findItem(R.id.menu_delete)
    local openInNewWindowMenu=menu.findItem(Rid.menu_openInNewWindow)--新窗口打开
    local referencesMenu=menu.findItem(Rid.menu_references)--引用资源
    local renameMenu=menu.findItem(Rid.menu_rename)--重命名

    --reNameMenu.setVisible(not(isUpFile))
    openInNewWindowMenu.setVisible(isFile or data.action=="openProject")
    referencesMenu.setVisible(toboolean(data.isResFile))
    renameMenu.setVisible(OpenedProject)
    if data.isResFile then--是资源文件
      parentFile=file.getParentFile()
      parentName=parentFile.getName()
    end

    pop.show()
    pop.onMenuItemClick=function(item)
      local id=item.getItemId()
      if id==Rid.menu_delete then--删除
        deleteFileDialog(title,file)
       elseif id==Rid.menu_rename then--重命名
        renameDialog(file)
       elseif id==Rid.menu_openInNewWindow then--新窗口打开
        if OpenedProject then--已打开项目
          activity.newActivity("main",{NowProjectDirectory,file.getPath()},true)
         else--未打开项目
          activity.newActivity("main",{file.getPath()},true)
        end
       elseif id==Rid.menu_references then--引用资源
        NowEditor.paste(("R.%s.%s"):format(parentName:match("(.-)%-")or parentName,fileName:match("(.+)%.")or fileName))
        drawer.closeDrawer(Gravity.LEFT)
       elseif id==R.id.menu_copy_import or id==R.id.menu_copy_classPath2 or id==R.id.menu_copy_classPath or id==R.id.menu_copy_className then
        MyToast.copyText(item.title)
      end
    end
    return true
  end
end

local function fileMoreMenuClick(view)
  local nowLibName,fileRelativePath,nowPrjDirPath
  if openProject then
    nowPrjDirPath=NowProjectDirectory.getPath()
    fileRelativePath=ProjectUtil.shortPath(NowDirectory.getPath(),true,nowPrjDirPath)
    if fileRelativePath:find("/.-/") then
      nowLibName=fileRelativePath:match("/(.-)/")
     elseif #fileRelativePath~=0 then
      nowLibName=fileRelativePath:match("/(.+)")
     else
      nowLibName="app"
    end
  end
  local pop=PopupMenu(activity,view)
  local menu=pop.Menu
  pop.inflate(R.menu.menu_main_file_upfile)
  pop.show()
  pop.onMenuItemClick=function(item)
    local id=item.getItemId()
    local Rid=R.id
    if id==Rid.menu_createFile then
      CreateFile(NowDirectory)
     elseif id==Rid.menu_createDir then
      createDirsDialog(NowDirectory)
     else
      if openProject then
        if id==Rid.menu_openDir_assets then
          refresh(File(("%s/%s/src/main/assets_bin"):format(nowPrjDirPath,nowLibName)))
         elseif id==Rid.menu_openDir_java then
          refresh(File(("%s/%s/src/main/java"):format(nowPrjDirPath,nowLibName)))
         elseif id==Rid.menu_openDir_lua then
          refresh(File(("%s/%s/src/main/luaLibs"):format(nowPrjDirPath,nowLibName)))
         elseif id==Rid.menu_openDir_res then
          refresh(File(("%s/%s/src/main/res"):format(nowPrjDirPath,nowLibName)))
         elseif id==Rid.menu_openDir_projectRoot then
          refresh(NowProjectDirectory)
        end
      end
    end
  end
end

--保存一下变量方便调用
local getProjectIconForGlide=ProjectUtil.getProjectIconForGlide--获取项目图标
local getFolderIconResIdByName=ProjectUtil.getFolderIconResIdByName--获取文件夹图标
local getFileIconResIdByType=ProjectUtil.getFileIconResIdByType--获取文件图标
local getFileTypeByName=ProjectUtil.getFileTypeByName--获取文件类型
local getIconAlphaByFileName=ProjectUtil.getIconAlphaByFileName--通过文件名获取文件透明度

local unknowString=activity.getString(R.string.unknown)


return function(data,item)
  local isResDir
  return LuaCustRecyclerAdapter(AdapterCreator({
    getItemCount=function()
      --print(NowProjectDirectory,NowDirectory)
      if OpenedProject then
        local nowDirPath=NowDirectory.getPath()
        local cache_isResDir=KeysCache.isResDir[nowDirPath]
        if cache_isResDir then--有缓存
          isResDir=cache_isResDir
         else--无缓存
          local nowDirName=NowDirectory.getName()
          isResDir=nowDirName~="values" and not(nowDirName:find("values%-")) and ProjectUtil.shortPath(nowDirPath,true,NowProjectDirectory.getPath()):find(".-/src/.-/res/") or false
          KeysCache.isResDir[nowDirPath]=isResDir
        end
        --print(isResDir)
       else
        isResDir=false
      end
      return #NowDirectoryFilesList+1
    end,
    getItemViewType=function(position)
      if OpenedProject then
        if position==0 then
          return 3
         else
          return 4
        end
       else
        if position==0 then
          return 1
         else
          return 2
        end
      end
    end,
    onCreateViewHolder=function(parent,viewType)
      local ids={}
      local view=loadlayout2(item[viewType],ids)
      local holder=LuaCustRecyclerHolder(view)
      view.setTag(ids)
      view.setBackground(ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary,true))
      view.onClick=onClick
      view.onLongClick=onLongClick
      if viewType==3 then
        ids.more.onClick=fileMoreMenuClick
      end
      return holder
    end,

    onBindViewHolder=function(holder,position)
      local data={position=position}
      local view=holder.view
      local tag=view.getTag()
      tag._data=data
      if position==0 then--是第一项
        if OpenedProject then
          local file=NowDirectory.getParentFile()
          tag.icon.setImageResource(R.drawable.ic_folder_outline)
          tag.icon.setColorFilter(FilesColor.folder)
          tag.title.setText("..")
          data.file=file
          data.filePath=file.getPath()
          data.fileName=".."
          data.upFile=true
          data.action="openFolder"
          view.contentDescription=activity.getString(R.string.file_up)
         else
          tag.icon.setImageResource(R.drawable.ic_plus)
          tag.title.text=activity.getString(R.string.project_create)
          data.action="createProject"
        end
       else--不是第一项
        local file=NowDirectoryFilesList[position]
        local filePath=file.getPath()

        data.file=file
        data.filePath=filePath
        if OpenedProject then
          local colorFilter
          local fileName=file.getName()
          tag.title.setText(fileName)
          tag.icon.setAlpha(getIconAlphaByFileName(fileName))
          if file.isFile() then
            FilesPositions[filePath]=position
            local fileType=getFileTypeByName(fileName)
            tag.icon.setImageResource(getFileIconResIdByType(fileType))
            if fileType then
              colorFilter=FilesColor[string.upper(fileType)] or FilesColor.normal
             else
              colorFilter=FilesColor.normal
            end
            if OpenedFile and NowFile.getPath()==filePath then
              tag.title.setTextColor(theme.color.colorAccent)
              tag.icon.setColorFilter(theme.color.colorAccent)
              tag.highLightCard.setCardBackgroundColor(theme.color.rippleColorAccent)
              NowFilePosition=position
             else
              tag.title.setTextColor(theme.color.textColorPrimary)
              tag.icon.setColorFilter(colorFilter)
              tag.highLightCard.setCardBackgroundColor(0)
            end
            data.isResFile=isResDir
            data.fileType=fileType
            data.action="openFile"
           else
            data.isResFile=false
            tag.title.setTextColor(theme.color.textColorPrimary)
            tag.icon.setImageResource(getFolderIconResIdByName(fileName))
            tag.icon.setColorFilter(FilesColor.folder)
            tag.highLightCard.setCardBackgroundColor(0)
            data.action="openFolder"
          end

          data.title=fileName
          data.fileName=fileName
         else
          local config=ReBuildTool.getConfigByProjectDir(filePath)
          --data.aideluaDir=aideluaDir
          data.config=config
          local iconView=tag.icon
          local iconUrl=getProjectIconForGlide(filePath,config)
          if type(iconUrl)=="number" then
            iconView.setImageResource(iconUrl)
           else
            local options=RequestOptions()
            options.skipMemoryCache(true)--跳过内存缓存
            options.diskCacheStrategy(DiskCacheStrategy.NONE)--不缓冲disk硬盘中
            Glide.with(activity).load(iconUrl).apply(options).into(iconView)
          end
          tag.title.setText(config.appName or unknowString)
          tag.message.setText(config.packageName or unknowString)
          data.title=config.appName or unknowString
          data.action="openProject"
        end
      end


    end,
  }))

end