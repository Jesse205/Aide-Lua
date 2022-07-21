require "import"
import "Jesse205"
import "console"
--import "loadlayout3"
--activity.setTitle('XML转换器')
--cm=activity.getSystemService(Context.CLIPBOARD_SERVICE)

t={
  LinearLayout;
  layout_width="fill";
  layout_height="fill";
  orientation="vertical";
  layoutTransition=newLayoutTransition();
  {
    LuaEditor;
    id="edit";
    layout_width="fill";
    layout_height="fill";
    layout_weight=1;
  };
  {
    LinearLayout;
    layout_width="fill";
    layout_marginLeft="8dp";
    layout_marginRight="8dp";
    layout_margin="4dp";
    {
      MaterialButton_OutlinedButton;
      id="open";
      text="转换",
      layout_width="fill";
      layout_marginLeft="8dp";
      layout_marginRight="8dp";
      layout_weight=1;
      onClick="click";
    } ,
    {
      MaterialButton_OutlinedButton;
      id="open";
      text="预览";
      layout_width="fill";
      layout_marginLeft="8dp";
      layout_marginRight="8dp";
      layout_weight=1;
      onClick="click2";
    };
    {
      MaterialButton_OutlinedButton;
      id="open";
      text="复制";
      layout_width="fill";
      layout_marginLeft="8dp";
      layout_marginRight="8dp";
      layout_weight=1;
      onClick="click3";
    };
    {
      MaterialButton_OutlinedButton;
      id="open";
      text="确定";
      layout_width="fill";
      layout_marginLeft="8dp";
      layout_marginRight="8dp";
      layout_weight=1;
      onClick="click4";
    } ,
  }
}

function xml2table(xml)
  local xml,s=xml:gsub("</%w+>","}")
  if s==0 then
    return xml
  end
  xml=xml:gsub("<%?[^<>]+%?>","")
  xml=xml:gsub("xmlns:android=%b\"\"","")
  xml=xml:gsub("%w+:","")
  xml=xml:gsub("\"([^\"]+)\"",function(s)return (string.format("\"%s\"",s:match("([^/]+)$")))end)
  xml=xml:gsub("[\t ]+","")
  xml=xml:gsub("\n+","\n")
  xml=xml:gsub("^\n",""):gsub("\n$","")
  xml=xml:gsub("<","{"):gsub("/>","}"):gsub(">",""):gsub("\n",",\n")
  return (xml)
end

dlg=luajava.override(AppCompatDialog,{
  onMenuItemSelected=function(super,id,item)
    dlg.dismiss()
  end},activity,(function()
  if ThemeUtil.NowAppTheme.night then
    return R.style.Theme_MaterialComponents
   else
    return R.style.Theme_MaterialComponents_Light
  end
end)())
dlg.setTitle("布局表预览")
dlg_actionBar=dlg.getSupportActionBar()
dlg_actionBar.setElevation(0)
dlg_actionBar.setDisplayHomeAsUpEnabled(true)
--[[
dlg_actionBar.setDisplayHomeAsUpEnabled(true)
dlg.onOptionsItemSelected=function(item)
  local id=item.getItemId()
  print(id)
  if id==android.R.id.home then
    activity.finish()
  end
end
]]

function show(s)
  local oldThemeId=activity.getThemeResId()
  if ThemeUtil.NowAppTheme.night then
    activity.setTheme(R.style.Theme_MaterialComponents)
   else
    activity.setTheme(R.style.Theme_MaterialComponents_Light)
  end
  dlg.setContentView(loadlayout2(loadstring("return "..s)(),{}))
  activity.setTheme(oldThemeId)
  local dia=dlg.show()
  --print(dia)
  --parentPanel=dia.findViewById(R.id.action_bar_root)
  --print(parentPanel)
end

function click()
  local str=edit.text
  str=xml2table(str)
  edit.setText(str)
  edit.format()
end

function click2()
  show(edit.text)
end


function click3(s)
  MyToast.copyText(edit.text)
end

function click4()
  layout.main=loadstring("return "..edit.text)()
  activity.setContentView(loadlayout(layout.main,{}))
  dlg2.dismiss()
end


dlg2=luajava.override(AppCompatDialog,{
  onMenuItemSelected=function(super,id,item)
    dlg2.dismiss()
end},activity,activity.getThemeResId())
dlg2_actionBar=dlg2.getSupportActionBar()
dlg2_actionBar.setElevation(0)
dlg2_actionBar.setDisplayHomeAsUpEnabled(true)

dlg2.setTitle("编辑代码")
dlg2.getWindow().setSoftInputMode(0x10)
dlg2.setContentView(loadlayout2(t))

edit.onScrollChange=function(view,l,t,oldl,oldt)
  MyAnimationUtil.ScrollView.onScrollChange(view,l,t,oldl,oldt,dlg2_actionBar)
end

function editlayout(text)
  edit.text=text
  edit.format()
  dlg2.show()
end

--[[
function onResume2()
  local cd=cm.getPrimaryClip();
  local msg=cd.getItemAt(0).getText()--.toString();
  edit.setText(msg)
end
]]