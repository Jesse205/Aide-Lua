require "import"
import "Jesse205"
import "openSourceLicenses"

import "item"

activity.setTitle(R.string.Jesse205_openSourceLicense)
activity.setContentView(loadlayout2("layout",_ENV))
actionBar.setDisplayHomeAsUpEnabled(true)

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
end

adp=LuaCustRecyclerAdapter(AdapterCreator({
  getItemCount=function()
    return #openSourceLicenses
  end,
  getItemViewType=function(position)
    return 0
  end,
  onCreateViewHolder=function(parent,viewType)
    local ids={}
    local view=loadlayout2(item,ids)
    local holder=LuaCustRecyclerHolder(view)
    view.setTag(ids)
    ids.cardViewChild.setBackground(ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary))
    ids.cardViewChild.onClick=function()
      local url=ids._data.url
      if url then
        openUrl(url)
      end
    end
    return holder
  end,

  onBindViewHolder=function(holder,position)
    local data=openSourceLicenses[position+1]
    local tag=holder.view.getTag()
    tag._data=data
    local name=data.name
    local message=data.message
    local license=data.license
    tag.name.text=name

    local messageView=tag.message
    local licenseView=tag.license
    if message then
      messageView.text=message
      messageView.setVisibility(View.VISIBLE)
     else
      messageView.setVisibility(View.GONE)
    end
    if license then
      licenseView.text=license
      licenseView.setVisibility(View.VISIBLE)
     else
      licenseView.setVisibility(View.GONE)
    end
    tag.cardViewChild.setClickable(toboolean(data.url))
  end,
}))
recyclerView.setAdapter(adp)
layoutManager=StaggeredGridLayoutManager(1,StaggeredGridLayoutManager.VERTICAL)
recyclerView.setLayoutManager(layoutManager)
recyclerView.addOnScrollListener(RecyclerView.OnScrollListener{
  onScrolled=function(view,dx,dy)
    MyAnimationUtil.RecyclerView.onScroll(view,dx,dy,sideAppBarLayout,"LastSideActionBarElevation")
  end
})
recyclerView.getViewTreeObserver().addOnGlobalLayoutListener({
  onGlobalLayout=function()
    if activity.isFinishing() then
      return
    end
    MyAnimationUtil.RecyclerView.onScroll(recyclerView,0,0,sideAppBarLayout,"LastSideActionBarElevation")
  end
})

screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({
  layoutManagers={layoutManager},
})

onConfigurationChanged(activity.getResources().getConfiguration())