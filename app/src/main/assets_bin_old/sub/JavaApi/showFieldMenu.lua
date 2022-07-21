local function showFieldMenu(name,view,mainLay)
  local pop=PopupMenu(activity,view)
  local menu=pop.Menu
  pop.inflate(R.menu.menu_javaapi_item_field)
  local copyNameMenu=menu.findItem(R.id.menu_copy_name)
  local copyName2Menu=menu.findItem(R.id.menu_copy_name2)
  copyNameMenu.title=name
  copyName2Menu.title=name:match("%.(.+)")
  pop.show()
  pop.onMenuItemClick=function(item)
    local id=item.getItemId()
    if id==R.id.menu_copy_name
      or id==R.id.menu_copy_name2
      then
      MyToast.copyText(item.title,mainLay)
    end
  end
end
return showFieldMenu