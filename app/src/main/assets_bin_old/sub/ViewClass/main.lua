package.path=package.path..activity.getLuaPath("../JavaApi/?.lua;")
require "import"
--activity.setTheme(R.style.Theme_MaterialComponents_Light_DarkActionBar)
import "Jesse205"

--import "android.animation.LayoutTransition"
import "androidx.viewpager.widget.*"
import "com.google.android.material.tabs.*"
import "com.google.android.material.appbar.AppBarLayout"
import "com.google.android.material.textfield.*"

import "com.Jesse205.adapter.MyLuaAdapter"
--import "SpannableStringUtil"

import "item"

local classString=...
LoadSucceed,class=pcall(luajava.bindClass,classString)

if not(LoadSucceed) or not(class) then
  activity.result({R.string.javaApiViewer_notFindClass})
  return
end

PageTypes={"parents","constructors","events","fields","methods"}

import "getImportCode"

import "showPackageMenu"
import "showConstructorMenu"
import "showFieldMenu"
import "showEventMenu"
import "showMethodMenu"
import "com.Jesse205.app.actionmode.SearchActionMode"
PageItemLists={
  {},
  {},
  {},
  {},
  {},
}
PageItemShowLists={
  {},
  {},
  {},
  {},
  {},
}

ParentsList=PageItemLists[1]
ConList=PageItemLists[2]
EventsList=PageItemLists[3]
FieldsList=PageItemLists[4]
MethodsList=PageItemLists[5]

ParentsShowList=PageItemShowLists[1]
ConShowList=PageItemShowLists[2]
EventsShowList=PageItemShowLists[3]
FieldsShowList=PageItemShowLists[4]
MethodsShowList=PageItemShowLists[5]

PageItemTab={}

NowPage=nil
AllNum=0

activity.setTitle(R.string.javaApiViewer)
activity.setContentView(loadlayout2("layout"))

actionBar.setDisplayHomeAsUpEnabled(true)
--actionBar.setElevation(0)
local classDir,className=classString:match("(.+)%.(.+)")
actionBar.setTitle(className or classString)--设置标题
actionBar.setSubtitle(("Located at \"%s\""):format(classDir))


function onCreateOptionsMenu(menu)
  local inflater=activity.getMenuInflater()
  inflater.inflate(R.menu.menu_javaapi_viewclass,menu)
  LoadedMenu=true
end

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
   elseif id==R.id.menu_search then
    local ids
    ids=SearchActionMode({
      onEditorAction=function(view,actionId,event)
        if event then
          local text=view.text
          if checkTextError(text,view) then
            return
          end
          searchItem(text)
        end
      end,
      onTextChanged=function(text)
        text=tostring(text)
        if checkTextError(text,ids.searchEdit) then
          return
        end
        if AllNum<=500 then
          searchItem(text)
        end
      end,
      onActionItemClicked=function(mode,item)
        local title=item.title
        if title==activity.getString(R.string.abc_searchview_description_search) then
          local searchEdit=ids.searchEdit
          local text=tostring(searchEdit.text)
          if checkTextError(text,searchEdit) then
            return
          end
          searchItem(text)
        end
      end,
      onDestroyActionMode=function(mode)
        if ids.searchEdit.text~="" then
          searchItem("")
        end
      end,
    })
  end
end

function checkTextError(text,searchEdit)
  local success,err=pcall(string.find,"",text)
  if success then
    searchEdit.setError(nil)
    return false
   else
    searchEdit.setError(err)
    return true
  end
end

function switchTab(id)
  adp.clear()
  adp.addAll(PageItemShowLists[id])
  adp.notifyDataSetChanged()
  NowPage=id
end

function shortString(text)
  return text:gsub("java%.lang%.String","String")
end

--adp=ArrayAdapter(activity,android.R.layout.simple_list_item_1)
datas={}
adp=MyLuaAdapter(activity,datas,item)
listView.setAdapter(adp)
listView.onItemClick=function(id,v,zero,one)
  local name=datas[one].name
  if NowPage==1 then
    if name~=classString then
      newActivity("main",{name})
    end
    --[[
   elseif NowPage==2 then
   elseif NowPage==3 then
   elseif NowPage==4 then
   elseif NowPage==5 then]]
  end
end
listView.onItemLongClick=function(id,v,zero,one)
  local text=datas[one].name
  if NowPage==1 then
    showPackageMenu(text,v,mainLay)
    return true
   elseif NowPage==2 then
    showConstructorMenu(text,v,mainLay)
    return true
   elseif NowPage==3 then
    showEventMenu(text,v,mainLay)
    return true
   elseif NowPage==4 then
    showFieldMenu(text,v,mainLay)
    return true
   elseif NowPage==5 then
    showMethodMenu(text,v,mainLay)
    return true
  end
end
listView.onScroll=function(view,firstVisibleItem,visibleItemCount,totalItemCount)
  MyAnimationUtil.ListView.onScroll(view,firstVisibleItem,visibleItemCount,totalItemCount,topCard)
end


local addedParents={}
local nowParent=class
while nowParent do
  local className=nowParent.getName()
  nowParent=nowParent.getSuperclass()--父类
  if addedParents[className] then
    break
  end
  local summary
  if nowParent then
    summary="Inherited from "..nowParent.getName()
   else
    summary="Top class"
  end
  table.insert(ParentsList,{name=className,summary=summary})
  AllNum=AllNum+1
  addedParents[className]=true
end


constructors=luajava.astable(class.getConstructors())--构建
for index,content in ipairs(constructors) do
  content=shortString(tostring(content))
  local info,method=content:match("(.+) .+[%.$](.+%(.-%))")
  table.insert(ConList,{name=method,summary=info})
  AllNum=AllNum+1
end

allMethods=class.getMethods()--方法
for item=0,#allMethods-1 do
  local methodInfo=shortString(tostring(allMethods[item]))
  local info,method,throws=methodInfo:match("(.+) (.-%)) ?(.*)")
  if method:find("%..-%..-%(") then
    method=method:match(".+%.(.-%..-%(.-%))")
  end
  if throws and throws~="" then
    info=info.."\n"..throws
  end
  table.insert(MethodsList,{name=method,summary=info})
  local throws=methodInfo:match("throws (.+)")
  local event=method:match("setOn(%a+)Listener")--事件
  if event then
    local shorEvent="on"..event
    table.insert(EventsList,{name=shorEvent,summary=info})
    AllNum=AllNum+1
  end
end

fields=class.getFields()--字段
for index,content in ipairs(luajava.astable(fields)) do
  content=shortString(tostring(content))
  local info,name,shortname=tostring(content):match("(.+) .+[%.$](.-%.(.+))")
  local summary=("%s\n(lower: %s)"):format(info,string.lower(shortname))
  pcall(function()
    summary=("%s\n(value: %s)"):format(summary,tostring(Class[shortname]))
  end)
  table.insert(FieldsList,{name=name,summary=summary,info=info})
  AllNum=AllNum+1
end



for index,content in ipairs(PageTypes) do
  local tab=tabs.newTab()
  tab.tag={id=index}
  tab.setText(R.string["javaApiViewer_"..content])
  tabs.addTab(tab)
  PageItemTab[index]=tabs
end

tabs.addOnTabSelectedListener(TabLayout.OnTabSelectedListener({
  onTabSelected=function(tab)
    switchTab(tab.tag.id)
  end,
  onTabReselected=function(tab)
    --switchTab(tab.tag.id)
  end,
  onTabUnselected=function(tab)
  end
}))
--tabs.getTabAt(0).select()
--switchTab(1)



function searchItem(text)
  local isEmptyText=text==""
  for index,list in ipairs(PageItemLists) do
    local showList=PageItemShowLists[index]
    table.clear(showList)
    for index,content in ipairs(list) do
      local lowerText=string.lower(text)
      if isEmptyText
        or (content.name and string.lower(content.name):find(lowerText))
        or (content.summary and string.lower(content.summary):find(lowerText))
        then
        table.insert(showList,content)
      end
    end
  end
  adp.notifyDataSetChanged()
  switchTab(NowPage or 1)
end
--[[
searchButton.onClick=function()
  searchItem(searchEdit.text)
end

searchEdit.onEditorAction=function(view)
  if searchButton.clickable then
    searchItem(view.text)
    return true
  end
end
]]
searchItem("")
