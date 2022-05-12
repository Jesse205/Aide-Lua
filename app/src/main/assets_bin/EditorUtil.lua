--module(...,package.seeall)
local EditorUtil={}
--[[
import "tiiehenry.code.language.LanguageNonProg"
import "tiiehenry.code.language.java.JavaLanguage"
import "tiiehenry.code.language.python.PythonLanguage"
import "tiiehenry.code.language.xml.XMLLanguage"
import "tiiehenry.code.language.lua.LuaLanguage"
import "com.myopicmobileX.textwarrior.common.LanguageXML"
import "com.xiaoyv.editor.common.LanguageJava"
import "com.xiaoyv.editor.common.LanguageNonPro"
]]
import "io.github.rosemoe.editor.langs.EmptyLanguage"
import "io.github.rosemoe.editor.langs.desc.JavaScriptDescription"
import "io.github.rosemoe.editor.langs.html.HTMLLanguage"
import "io.github.rosemoe.editor.langs.java.JavaLanguage"
import "io.github.rosemoe.editor.langs.python.PythonLanguage"
import "io.github.rosemoe.editor.langs.universal.UniversalLanguage"

EditorUtil.Editors={}
EditorUtil.IsEditors={}
EditorUtil.EditorsGroup={}

EditorUtil.NowEditorType=nil
EditorUtil.NowEditor=nil
EditorUtil.IsEdtor=nil

EditorUtil.isPreviewing=false

EditorUtil.TextFileType2EditorType={
  lua="LuaEditor",
  aly="LuaEditor",

  html="CodeEditor",
  svg="CodeEditor",
  xml="CodeEditor",
  java="CodeEditor",
  py="CodeEditor",
  pyw="CodeEditor",
  txt="CodeEditor",
  gradle="CodeEditor",
  bat="CodeEditor",
  json="CodeEditor",
}

local oldThemeId,xmlPreviewMode
EditorUtil.PreviewFunc={
  svg=function()
    EditorUtil.switchEditor("PhotoView")--将编辑器切换为Lua编辑器
    Sharp.loadFile(NowFile).into(NowEditor)

    return true
  end,
  aly=function()
    import "androidx"
    EditorUtil.switchEditor("LayoutView")--将编辑器切换为Lua编辑器
    oldThemeId=activity.getThemeResId()
    if ThemeUtil.NowAppTheme.night then
      activity.setTheme(R.style.Theme_MaterialComponents)
     else
      activity.setTheme(R.style.Theme_MaterialComponents_Light)
    end
    local layout=loadpreviewlayout(assert(loadfile(NowFile.getPath()))(),{},nil,NowProjectDirectory.getPath())
    --NowEditor.removeAllViews()
    NowEditor.addView(layout)
    return true
  end,
  alyFinish=function()
    if oldThemeId then
      activity.setTheme(oldThemeId)
    end
  end,
  alyExit=function()
    NowEditor.removeAllViews()
  end,
  xml=function()
    local content=io.readall(NowFile.getPath())
    local layout,s=content:gsub("</%w+>","}")
    if s==0 then
      return false
    end
    if content:find("</vector>") then
      xmlPreviewMode="photo"
      content=content:gsub("vector","svg")
      :gsub("http://schemas.android.com/apk/res/android","http://www.w3.org/2000/svg")
      :gsub("android:fillColor","fill")
      :gsub("@android:color/white","#ffffff")
      :gsub("@android:color/black","#000000")
      :gsub('android:tint="(.-)"',"")
      :gsub('android:pathData="(.-)"/>',function(v)
        return 'd="'..v..'"/>'
      end)
      :gsub("dp","")
      :gsub("viewportWidth(.-)>",[[viewBox="0 0 24 24">]])
      :gsub("android:","")
      EditorUtil.switchEditor("PhotoView")
      Sharp.loadString(content).into(NowEditor)
     else
      xmlPreviewMode="layout"
      layout=layout:gsub("<%?[^<>]+%?>","")
      :gsub("xmlns:android=%b\"\"","")
      :gsub("%w+:","")
      :gsub("\"([^\"]+)\"",function(s)return (string.format("\"%s\"",s:match("([^/]+)$")))end)
      :gsub("[\t ]+","")
      :gsub("\n+","\n")
      :gsub("^\n",""):gsub("\n$","")
      :gsub("<","{"):gsub("/>","}"):gsub(">",""):gsub("\n",",\n")
      import "androidx"
      EditorUtil.switchEditor("LayoutView")--将编辑器切换为Lua编辑器
      oldThemeId=activity.getThemeResId()
      if ThemeUtil.NowAppTheme.night then
        activity.setTheme(R.style.Theme_MaterialComponents)
       else
        activity.setTheme(R.style.Theme_MaterialComponents_Light)
      end
      local layout=loadpreviewlayout(assert(loadstring(layout))(),{},nil,NowProjectDirectory.getPath())
      --NowEditor.removeAllViews()
      NowEditor.addView(layout)

    end
    return true
  end,
  xmlFinish=function()
    if oldThemeId then
      activity.setTheme(oldThemeId)
    end
  end,
  xmlExit=function()
    if xmlPreviewMode=="layout" then
      NowEditor.removeAllViews()
    end
    xmlPreviewMode=nil
  end,
}


EditorUtil.TextFileType2EditorLanguage={
  --lua=LuaLanguage.getInstance(),
  --aly=LuaLanguage.getInstance(),
  --xml=LanguageXML.getInstance(),
  html=HTMLLanguage(),
  xml=JavaLanguage(),
  svg=JavaLanguage(),
  py=PythonLanguage(),
  pyw=PythonLanguage(),
  java=JavaLanguage(),
  txt=EmptyLanguage(),
  gradle=EmptyLanguage(),
  bat=EmptyLanguage(),
  html=HTMLLanguage(),
  json=JavaLanguage(),
}

function EditorUtil.switchEditor(editorType,language)
  if EditorUtil.isPreviewing then
    local exitFunc=EditorUtil.PreviewFunc[NowFileType.."Exit"]
    if exitFunc then
      exitFunc()
    end
    editChip.setChecked(true)
    EditorUtil.isPreviewing=false
  end

  for index,content in pairs(EditorUtil.EditorsGroup) do
    if editorType==index then
      local editor=EditorUtil.Editors[editorType]
      _G.NowEditor=editor
      _G.NowEditorType=editorType
      _G.IsEdtor=EditorUtil.IsEditors[editorType]
      EditorUtil.NowEditorType=editorType
      EditorUtil.NowEditor=editor
      if language then
        xpcall(function()
          if editorType=="CodeEditor" then
            editor.setEditorLanguage(language)
          end
        end,
        function(err)
          print(err)
        end)
      end
      content.setVisibility(View.VISIBLE)
      editor.requestFocus()
      MyAnimationUtil.ScrollView.onScrollChange(editor,editor.getScrollX(),editor.getScrollY(),0,0,appBarLayout,nil)
     else
      content.setVisibility(View.GONE)
    end
  end
  refreshSymbolBar(oldEditorSymbolBar)
  return EditorUtil
end

function EditorUtil.switchEditorByFileType(fileType)
  EditorUtil.switchEditor(EditorUtil.TextFileType2EditorType[fileType],EditorUtil.TextFileType2EditorLanguage[fileType])--switchEditor自带关闭预览
end

function EditorUtil.switchPreview(isPreview)
  local fileType=NowFileType
  if isPreview and not(EditorUtil.isPreviewing) then
    local succeed,oldThemeId,errorString
    if OpenedFile and IsEdtor then
      succeed=saveFile()
     else
      succeed=true
    end
    if succeed then
      local finishFunc=EditorUtil.PreviewFunc[fileType.."Finish"]
      xpcall(function()
        if not(EditorUtil.PreviewFunc[fileType]()) then
          error("Content not supported")
        end
      end,
      function(err)
        errorString=err
      end)
      if finishFunc then
        finishFunc()
      end
      if errorString then
        AlertDialog.Builder(this)
        .setTitle("Preview error")
        .setMessage(errorString)
        .setPositiveButton(android.R.string.ok,nil)
        .show()
        if errorString:find(": Content not supported$") then
          editChip.setChecked(true)
          return
        end
      end
     else
      editChip.setChecked(true)
      return
    end
    EditorUtil.isPreviewing=isPreview
    previewChip.setChecked(true)
   elseif not(isPreview) and EditorUtil.isPreviewing then
    EditorUtil.switchEditorByFileType(fileType)--自带关闭预览
  end
  return EditorUtil
end
return EditorUtil