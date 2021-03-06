require "import"
import "Jesse205"
import "com.google.android.material.appbar.*"
import "com.google.android.material.behavior.*"
import "com.google.android.material.bottomappbar.*"
import "com.google.android.material.bottomnavigation.*"
import "com.google.android.material.bottomsheet.*"
import "com.google.android.material.chip.*"
import "com.google.android.material.circularreveal.*"
import "com.google.android.material.floatingactionbutton.*"
import "com.google.android.material.internal.*"
import "com.google.android.material.navigation.*"
import "com.google.android.material.tabs.*"
import "com.google.android.material.textfield.*"
import "androidx.coordinatorlayout.widget.CoordinatorLayout"
import "androidx.drawerlayout.widget.DrawerLayout"
import "androidx.recyclerview.widget.RecyclerView"
import "androidx.slidingpanelayout.widget.SlidingPaneLayout"
import "androidx.swiperefreshlayout.widget.SwipeRefreshLayout"
import "androidx.viewpager.widget.ViewPager"
import "android.util.*"

import "com.Jesse205.layout.MyEditDialogLayout"

import "loadpreviewlayout"
require "xml2table"
import "layout"

activity.setTitle(R.string.layoutHelper)
actionBar.setDisplayHomeAsUpEnabled(true)

cm=activity.getSystemService(activity.CLIPBOARD_SERVICE)


function onCreateOptionsMenu(menu)
  local inflater=activity.getMenuInflater()
  inflater.inflate(R.menu.menu_layouthelper,menu)
  local saveMenu=menu.findItem(R.id.menu_save)
  saveMenu.setVisible(toboolean(showsave))
end

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==R.id.menu_copy then
    MyToast.copyText(dumplayout2(layout.main))
   elseif id==R.id.menu_edit then
    editlayout(dumplayout2(layout.main))
   elseif id==R.id.menu_preview then
    show(dumplayout2(layout.main))
   elseif id==R.id.menu_save then
    save(dumplayout2(layout.main))
    MyToast(R.string.save_succeed)
    activity.finish()
   elseif id==android.R.id.home then
    activity.finish()
  end
end

function onCreate()
  local oldThemeId=activity.getThemeResId()
  if ThemeUtil.NowAppTheme.night then
    activity.setTheme(R.style.Theme_MaterialComponents)
   else
    activity.setTheme(R.style.Theme_MaterialComponents_Light)
  end
  activity.setContentView(loadpreviewlayout(layout.main,{}))
  activity.setTheme(oldThemeId)
end

lastclick=os.time()-2
function onKeyDown(e)
  local now=os.time()
  if e==4 then
    if now-lastclick>2 then
      MyToast("??????????????????")
      lastclick=now
      return true
    end
  end
end

function dumparray(arr)
  local ret={}
  table.insert(ret,"{\n")
  for k,v in ipairs(arr) do
    table.insert(ret,string.format("\"%s\";\n",v))
  end
  table.insert(ret,"};\n")
  return table.concat(ret)
end

function dumplayout(t)
  table.insert(ret,"{\n")
  table.insert(ret,tostring(t[1].getSimpleName()..";\n"))
  for k,v in pairs(t) do
    if type(k)=="number" then
      --do nothing
     elseif type(v)=="table" then
      table.insert(ret,k.."="..dumparray(v))
     elseif type(v)=="string" then
      if v:find("[\"\'\r\n]") then
        table.insert(ret,string.format("%s=[==[%s]==];\n",k,v))
       else
        table.insert(ret,string.format("%s=\"%s\";\n",k,v))
      end
     else
      table.insert(ret,string.format("%s=%s;\n",k,tostring(v)))
    end
  end
  for k,v in ipairs(t) do
    if type(v)=="table" then
      dumplayout(v)
    end
  end
  table.insert(ret,"};\n")
end

function dumplayout2(t)
  ret={}
  dumplayout(t)
  return table.concat(ret)
end

function save(s)
  local f=io.open(luapath,"w")
  f:write(s)
  f:close()
end




luadir,luapath=...
if luapath then
  luadir=luadir or luapath:gsub("/[^/]+$","")
end
if luadir then
  package.path=package.path..";"..luadir.."/?.lua;"
end

if luapath and luapath:find("%.aly$") then
  local f=io.open(luapath)
  local s=f:read("*a")
  f:close()
  xpcall(function()
    layout.main=assert(loadstring("return "..s))()
  end,
  function()
    MyToast("????????????????????????")
    activity.finish()
  end)
  showsave=true
end

function onTouch(v,e)
  if e.getAction()==MotionEvent.ACTION_DOWN then
    getCurr(v)
    return true
  end
end

local dm=activity.getResources().getDisplayMetrics()
function dp(n)
  return TypedValue.applyDimension(1,n,dm)
end

function to(n)
  return string.format("%ddp",n//dn)
end


dn=dp(1)
lastX=0
lastY=0
vx=0
vy=0
vw=0
vh=0
zoomX=false
zoomY=false
function move(v,e)
  curr=v.Tag
  currView=v
  ry=e.getRawY()--??????????????????Y??????
  rx=e.getRawX()--??????????????????X??????
  if e.getAction() == MotionEvent.ACTION_DOWN then
    lp=v.getLayoutParams()
    vy=v.getY()--???????????????Y??????
    vx=v.getX()--???????????????X??????
    lastY=ry--???????????????Y??????
    lastX=rx--???????????????X??????
    vw=v.getWidth()--??????????????????
    vh=v.getHeight()--??????????????????
    if vw-e.getX()<20 then
      zoomX=true--?????????????????????????????????????????????
     elseif vh-e.getY()<20 then
      zoomY=true--?????????????????????????????????????????????
    end

   elseif e.getAction() == MotionEvent.ACTION_MOVE then
    --lp.gravity=Gravity.LEFT|Gravity.TOP --????????????????????????
    if zoomX then
      lp.width=(vw+(rx-lastX))--??????????????????
     elseif zoomY then
      lp.height=(vh+(ry-lastY))--??????????????????
     else
      lp.x=(vx+(rx-lastX))--?????????????????????
      lp.y=(vy+(ry-lastY))--?????????????????????
    end
    v.setLayoutParams(lp)--??????????????????????????????
    --v.Parent.invalidate()
   elseif e.getAction() == MotionEvent.ACTION_UP then
    if (rx-lastX)^2<100 and (ry-lastY)^2<100 then
      getCurr(v)
     else
      curr.layout_x=to(v.getX())
      curr.layout_y=to(v.getY())
      if zoomX then
        curr.layout_width=to(v.getWidth())
       elseif zoomY then
        curr.layout_height=to(v.getHeight())
      end
    end
    zoomX=false--???????????????
    zoomY=false--???????????????
  end
  return true
end

function getCurr(v)
  curr=v.Tag
  currView=v
  fd_dlg.setView(nil)
  fd_dlg.title=tostring(v.Class.getSimpleName())
  if luajava.instanceof(v,GridLayout) then
    fd_dlg.setItems(fds_grid)
   elseif luajava.instanceof(v,LinearLayout) then
    fd_dlg.setItems(fds_linear)
   elseif luajava.instanceof(v,ViewGroup) then
    fd_dlg.setItems(fds_group)
   elseif luajava.instanceof(v,TextView) then
    fd_dlg.setItems(fds_text)
   elseif luajava.instanceof(v,ImageView) then
    fd_dlg.setItems(fds_image)
   else
    fd_dlg.setItems(fds_view)
  end
  if luajava.instanceof(v.Parent,LinearLayout) then
    fd_list.getAdapter().add("layout_weight")
   elseif luajava.instanceof(v.Parent,AbsoluteLayout) then
    fd_list.getAdapter().insert(5,"layout_x")
    fd_list.getAdapter().insert(6,"layout_y")
   elseif luajava.instanceof(v.Parent,RelativeLayout) then
    local adp=fd_list.getAdapter()
    for k,v in ipairs(relative) do
      adp.add(v)
    end
  end
  fd_dlg.show()
end

function adapter(t)
  local ls=ArrayList()
  for k,v in ipairs(t) do
    ls.add(v)
  end
  return ArrayAdapter(activity,android.R.layout.simple_list_item_1, ls)
end



curr=nil
--activity.Theme=android.R.style.Theme_Material_Light
xpcall(function()
  local oldThemeId=activity.getThemeResId()
  if ThemeUtil.NowAppTheme.night then
    activity.setTheme(R.style.Theme_MaterialComponents)
   else
    activity.setTheme(R.style.Theme_MaterialComponents_Light)
  end
  activity.setContentView(loadpreviewlayout(layout.main,{}))
  activity.setTheme(oldThemeId)
end,
function()
  MyToast("????????????????????????")
  activity.finish()
end)

relative={
  "layout_above","layout_alignBaseline","layout_alignBottom","layout_alignEnd","layout_alignLeft","layout_alignParentBottom","layout_alignParentEnd","layout_alignParentLeft","layout_alignParentRight","layout_alignParentStart","layout_alignParentTop","layout_alignRight","layout_alignStart","layout_alignTop","layout_alignWithParentIfMissing","layout_below","layout_centerHorizontal","layout_centerInParent","layout_centerVertical","layout_toEndOf","layout_toLeftOf","layout_toRightOf","layout_toStartOf"
}

--?????????????????????
fd_dlg=AlertDialogBuilder(activity)
fd_list=fd_dlg.getListView()
fds_grid={
  "??????","??????","?????????","?????????",
  "id","orientation",
  "columnCount","rowCount",
  "layout_width","layout_height","layout_gravity",
  "background","gravity",
  "layout_margin","layout_marginLeft","layout_marginTop","layout_marginRight","layout_marginBottom",
  "padding","paddingLeft","paddingTop","paddingRight","paddingBottom",
}

fds_linear={
  "??????","??????","?????????","?????????",
  "id","orientation","layout_width","layout_height","layout_gravity",
  "background","gravity",
  "layout_margin","layout_marginLeft","layout_marginTop","layout_marginRight","layout_marginBottom",
  "padding","paddingLeft","paddingTop","paddingRight","paddingBottom",
}

fds_group={
  "??????","??????","?????????","?????????",
  "id","layout_width","layout_height","layout_gravity",
  "background","gravity",
  "layout_margin","layout_marginLeft","layout_marginTop","layout_marginRight","layout_marginBottom",
  "padding","paddingLeft","paddingTop","paddingRight","paddingBottom",
}

fds_text={
  "??????","?????????",
  "id","layout_width","layout_height","layout_gravity",
  "background","text","textColor","hint","hintTextColor","textSize","singleLine","gravity",
  "layout_margin","layout_marginLeft","layout_marginTop","layout_marginRight","layout_marginBottom",
  "padding","paddingLeft","paddingTop","paddingRight","paddingBottom",
}

fds_image={
  "??????","?????????",
  "id","layout_width","layout_height","layout_gravity",
  "background","src","scaleType","gravity",
  "layout_margin","layout_marginLeft","layout_marginTop","layout_marginRight","layout_marginBottom",
  "padding","paddingLeft","paddingTop","paddingRight","paddingBottom",
}

fds_view={
  "??????","?????????",
  "id","layout_width","layout_height","layout_gravity",
  "background","gravity",
  "layout_margin","layout_marginLeft","layout_marginTop","layout_marginRight","layout_marginBottom",
  "padding","paddingLeft","paddingTop","paddingRight","paddingBottom",
}

--??????????????????
checks={}
checks.singleLine={"true","false"}
checks.orientation={"vertical","horizontal"}
checks.gravity={"left","top","right","bottom","start","center","end"}
checks.layout_gravity={"left","top","right","bottom","start","center","end"}
checks.scaleType={
  "matrix",
  "fitXY",
  "fitStart",
  "fitCenter",
  "fitEnd",
  "center",
  "centerCrop",
  "centerInside"}


function addDir(out,dir,f)
  local ls=f.listFiles()
  for n=0,#ls-1 do
    local name=ls[n].getName()
    if ls[n].isDirectory() then
      addDir(out,dir..name.."/",ls[n])
     elseif name:find("%.j?pn?g$") then
      table.insert(out,dir..name)
    end
  end
end

function checkid()
  local cs={}
  local parent=currView.Parent.Tag
  for k,v in ipairs(parent) do
    if v==curr then
      break
    end
    if type(v)=="table" and v.id then
      table.insert(cs,v.id)
    end
  end
  return cs
end

rbs={"layout_alignParentBottom","layout_alignParentEnd","layout_alignParentLeft","layout_alignParentRight","layout_alignParentStart","layout_alignParentTop","layout_centerHorizontal","layout_centerInParent","layout_centerVertical"}
ris={"layout_above","layout_alignBaseline","layout_alignBottom","layout_alignEnd","layout_alignLeft","layout_alignRight","layout_alignStart","layout_alignTop","layout_alignWithParentIfMissing","layout_below","layout_toEndOf","layout_toLeftOf","layout_toRightOf","layout_toStartOf"}
for k,v in ipairs(rbs) do
  checks[v]={"true","false","none"}
end

for k,v in ipairs(ris) do
  checks[v]=checkid
end

if luadir then
  checks.src=function()
    local src={}
    addDir(src,"",File(luadir))
    return src
  end
end

fd_list.onItemClick=function(l,v,p,i)
  fd_dlg.hide()
  local fd=tostring(v.Text)
  if checks[fd] then
    if type(checks[fd])=="table" then
      check_dlg.Title=fd
      check_dlg.setItems(checks[fd])
      check_dlg.show()
     else
      check_dlg.Title=fd
      check_dlg.setItems(checks[fd](fd))
      check_dlg.show()
    end
   else
    func[fd]()
  end
end

--????????????????????????
cd_dlg=AlertDialogBuilder(activity)
cd_list=cd_dlg.getListView()
cd_list.onItemClick=function(l,v,p,i)
  getCurr(chids[p])
  cd_dlg.hide()
end

--?????????????????????
check_dlg=AlertDialogBuilder(activity)
check_list=check_dlg.getListView()
check_list.onItemClick=function(l,v,p,i)
  local v=tostring(v.text)
  if #v==0 or v=="none" then
    v=nil
  end
  local fld=check_dlg.Title
  local old=curr[tostring(fld)]
  curr[tostring(fld)]=v
  check_dlg.hide()
  local oldThemeId=activity.getThemeResId()
  if ThemeUtil.NowAppTheme.night then
    activity.setTheme(R.style.Theme_MaterialComponents)
   else
    activity.setTheme(R.style.Theme_MaterialComponents_Light)
  end
  local s,l=pcall(loadpreviewlayout,layout.main,{})
  if s then
    activity.setContentView(l)
   else
    curr[tostring(fld)]=old
    print(l)
  end
  activity.setTheme(oldThemeId)
end

func={}
setmetatable(func,{__index=function(t,k)
    return function()
      sfd_dlg.Title=k--tostring(currView.Class.getSimpleName())
      --sfd_dlg.Message=k
      fld.Text=curr[k] or ""
      sfd_dlg.show()
    end
  end
})
func["??????"]=function()
  add_dlg.Title=tostring(currView.Class.getSimpleName())
  for n=0,#ns-1 do
    if n~=i then
      el.collapseGroup(n)
    end
  end
  add_dlg.show()
end

func["??????"]=function()
  local gp=currView.Parent.Tag
  if gp==nil then
    MyToast("???????????????????????????")
    return
  end
  for k,v in ipairs(gp) do
    if v==curr then
      table.remove(gp,k)
      break
    end
  end
  local oldThemeId=activity.getThemeResId()
  if ThemeUtil.NowAppTheme.night then
    activity.setTheme(R.style.Theme_MaterialComponents)
   else
    activity.setTheme(R.style.Theme_MaterialComponents_Light)
  end
  activity.setContentView(loadpreviewlayout(layout.main,{}))
  activity.setTheme(oldThemeId)
end


func["?????????"]=function()
  local p=currView.Parent
  if p.Tag==nil then
    MyToast("??????????????????")
   else
    getCurr(p)
  end
end

chids={}
func["?????????"]=function()
  chids={}
  local arr={}
  for n=0,currView.ChildCount-1 do
    local chid=currView.getChildAt(n)
    chids[n]=chid
    table.insert(arr,chid.Class.getSimpleName())
  end
  cd_dlg.Title=tostring(currView.Class.getSimpleName())
  cd_dlg.setItems(arr)
  cd_dlg.show()
end

--?????????????????????
add_dlg=AppCompatDialog(activity)
add_dlg.title="??????"
wdt_list=ListView(activity)

ns={
  "Widget (?????????)","Check view (????????????)","Adapter view (???????????????)",
  "Advanced Widget (????????????)","Layout (??????)","Advanced Layout (????????????)",
  "Material Design (????????????)",
}

wds={
  {"Button","EditText","TextView",
    "ImageButton","ImageView"},
  {"CheckBox","RadioButton","ToggleButton","Switch"},
  {"ListView","GridView","PageView","ExpandableListView","Spinner","ViewPager","RecyclerView"},
  {"SeekBar","ProgressBar","RatingBar",
    "DatePicker","TimePicker","NumberPicker"},
  {"LinearLayout","AbsoluteLayout","FrameLayout","RelativeLayout","CoordinatorLayout"},
  {"CardView","RadioGroup","GridLayout",
    "ScrollView","HorizontalScrollView"},--?????????????????????SwipeRefreshLayout???SlidingPaneLayout???DrawerLayout
  {"AppBarLayout","CollapsingToolbarLayout",
    "BottomAppBar","BottomNavigationItemView","BottomNavigationView",
    "MaterialButton","MaterialCardView","Chip","ChipGroup","CircularRevealFrameLayout",
    "CircularRevealGridLayout","FloatingActionButton","NavigationView","TabLayout","TextInputEditText","TextInputLayout"},
}


mAdapter=ArrayExpandableListAdapter(activity)
for k,v in ipairs(ns) do
  mAdapter.add(v,wds[k])
end

el=ExpandableListView(activity)
el.setDividerHeight(0)
el.setAdapter(mAdapter)
add_dlg.setContentView(el)

el.onChildClick=function(l,v,g,c)
  local w={_G[wds[g+1][c+1]]}
  table.insert(curr,w)
  local oldThemeId=activity.getThemeResId()
  if ThemeUtil.NowAppTheme.night then
    activity.setTheme(R.style.Theme_MaterialComponents)
   else
    activity.setTheme(R.style.Theme_MaterialComponents_Light)
  end
  local s,l=pcall(loadpreviewlayout,layout.main,{})
  if s then
    activity.setContentView(l)
   else
    table.remove(curr)
    print(l)
  end
  activity.setTheme(oldThemeId)
  add_dlg.hide()
end



function ok()
  local v=tostring(fld.Text)
  if #v==0 then
    v=nil
  end
  local fld=sfd_dlg.Title
  local old=curr[tostring(fld)]
  curr[tostring(fld)]=v
  --sfd_dlg.hide()
  local oldThemeId=activity.getThemeResId()
  if ThemeUtil.NowAppTheme.night then
    activity.setTheme(R.style.Theme_MaterialComponents)
   else
    activity.setTheme(R.style.Theme_MaterialComponents_Light)
  end
  local s,l=pcall(loadpreviewlayout,layout.main,{})
  if s then
    activity.setContentView(l)
   else
    curr[tostring(fld)]=old
    print(l)
  end
  activity.setTheme(oldThemeId)
end

function none()
  local key=sfd_dlg.title
  local old=curr[key]
  curr[key]=nil
  --sfd_dlg.hide()
  local oldThemeId=activity.getThemeResId()
  if ThemeUtil.NowAppTheme.night then
    activity.setTheme(R.style.Theme_MaterialComponents)
   else
    activity.setTheme(R.style.Theme_MaterialComponents_Light)
  end
  local s,l=pcall(loadpreviewlayout,layout.main,{})
  if s then
    activity.setContentView(l)
   else
    curr[key]=old
    print(l)
  end
  activity.setTheme(oldThemeId)
end


--?????????????????????
local ids={}
sfd_dlg=AlertDialogBuilder(activity)
--fld=EditText(activity)
sfd_dlg.setView(MyEditDialogLayout.load({hint="??????"},ids))
sfd_dlg.setPositiveButton("??????",ok)
sfd_dlg.setNegativeButton("??????",nil)
sfd_dlg.setNeutralButton("???",none)
fld=ids.edit
