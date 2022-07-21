require "import"
import "Jesse205"
import "loadpreviewlayout"
import "viewList"
import "defaultLayout"

activity.setTitle(R.string.app_name)
activity.setContentView(loadlayout2("layout"))
actionBar.setDisplayHomeAsUpEnabled(true)

projectPath,layoutContent=...--传入的文件路径

if layoutContent then
  editFileMode=true
 else
  layoutContent=defaultLayout
  editFileMode=false
end
activity.setLuaDir(projectPath)


function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
end

function refreshLayout()
  presentationView.removeAllViews()
  local view=loadpreviewlayout(loadstring(layoutContent)())
  presentationView.addView(view)
end

xpcall(function()
  refreshLayout()
end,
function(err)
  print(err)
  MyToast("暂时不支持此布局")
  layoutContent=defaultLayout
  editFileMode=false
end)

print(layoutContent,editFileMode)



screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({

})

onConfigurationChanged(activity.getResources().getConfiguration())

