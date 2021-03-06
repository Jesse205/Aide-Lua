local ScreenFixUtil={}
local resources=resources
function ScreenFixUtil.getNavigationBarHeight()
  local resourceId = resources.getIdentifier("navigation_bar_height","dimen", "android");
  local height = resources.getDimensionPixelSize(resourceId)
  return height
end
function ScreenFixUtil.getStatusBarHeight()
  local resourceId=resources.getIdentifier("status_bar_height", "dimen","android")
  local height=resources.getDimensionPixelSize(resourceId)
  return height
end

function ScreenFixUtil.getSmallestScreenWidthDp()
  return resources.getConfiguration().smallestScreenWidthDp
end

function ScreenFixUtil.getScreenRealSize()
  import "android.util.DisplayMetrics"
  local wm=activity.getSystemService(Context.WINDOW_SERVICE)
  local displayMetrics=DisplayMetrics()
  wm.getDefaultDisplay().getRealMetrics(displayMetrics)
  return displayMetrics.widthPixels,displayMetrics.heightPixels
end

function ScreenFixUtil.getDensityDpi()
  import "android.util.DisplayMetrics"
  local dm=DisplayMetrics()
  activity.WindowManager.getDefaultDisplay().getMetrics(dm)
  return dm.densityDpi;
end

local ScreenConfigDecoder={
  device="phone",
}
ScreenFixUtil.ScreenConfigDecoder=ScreenConfigDecoder
setmetatable(ScreenConfigDecoder,ScreenConfigDecoder)

--[[
{
  device={
    phone=function()
    pad=function()
    pc=function()
    }
  orientation={
    identical={LinearLayout...}
    different={LinearLayout...}
    }
  fillParent={View...}
  layoutManagers={LayoutManager...}
  singleViews={View...}
  }
]]
function ScreenConfigDecoder.__call(self,events)
  self=table.clone(self)
  self.events=events
  return self
end

local function setLayoutManagersSpanCount(layoutManagers,count)
  if layoutManagers then
    for index,content in ipairs(layoutManagers) do
      content.setSpanCount(count)
    end
  end
end
ScreenFixUtil.setLayoutManagersSpanCount=setLayoutManagersSpanCount

local function setLayoutsOrientation(lays,orientation)
  if lays then
    for index,content in ipairs(lays) do
      content.setOrientation(orientation)
    end
  end
end
ScreenFixUtil.setLayoutsOrientation=setLayoutsOrientation

local function setLayoutsSize(lays,height,width)
  if lays then
    for index,content in ipairs(lays) do
      local linearParams=content.getLayoutParams()
      if height then
        linearParams.height=height
      end
      if width then
        linearParams.width=width
      end
      content.setLayoutParams(linearParams)
    end
  end
end
ScreenFixUtil.setLayoutsSize=setLayoutsSize


local function setGridViewsNumColumns(gridViews,columns)
  if gridViews then
    for index,content in ipairs(gridViews) do
      content.setNumColumns(columns)
    end
  end
end
ScreenFixUtil.setGridViewsNumColumns=setGridViewsNumColumns


function ScreenConfigDecoder.decodeConfiguration(self,config)
  local smallestScreenWidthDp=config.smallestScreenWidthDp--???????????????dp???
  local smallestScreenWidth=math.dp2int(smallestScreenWidthDp)--????????????
  local screenWidthDp=config.screenWidthDp--????????????????????????dp???
  local screenWidth=math.dp2int(screenWidthDp)--???????????????

  local events=self.events
  local orientationLays=events.orientation
  local layoutManagers=events.layoutManagers--????????????????????????
  local singleCardViews=events.singleCardViews--??????????????????????????????
  local listViews=events.listViews--?????????
  local gridViews=events.gridViews--???layoutManagers???????????????
  local fillParentViews=events.fillParentViews--?????????

  local onDeviceChanged=events.onDeviceChanged--????????????????????????
  local identicalLays,differentLays--?????????????????????????????????
  local orientation=config.orientation


  if orientationLays then
    identicalLays=orientationLays.identical
    differentLays=orientationLays.different
  end

  local oldDevice=self.device
  local device
  if smallestScreenWidth~=self.smallestScreenWidth then--?????????????????????
    if smallestScreenWidth<theme.number.padWidth then--??????????????????
      device="phone"
     elseif smallestScreenWidth<theme.number.pcWidth then
      device="pad"
     else
      device="pc"
    end
    self.smallestScreenWidth=smallestScreenWidth
   else--???????????????????????????????????????????????????
    device=oldDevice
  end

  if orientation~=self.orientation or device~=self.device then--??????????????????
    if orientation==Configuration.ORIENTATION_LANDSCAPE then--?????????
      setLayoutsOrientation(identicalLays,LinearLayout.HORIZONTAL)
      setLayoutsOrientation(differentLays,LinearLayout.VERTICAL)
      setLayoutsSize(fillParentViews,-1,-2)
      if device=="phone" then--?????????????????????2???
        setLayoutManagersSpanCount(layoutManagers,2)
        setGridViewsNumColumns(gridViews,2)
       elseif device=="pad" then--?????????????????????4???
        setLayoutManagersSpanCount(layoutManagers,4)
        setGridViewsNumColumns(gridViews,4)
       elseif device=="pc" then--?????????????????????6???
        setLayoutManagersSpanCount(layoutManagers,6)
        setGridViewsNumColumns(gridViews,6)
      end
     else
      setLayoutsOrientation(identicalLays,LinearLayout.VERTICAL)
      setLayoutsOrientation(differentLays,LinearLayout.HORIZONTAL)
      setLayoutsSize(fillParentViews,-2,-1)
      if device=="phone" then--?????????????????????1???
        setLayoutManagersSpanCount(layoutManagers,1)
        setGridViewsNumColumns(gridViews,1)
       elseif device=="pad" then--?????????????????????2???
        setLayoutManagersSpanCount(layoutManagers,2)
        setGridViewsNumColumns(gridViews,2)
       elseif device=="pc" then--?????????????????????4???
        setLayoutManagersSpanCount(layoutManagers,4)
        setGridViewsNumColumns(gridViews,4)
      end
    end
    self.orientation=config.orientation
  end

  if singleCardViews then
    if screenWidthDp>640+32 then
      setLayoutsSize(singleCardViews,nil,math.dp2int(640))
     else
      setLayoutsSize(singleCardViews,nil,-1)
    end
  end

  if listViews then
    if device=="phone" then--????????????
      if screenWidthDp>704 then
        setLayoutsSize(listViews,nil,math.dp2int(704))
       else
        setLayoutsSize(listViews,nil,-1)
      end
     elseif device=="pad" then--????????????
      if screenWidthDp>800 then
        setLayoutsSize(listViews,nil,math.dp2int(800))
       else
        setLayoutsSize(listViews,nil,-1)
      end
     elseif device=="pc" then--????????????
      if screenWidthDp>1000 then
        setLayoutsSize(listViews,nil,math.dp2int(1000))
       else
        setLayoutsSize(listViews,nil,-1)
      end

    end
  end

  self:decodeMenus(screenWidthDp)

  if device~=oldDevice then--?????????????????????
    self.device=device
    if onDeviceChanged then
      onDeviceChanged(device,oldDevice)
    end
  end


end

function ScreenConfigDecoder.decodeMenus(self,screenWidthDp)
  local events=self.events
  local menus=events.menus
  if menus then
    if not(MenuItemCompat) then
      import "androidx.core.view.MenuItemCompat"
    end
    for showWidthDp,content in pairs(menus) do
      for index,content in ipairs(content) do
        if showWidthDp<=screenWidthDp then
          MenuItemCompat.setShowAsAction(content, MenuItemCompat.SHOW_AS_ACTION_ALWAYS)
         else
          MenuItemCompat.setShowAsAction(content, MenuItemCompat.SHOW_AS_ACTION_NEVER)
        end
      end
    end
  end
end

return ScreenFixUtil
