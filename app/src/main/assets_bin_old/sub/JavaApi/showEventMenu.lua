local function showEventMenu(name,view,mainLay)
  local pop=PopupMenu(activity,view)
  local menu=pop.Menu
  pop.inflate(R.menu.menu_javaapi_item_event)
  local copyNameMenu=menu.findItem(R.id.menu_copy_name)
  copyNameMenu.title=name
  pop.show()
  pop.onMenuItemClick=function(item)
    local id=item.getItemId()
    if id==R.id.menu_copy_name
      then
      MyToast.copyText(item.title,mainLay)
    end
  end
end
return showEventMenu