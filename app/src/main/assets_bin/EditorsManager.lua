local EditorsManager={}

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

return EditorsManager
