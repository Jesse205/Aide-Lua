require "import"
--import "androidx"
import "androidx.appcompat.app.*"
import "androidx.appcompat.view.*"
import "androidx.appcompat.widget.*"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

import "androidx.coordinatorlayout.widget.CoordinatorLayout"

--activity.setTitle("Aide Lua")
--activity.setTheme(R.style.AppTheme)
activity.setContentView(loadlayout("layout"))
actionBar=activity.getSupportActionBar()
actionBar.setDisplayHomeAsUpEnabled(true)

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end