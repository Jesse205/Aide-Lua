local function showConstructorMenu(name,view,mainLay)
  local pop=PopupMenu(activity,view)
  local menu=pop.Menu
  pop.inflate(R.menu.menu_javaapi_item_constructor)
  local copyNameMenu=menu.findItem(R.id.menu_copy_name)
  local copyCallMenu=menu.findItem(R.id.menu_copy_call)
  local copyCall2Menu=menu.findItem(R.id.menu_copy_call2)
  local baseName=name:match("(.+)%(.-%)")
  copyNameMenu.title=baseName
  copyCallMenu.title=baseName.."()"
  copyCall2Menu.title=name
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
return showConstructorMenu