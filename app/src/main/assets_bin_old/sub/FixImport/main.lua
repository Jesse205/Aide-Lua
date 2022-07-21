package.path=package.path..activity.getLuaPath("../JavaApi/?.lua;")
require "import"
import "Jesse205"
import "android.animation.Animator$AnimatorListener"
import "androidx.coordinatorlayout.widget.CoordinatorLayout"
import "com.google.android.material.floatingactionbutton.FloatingActionButton"
--import "android.content.res.ColorStateList"

import "getImportCode"
import "showPackageMenu"

activity.setTitle(R.string.javaApiViewer_fixImport)
actionBar.setDisplayHomeAsUpEnabled(true)
activity.setContentView(loadlayout2("layout"))

code,packageName=...
LoadedData=false
data={}


--复制按钮点击事件
function copyImports()
  local imports={}
  for index,content in pairs(data) do
    table.insert(imports,getImportCode(index))--把代码添加到list
  end
  --table.sort(imports)
  table.sort(imports,function(a,b)
    return string.lower(a)<string.lower(b)
  end)
  local importsStr=table.concat(imports,"\n")--把list用\n割开
  MyToast.copyText(importsStr)--复制文字
  --MyToast(R.string.copiedToClipboard)
end


function selectAll(checked)
  if classes then
    for index,content in ipairs(classes) do
      listView.setItemChecked(index-1,checked)
      data[content]=checked or nil
    end
  end
  if table.size(data)==0 then
    floatButton.hide()
   else
    floatButton.show()
  end
end

function refreshMenusState()
  if LoadedMenu then
    for index,content in ipairs(StateByLoadedMenus) do
      content.setEnabled(LoadedData)
      --[[
      if LoadedData then
        content.setIconTintList(ColorStateList(int[0].class{int{}},int{0xFF000000}))
       else
        content.setIconTintList(ColorStateList(int[0].class{int{}},int{0x99000000}))
      end
    ]]
    end
  end
end

function onCreateOptionsMenu(menu)
  local inflater=activity.getMenuInflater()
  inflater.inflate(R.menu.menu_javaapi_fiximport,menu)
  selectAllMenu=menu.findItem(R.id.menu_selectAll)
  unSelectAllMenu=menu.findItem(R.id.menu_unSelectAll)
  StateByLoadedMenus={selectAllMenu,unSelectAllMenu}

  LoadedMenu=true
  refreshMenusState()
end

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
   elseif id==R.id.menu_selectAll then
    selectAll(true)
   elseif id==R.id.menu_unSelectAll then
    selectAll(false)
  end
end

function onKeyShortcut(keyCode,event)
  local filteredMetaState = event.getMetaState() & ~KeyEvent.META_CTRL_MASK;
  if (KeyEvent.metaStateHasNoModifiers(filteredMetaState)) then
    if keyCode==KeyEvent.KEYCODE_C then
      copyImports()
      return true
    end
  end
end

function fiximport(code,packageName,application)
  require "import"
  notLoadTheme=true
  import "Jesse205"
  --import "com.shixin.LuaLexer"

  local allClasses=application.get("classes_table_fiximport")
  if allClasses then
    allClasses=luajava.astable(allClasses,true)
   else
    --local classesTable=luajava.astable(classes)
    import "androidApis.androidxApis"
    import "androidApis.systemApis"
    import "androidApis.androluaApis"
    local insertedClasses={}
    allClasses={}
    function addAndroidClasses(classes,rootPath)
      for index,className in pairs(classes) do
        if type(index)=="number" then
          --local className=content:match(".+[%.$](.+)")
          local fastReadClassesSelf=allClasses[className]
          if not(fastReadClassesSelf) then
            fastReadClassesSelf={}
            allClasses[className]=fastReadClassesSelf
          end
          local class=rootPath..className
          if not(insertedClasses[class]) then
            insertedClasses[class]=true
            table.insert(fastReadClassesSelf,class)
          end

         else
          addAndroidClasses(className,rootPath..index..".")
        end
      end
    end

    for index,content in ipairs({androidxApis,systemApis,androluaApis}) do
      addAndroidClasses(content,"")
    end
    table.insert(allClasses,activity.getPackageName()..".R")
    table.sort(allClasses)
    application.set("classes_table_fiximport",allClasses)
  end

  allClasses.R={
    "android.R",
    packageName..".R"
  }

  local importClassList={}
  local buf={}
  local last=nil


  for advance,text,column in LuaLexerIteratorBuilder(code)
    if last~=LuaTokenTypes.DOT and advance==LuaTokenTypes.NAME then
      if not(buf[text]) then
        buf[text]=true
        local fastReadClassesSelf=allClasses[text]
        if fastReadClassesSelf then
          for index,content in ipairs(fastReadClassesSelf)
            table.insert(importClassList,content)
          end
        end
      end
    end
    last=advance
  end


  --table.sort(importClassList)
  table.sort(importClassList,function(a,b)
    return string.lower(a)<string.lower(b)
  end)
  --[[
  for index,content in pairs(buf) do
    local index="[%.$]"..index.."$"
    for index2,class in ipairs(classes) do
      if string.find(class,index) then
        if not(cache[class]) then
          table.insert(ret,class)
          cache[class]=true
        end
      end
    end
  end]]
  return String(importClassList)
  --return String{dump(FastReadClasses)}
end

--延迟一毫秒隐藏悬浮球，如果不延迟的话会有动画及各种bug
task(1,function()
  floatButton.hide()
end)

activity.newTask(fiximport,function(classes)
  classes=luajava.astable(classes)
  _G.classes=classes
  adp=ArrayListAdapter(activity,android.R.layout.simple_list_item_multiple_choice,classes)
  listView.setAdapter(adp)
  adp.notifyDataSetChanged()
  progressBar.setVisibility(View.GONE)
  LoadedData=true
  refreshMenusState()
end).execute({code,packageName,application})

listView.onItemClick=function(id,v,zero,one)
  data[v.text]=v.checked or nil
  if table.size(data)==0 then--但data没有数据时候隐藏复制按钮
    floatButton.hide()
   else
    floatButton.show()
  end
end
listView.onItemLongClick=function(id,v,zero,one)
  showPackageMenu(classes[one],v,mainLay)
  return true
end
listView.onScroll=function(view,firstVisibleItem,visibleItemCount,totalItemCount)
  MyAnimationUtil.ListView.onScroll(view,firstVisibleItem,visibleItemCount,totalItemCount)
end

floatButton.onClick=copyImports
floatButton.addOnShowAnimationListener(AnimatorListener({
  onAnimationStart=function(animSet)
    listView.setPadding(0,0,0,floatButton.getHeight()+math.dp2int(16)*2)
  end
}))
floatButton.addOnHideAnimationListener(AnimatorListener({
  onAnimationStart=function(animSet)
    listView.setPadding(0,0,0,0)
  end
}))



--[[
list=ListView(activity)
list.ChoiceMode=ListView.CHOICE_MODE_MULTIPLE;
task(fiximport,path,function(v)
  rs=v
  adp=ArrayListAdapter(activity,android.R.layout.simple_list_item_multiple_choice,v)
  list.Adapter=adp
  activity.setContentView(list)
end)

function onCreateOptionsMenu(menu)
  menu.add("全选").setShowAsAction(1)
  menu.add("复制").setShowAsAction(1)
end

cm=activity.getSystemService(Context.CLIPBOARD_SERVICE)

function onOptionsItemSelected(item)
  if item.Title=="复制" then
    local buf={}

    local cs=list.getCheckedItemPositions()
    local buf={}
    for n=0,#rs-1 do
      if cs.get(n) then
        table.insert(buf,string.format("import \"%s\"",rs[n]))
      end
    end

    local str=table.concat(buf,"\n")
    local cd = ClipData.newPlainText("label", str)
    cm.setPrimaryClip(cd)
    Toast.makeText(activity,"已复制的剪切板",1000).show()
   else
    for n=0,#rs-1 do
      list.setItemChecked(n,not list.isItemChecked(n))
    end
  end
end
]]
