require "import"
import "Jesse205"

activity.setTitle(luajava.bindClass(activity.getPackageName()..".R").string.runCode)
activity.getSupportActionBar().setDisplayHomeAsUpEnabled(true)

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

local code,codeType=...
if code then
  if codeType=="lua" or not(codeType) then
    activity.doString(code,{})
  end
end
