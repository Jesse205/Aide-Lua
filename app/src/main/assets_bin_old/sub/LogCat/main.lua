require "import"
pcall(function()
  import "Jesse205"
end)
isSupportActivity=false

--判断是不是AndroidX的类
nowParent=activity.getClass()
while nowParent do
  local className=nowParent.getName()
  if className=="androidx.appcompat.app.AppCompatActivity" then
    isSupportActivity=true
    break
  end
  nowParent=nowParent.getSuperclass()--父类
end
nowParent=nil

--设置主题
if not(Jesse205) then
  import "android.app.*"
  import "android.os.*"
  import "android.widget.*"
  import "android.view.*"
  import "android.content.*"
  if isSupportActivity then
    activity.setTheme(R.style.Theme_MaterialComponents)
   else
    pcall(function()
      import "autotheme"
    end)
    pcall(function()androidhwext={R=luajava.bindClass("androidhwext.R")} end)
    if not(androidhwext and pcall(function()activity.setTheme(androidhwext.R.style.Theme_Emui)end)) then--没有hwext或者无法设置emui主题
      if autotheme then--有androlua的自动主题
        activity.setTheme(autotheme())--就用自动主题
       else
        activity.setTheme(android.R.style.Theme_DeviceDefault_Settings)
      end
    end
  end
end

if isSupportActivity then
  actionBar=activity.getSupportActionBar()
 else
  actionBar=activity.getActionBar()
end
actionBar.setDisplayHomeAsUpEnabled(true)

--添加菜单
items={"All","Lua","Test","Tcc","Error","Warning","Info","Debug","Verbose","清空"}
function onCreateOptionsMenu(menu)
  for index,content in ipairs(items) do
    menu.add(content)
  end
end

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
   else
    local title=item.title
    func[title]()
    if title~="清空" then
      lastReadType=title--保存一下，方便清空
      actionBar.setSubtitle(title)--设置副标题
    end
  end
end

function show(content)--展示日志
  adapter.clear()
  if #content~=0 then
    local l=1
    for i in content:gfind("%[ *%d+%-%d+ *%d+:%d+:%d+%.%d+ *%d+: *%d+ *%a/[^ ]+ *%]") do
      if l~=1 then
        adapter.add(String(content:sub(l,i-1)).trim())
      end
      l=i
    end
    adapter.add(String(content:sub(l)).trim())
   else
    adapter.add("<运行应用程序以查看其日志输出>")
  end
end

function readLog(value)--读取日志
  local p=io.popen("logcat -d -v long "..value)
  local content=p:read("*a")
  p:close()
  content=content:gsub("%-+ beginning of[^\n]*\n","")
  return content
end

function clearLog()--清除日志
  local p=io.popen("logcat -c")
  local s=p:read("*a")
  p:close()
  return s
end

func={}
func.All=function()
  task(readLog,"",show)
end
func.Lua=function()
  task(readLog,"lua:* *:S",show)
end
func.Test=function()
  task(readLog,"test:* *:S",show)
end
func.Tcc=function()
  task(readLog,"tcc:* *:S",show)
end
func.Error=function()
  task(readLog,"*:E",show)
end
func.Warning=function()
  task(readLog,"*:W",show)
end
func.Info=function()
  task(readLog,"*:I",show)
end
func.Debug=function()
  task(readLog,"*:D",show)
end
func.Verbose=function()
  task(readLog,"*:V",show)
end
func.清空=function()
  task(clearLog,function()
    func[lastReadType]()
  end)
end

local array = activity.getTheme().obtainStyledAttributes({
  android.R.attr.textColorPrimary,
  android.R.attr.dividerVertical,
})
item={--条目
  TextView;
  textIsSelectable=true;
  textSize="14sp";
  padding="16dp";
  textColor=array.getColor(0,0);
}

layout=ListView(activity)
layout.fastScrollEnabled=true
if Jesse205 then--Jesse205主题没有分割线
  layout.setDivider(array.getDrawable(1))
end
adapter=LuaArrayAdapter(activity,item)
layout.setAdapter(adapter)
if MyAnimationUtil then
  layout.onScroll=function(view,firstVisibleItem,visibleItemCount,totalItemCount)
    MyAnimationUtil.ListView.onScroll(view,firstVisibleItem,visibleItemCount,totalItemCount,topCard)
  end
end

array.recycle()


if CoordinatorLayout then
  mainLay=CoordinatorLayout(activity)
  mainLay.addView(layout)
  local linearParams=layout.getLayoutParams()
  linearParams.height=-1
  linearParams.width=-1
  layout.setLayoutParams(linearParams)
  layout=mainLay
end

func.Lua()
lastReadType="Lua"
actionBar.setSubtitle("Lua")

activity.setContentView(layout)

local linearParams=layout.getLayoutParams()
linearParams.height=-1
linearParams.width=-1
layout.setLayoutParams(linearParams)


