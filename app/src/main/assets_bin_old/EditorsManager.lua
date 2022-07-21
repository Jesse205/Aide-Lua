local EditorsManager={}
local managerActions={}
EditorsManager.actions=managerActions
--EditorsManager.language=nil
EditorsManager.editorConfig=nil
EditorsManager.editorType=nil
EditorsManager.editor=nil
--编辑器活动(事件)，编辑器(View)，视图列表(table)
local editorActions,editor,editorGroupViews

import "io.github.rosemoe.editor.widget.CodeEditor"
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
EditorsManager.keyWords=String({
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
})

--Jesse205库关键词
EditorsManager.jesse205KeyWords=String({
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
})

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

local fileType2EditorType={--获取文件对应的编辑器
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
local function generalActionEvent(name1,name2,...)
  local func=editorActions[name1]
  if func then--func不为nil，说明编辑器支持此功能
    if func=="default" then
      return editor[name2](...)
     else
      return func(editorGroupViews,...)
    end
   else
    return false
  end
end

function managerActions.undo()--撤销
  generalActionEvent("undo","undo")
end

function managerActions.redo()--重做
  generalActionEvent("redo","redo")
end

function managerActions.commented()--注释
  generalActionEvent("commented","commented")
end

function managerActions.getText()--获取编辑器文字内容
  local text=generalActionEvent("getText","getText")
  if text then
    return tostring(text)
  end
end
function managerActions.setText(...)--设置编辑器文字内容
  local text=generalActionEvent("setText","setText",...)
  if text then
    return tostring(text)
  end
end

function managerActions.search(text,gotoNext)--搜索
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
    FilesTabManager.changeContent(text)
   else
    print("警告：无法获取代码")
  end
end

local searching,searchedContent
function EditorsManager.startSearch()--启动搜索
  local searchActions=editorActions.search
  if type(searchActions)~="table" then
    searchActions=nil
  end
  if searchActions then
    local search=EditorsManager.action.search
    local ids
    --local idx=0
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
        searchedContent=text
        --application.set("editor_search_text",text)
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
        if searchActions.finish then--结束搜索
          searchActions.finish(editorGroupViews)
        end
      end,
    })
    --local searchContent=application.get("editor_search_text")
    if searchedContent then--恢复已搜索的内容
      ids.searchEdit.text=searchedContent
      ids.searchEdit.setSelection(utf8.len(tostring(searchedContent)))
    end
  end
end

function EditorsManager.switchPreview(state)
end

function EditorsManager.switchLanguage(language)
  editor.setEditorLanguage(language)
end

--切换编辑器
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

  --print(editor)
  editor.requestFocus()
  if editorConfig.supportScroll then
    MyAnimationUtil.ScrollView.onScrollChange(editor,editor.getScrollX(),editor.getScrollY(),0,0,appBarLayout,nil)
   else
    MyAnimationUtil.ScrollView.onScrollChange(editor,0,0,0,0,appBarLayout,nil)
  end
end

--同时切换编辑器和语言，一般用于打开文本文件
function EditorsManager.switchEditorByFileType(fileType)
  --先切换编辑器，后切换编辑器语言，因为语言的设置是给当前正在使用的编辑器使用的
  EditorsManager.switchEditor(fileType2EditorType[fileType])
  EditorsManager.switchLanguage(fileType2Language[fileType])
end

function EditorsManager.init(previewChipGroup,editChip,previewChip)
  local previewChipGroupSelectedId
  previewChipGroup.setOnCheckedChangeListener{
    onCheckedChanged=function(chipGroup, selectedId)
      if selectedId==-1 and previewChipGroupSelectedId then
        local chip=chipGroup.findViewById(previewChipGroupSelectedId)
        chip.setChecked(true)
        return
       elseif chipGroup.getParent().getVisibility()==View.VISIBLE then
        local chip=chipGroup.findViewById(selectedId)
        if chip then
          previewChipGroupSelectedId=chip.getId()
          return
        end
      end
      previewChipGroupSelectedId=nil
    end
  }

  editChip.onClick=function()
    EditorsManager.switchPreview(false)
  end
  previewChip.onClick=function()
    EditorsManager.switchPreview(true)
  end
end

return EditorsManager
