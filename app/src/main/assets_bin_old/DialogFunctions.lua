local cannotBeEmptyStr=activity.getString(R.string.Jesse205_edit_error_cannotBeEmpty)
local existsStr=activity.getString(R.string.file_exists)

function deleteFileDialog(name,file)
  AlertDialog.Builder(this)
  .setTitle(formatResStr(R.string.delete_withName,{name}))
  .setMessage(activity.getString(R.string.delete_warning))
  .setPositiveButton(android.R.string.ok,function()
    local succeed=LuaUtil.rmDir(file)
    if succeed then
      refresh()
      showSnackBar(R.string.delete_succeed)
      if OpenedFile then
        closeFileAndTabByPath(file.getPath(),true)
      end
     else
      showSnackBar(R.string.delete_failed)
    end
  end)
  .setNegativeButton(android.R.string.cancel,nil)
  .show()
end

function createDirsDialog(nowDir)--创建文件夹对话框
  local builder
  builder=EditDialogBuilder(activity)
  :setTitle(R.string.directory_create)
  :setHint(R.string.directory_name)
  :setAllowNull(false)
  :setPositiveButton(R.string.create,function(dialog,text)
    local editLay=builder.ids.editLay
    local errorState
    local fileName=text
    local filePath=rel2AbsPath(fileName,nowDir.getPath())
    local file=File(filePath)
    if file.exists() then--文件不能存在
      editLay
      .setError(existsStr)
      .setErrorEnabled(true)
      return true
    end
    editLay.setErrorEnabled(false)
    xpcall(function()
      file.mkdirs()
      showSnackBar(R.string.create_success)
      refresh(nowDir)
      dialog.dismiss()
    end,
    function(err)
      showErrorDialog(R.string.create_failed,err)
      errorState=true
      return true
    end)
    if errorState then
      return true
    end
  end,true,true)
  :setNegativeButton(android.R.string.cancel,nil)
  builder:show()
end

function renameDialog(oldFile)--重命名对话框
  local fileName=oldFile.getName()
  local builder
  builder=EditDialogBuilder(activity)
  :setTitle(R.string.rename)
  :setText(fileName)
  :setHint(R.string.name)
  :setAllowNull(false)
  :setPositiveButton(R.string.rename,function(dialog,text)
    local editLay=builder.ids.editLay
    local errorState
    local newName=text

    local oldParentFile=oldFile.getParentFile()
    local oldFilePath=oldFile.getPath()
    local lowerOldFilePath=string.lower(oldFilePath)

    local newFilePath=rel2AbsPath(newName,oldParentFile.getPath())
    local newFile=File(newFilePath)
    local newParentFile=newFile.getParentFile()
    local lowerNewFilePath=string.lower(newFilePath)

    local isSelfFile=lowerNewFilePath==lowerOldFilePath
    if newFilePath==oldFilePath then--没改就退出
      return
    end
    if newFile.exists() and not(isSelfFile) then--文件不能存在
      editLay
      .setError(existsStr)
      .setErrorEnabled(true)
      return true
    end
    editLay.setErrorEnabled(false)
    xpcall(function()
      newParentFile.mkdirs()
      if isSelfFile then--大小写直接修改无效，使用临时文件
        local tempFilePath=AppPath.Temp.."/"..os.time()
        os.rename(oldFilePath, tempFilePath)
        os.rename(tempFilePath, newFilePath)
       else
        os.rename(oldFilePath, newFilePath)
      end
      local tabTag=FilesTabList[lowerOldFilePath]
      if tabTag then
        local tab=tabTag.tab
        local newFile=File(newFilePath)
        local fileType=ProjectUtil.getFileTypeByName(newName)
        if string.lower(NowFile.getPath())==lowerOldFilePath then
          NowFile=newFile
          NowFileType=fileType
        end
        FilesTabList[lowerNewFilePath]=tabTag
        FilesTabList[lowerOldFilePath]=nil
        tabTag.fileType=fileType
        tabTag.file=newFile
        tabTag.shortFilePath=shortPath(newFile.getPath(),true,NowProjectDirectory.getParent().."/")
        tab.setText(newName)--设置显示的文字
        if oldTabIcon and notSafeModeEnable then
          tab.setIcon(ProjectUtil.getFileIconResIdByType(fileType))
        end
        initFileTabView(tab,tabTag)
      end

      showSnackBar(R.string.rename_success)
      refresh(newParentFile)
    end,
    function(err)
      showErrorDialog(R.string.rename_fail,err)
      errorState=true
      return true
    end)
    if errorState then
      return true
    end
  end,true,true)
  :setNegativeButton(android.R.string.cancel,nil)
  builder:show()
  local _,splitEnd=utf8.find(fileName,".+%.")
  if splitEnd then
    splitEnd=splitEnd-1
  end
  builder.ids.edit.setSelection(0,splitEnd or utf8.len(fileName))
end