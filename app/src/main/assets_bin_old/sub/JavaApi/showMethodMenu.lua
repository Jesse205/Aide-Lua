local function showMethodMenu(name,view,mainLay)
  local pop=PopupMenu(activity,view)
  local menu=pop.Menu
  pop.inflate(R.menu.menu_javaapi_item_method)
  local copyNameMenu=menu.findItem(R.id.menu_copy_name)
  local copyCallMenu=menu.findItem(R.id.menu_copy_call)
  local copyCall2Menu=menu.findItem(R.id.menu_copy_call2)
  local name=name:match(".-%.(.+)")
  local baseName=name:match("(.+)%(.-%)")
  copyNameMenu.title=baseName
  local callName=baseName.."()"
  copyCallMenu.title=callName
  copyCall2Menu.title=name
  copyCall2Menu.setVisible(toboolean(name~=callName))
  pop.show()
  pop.onMenuItemClick=function(item)
    local id=item.getItemId()
    if id==R.id.menu_copy_name
      or id==R.id.menu_copy_call
      or id==R.id.menu_copy_call2
      then
      MyToast.copyText(item.title,mainLay)
    end
  end
end
return showMethodMenu