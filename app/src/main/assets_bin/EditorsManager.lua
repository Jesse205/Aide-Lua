local EditorsManager={}
local actionEvents={}
EditorsManager.actions=actionEvents
EditorsManager.language=nil
EditorsManager.editor=nil

import "io.github.rosemoe.editor.langs.EmptyLanguage"
import "io.github.rosemoe.editor.langs.desc.JavaScriptDescription"
import "io.github.rosemoe.editor.langs.html.HTMLLanguage"
import "io.github.rosemoe.editor.langs.java.JavaLanguage"
import "io.github.rosemoe.editor.langs.python.PythonLanguage"
import "io.github.rosemoe.editor.langs.universal.UniversalLanguage"
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

EditorsManager.fileType2Language={
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
function EditorsManager.action.undo()
end

function EditorsManager.action.redo()
end

function EditorsManager.action.getText()
end

function EditorsManager.action.save2Tab()
  local text=EditorsManager.action.getText()
  if text then
   else
    print("无法获取代码")
  end
end


function EditorsManager.switchLanguage(language)
  EditorsManager.language=language
end

function EditorsManager.switchEditor(editorType)
  EditorsManager.editor=editorLayouts[editorType]
end

return EditorsManager
