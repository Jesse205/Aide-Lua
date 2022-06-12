local EditorsManager={}
local managerActions={}
EditorsManager.actions=managerActions
--EditorsManager.language=nil
EditorsManager.editorConfig=nil
EditorsManager.editorType=nil
EditorsManager.editor=nil
local editorActions,editor,editorGroupViews

import "io.github.rosemoe.editor.widget.CodeEditor"
import "io.github.rosemoe.editor.widget.schemes.SchemeDarcula"
import "io.github.rosemoe.editor.widget.schemes.SchemeGitHub"
import "io.github.rosemoe.editor.langs.EmptyLanguage"
import "io.github.rosemoe.editor.langs.desc.JavaScriptDescription"
import "io.github.rosemoe.editor.langs.html.HTMLLanguage"
import "io.github.rosemoe.editor.langs.java.JavaLanguage"
import "io.github.rosemoe.editor.langs.python.PythonLanguage"
import "io.github.rosemoe.editor.langs.universal.UniversalLanguage"

MyLuaEditor=editor2my(LuaEditor)
MyCodeEditor=editor2my(CodeEditor)

import "layouts.editorLayouts"

--编辑器提示关键词
EditorsManager.keyWords={
  --一些事件
  "onCreate",
  "onStart",
  "onResume",
  "onPause",
  "onStop",
  "onDestroy",
  "onActivityResult",
  "onResult",
  "onCreateOptionsMenu",
  "onOptionsItemSelected",
  "onTouchEvent",
  "onKeyLongPress",
  "onConfigurationChanged",
  "onHook",
  "onAccessibilityEvent",
  "onKeyUp",
  "onKeyDown",

  "onClick",
  "onTouch",
  "onLongClick",
  "onItemClick",
  "onItemLongClick",
  "onVersionChanged",
  "onScroll";
  "onScrollChange",
  "onNewIntent",
  "onSaveInstanceState",

  --一些自带的类或者包
  "android",
  "R",

  --一些常用但不自带的类
  "PhotoView",
  "LuaLexerIteratorBuilder",
}

--Jesse205库关键词
EditorsManager.jesse205KeyWords={
  "newActivity","getSupportActionBar","getSharedData","setSharedData",
  "activity2luaApi",

  --一些标识
  "initApp","notLoadTheme","useCustomAppToolbar",
  "resources","application","inputMethodService","actionBar",
  "notLoadTheme","darkStatusBar","darkNavigationBar",
  "window","safeModeEnable","notSafeModeEnable","decorView",

  "ThemeUtil","theme","formatResStr","autoSetToolTip",
  "showLoadingDia","closeLoadingDia","getNowLoadingDia",
  "showErrorDialog","toboolean","rel2AbsPath","copyText",
  "newSubActivity","isDarkColor","openInBrowser","openUrl",
  "loadlayout2",

  "AppPath","ThemeUtil","EditDialogBuilder","ImageDialogBuilder",
  "NetErrorStr","MyToast","AutoToolbarLayout","PermissionUtil",
  "AutoCollapsingToolbarLayout","SettingsLayUtil","Jesse205",

  --自定义View或者Util
  "MyTextInputLayout","MyTitleEditLayout","MyEditDialogLayout",
  "MyTipLayout","MySearchLayout","MyAnimationUtil","MyStyleUtil",

  --适配器
  "MyLuaMultiAdapter","MyLuaAdapter","LuaCustRecyclerAdapter",
  "LuaCustRecyclerHolder","AdapterCreator",
}

local fileType2Language={--部分暂时没有对应的语言
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
EditorsManager.fileType2Language=fileType2Language

local fileType2EditorType={
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
EditorsManager.fileType2Language=fileType2Language

--默认的管理器的活动事件
local function generalActionEvent(readName,readName,...)
  local func=editorActions[readName]
  if func then
    if func=="default" then
      return editor[readName](...)
     else
      return func(editorGroupViews,...)
    end
   else
    return false
  end
end
function managerActions.undo()
  generalActionEvent("undo","undo")
end

function managerActions.redo()
  generalActionEvent("redo","redo")
end
function managerActions.comment()
  generalActionEvent("comment","comment")
end

function managerActions.getText()
  local text=generalActionEvent("getText","getText")
  if text then
    return tostring(text)
  end
end

function managerActions.search(text,gotoNext)
  local searchActions=editorActions.search
  if searchActions then
    if searchActions=="default" or searchActions.search=="default" then
      if gotoNext then
        editor.search(text)
      end
     elseif searchActions.search
      searchActions.search(editorGroupViews，text,gotoNext)
    end
   else
    return false
  end
end

function managerActions.save2Tab()--保存到标签
  local text=EditorsManager.action.getText()
  if text then
   else
    print("警告：无法获取代码")
  end
end

local searching
function EditorsManager.startSearch()
  local searchActions=editorActions.search
  if searchActions then
    local search=EditorsManager.action.search
    local ids
    local idx=0
    searching=true
    if searchActions.start then
      searchActions.start(editorGroupViews)
    end
    ids=SearchActionMode({
      onEditorAction=function(view,actionId,event)
        if event then
          search(view.text,true)
        end
      end,
      onTextChanged=function(text)
        application.set("editor_search_text",text)
        search(text)
      end,
      onActionItemClicked=function(mode,item)
        local title=item.title
        if title==activity.getString(R.string.abc_searchview_description_search) then
          local text=ids.searchEdit.text
          search(ids.searchEdit.text,true)
        end
      end,
      onDestroyActionMode=function(mode)
        searching=false
        if searchActions.finish then
          searchActions.finish(editorGroupViews)
        end
      end,
    })
    local searchContent=application.get("editor_search_text")
    if searchContent then
      ids.searchEdit.text=searchContent
      ids.searchEdit.setSelection(utf8.len(tostring(searchContent)))
    end
  end
end


function EditorsManager.switchLanguage(language)
  editor.setEditorLanguage(language)
end

function EditorsManager.switchEditor(editorType)
  if EditorsManager.editorType==editorType then--如果已经是当前编辑器，则不需要再切换一次了
    print("警告：编辑器切换冲突")
    return
  end
  EditorsManager.editorType=editorType
  local editorConfig=editorLayouts[editorType]
  EditorsManager.editorConfig=editorConfig
  editorActions=editorConfig.action
  if editorActions==nil then
    editorActions={}
    editorConfig.action=editorActions
  end

  --智能获取编辑器视图
  editorGroupViews=editorConfig.initedViews
  if editorGroupViews==nil then
    editorGroupViews={}
    loadlayout2(editorConfig.layout,editorGroupViews,LinearLayout)
    editorConfig.init(editorGroupViews)
    editorConfig.initedViews=editorGroupViews
  end
  editor=editorGroupViews.editor
  EditorsManager.editor=editor
end

function EditorsManager.switchEditorByFileType(fileType)
  EditorsManager.switchEditor(fileType2EditorType[fileType])
  EditorsManager.switchLanguage(fileType2Language[fileType])
end

return EditorsManager
