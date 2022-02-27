require "import"
import "Jesse205"
import "com.Jesse205.layout.innocentlayout.GridViewLayout"
import "item"

activity.setTitle(R.string.Jesse205_themePicker)
activity.setContentView(loadlayout2(GridViewLayout))
activity.getSupportActionBar().setDisplayHomeAsUpEnabled(true)

function onOptionsItemSelected()
  activity.finish()
end



function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
end

gridView.onScroll=function(view,firstVisibleItem,visibleItemCount,totalItemCount)
  MyAnimationUtil.ListView.onScroll(view,firstVisibleItem,visibleItemCount,totalItemCount)
end

local nowTheme=ThemeUtil.getAppTheme()

datas={}
adp=LuaAdapter(activity, datas,item)
gridView.setAdapter(adp)

for index,content in pairs(ThemeUtil.APPTHEMES) do
  --print(index)
  local data={
    title={text=content.show.name},
    preview={cardBackgroundColor=content.show.preview},
    key=content.name,
    message={},
  }
  table.insert(datas,data)
  if nowTheme==content.name then
    data.now={Visibility=View.VISIBLE}
   else
    data.now={Visibility=View.GONE}
  end
  if content.night then
    data.message.text=R.string.Jesse205_theme_darkMode
   else
    data.message.text=""
  end
end


adp.notifyDataSetChanged()

scroll=...
if scroll then
  scroll=luajava.astable(scroll)
  gridView.setSelection(scroll[1])
end

gridView.onItemClick=function(id,v,zero,one)
  local key=datas[one].key
  if nowTheme~=key then
    ThemeUtil.setAppTheme(key)
    local aRanim=android.R.anim
    local pos=gridView.getFirstVisiblePosition()
    local scroll=gridView.getChildAt(0).getTop()
    newActivity("main",aRanim.fade_in,aRanim.fade_out,{{pos,scroll}})
    activity.finish()
    gridView.setEnabled(false)
  end
end

screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({
  gridViews={gridView},
})

onConfigurationChanged(activity.getResources().getConfiguration())



